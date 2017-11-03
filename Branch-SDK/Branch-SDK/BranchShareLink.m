//
//  BranchShareLink.m
//  Branch-SDK
//
//  Created by Edward Smith on 3/13/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

#import "BranchShareLink.h"
#import "BranchConstants.h"
#import "BNCFabricAnswers.h"
#import "BranchActivityItemProvider.h"
#import "BNCDeviceInfo.h"
#import "BNCXcode7Support.h"
#import "BNCLog.h"
#import "BNCViewControllerManager.h"
#import "Branch.h"
@class BranchShareActivityItem;

typedef NS_ENUM(NSInteger, BranchShareActivityItemType) {
    BranchShareActivityItemTypeBranchURL = 0,
    BranchShareActivityItemTypeShareText,
    BranchShareActivityItemTypeOther,
};

#pragma mark BranchShareLink

@interface BranchShareLink () {
    NSPointerArray* _activityItems;
}

- (id) shareObjectForItem:(BranchShareActivityItem*)activityItem
             activityType:(UIActivityType)activityType;

@property (nonatomic, strong) NSURL *shareURL;
@end

#pragma mark - BranchShareActivityItem

@interface BranchShareActivityItem : UIActivityItemProvider
@property (nonatomic, assign) BranchShareActivityItemType itemType;
@property (nonatomic, strong) BranchShareLink *parent;
@end

@implementation BranchShareActivityItem

- (id) initWithPlaceholderItem:(id)placeholderItem {
    self = [super initWithPlaceholderItem:placeholderItem];
    if (!self) return self;

    if ([placeholderItem isKindOfClass:NSString.class]) {
        self.itemType = BranchShareActivityItemTypeShareText;
    } else {
        self.itemType = BranchShareActivityItemTypeOther;
    }

    return self;
}

- (id) item {
    return [self.parent shareObjectForItem:self activityType:self.activityType];
}

@end

#pragma mark - BranchShareLink

@implementation BranchShareLink

- (instancetype _Nullable) initWithUniversalObject:(BranchUniversalObject*_Nonnull)universalObject
                                    linkProperties:(BranchLinkProperties*_Nonnull)linkProperties {
    self = [super init];
    if (!self) return self;

    _universalObject = universalObject;
    _linkProperties = linkProperties;
    return self;
}

- (void) shareDidComplete:(BOOL)completed activityError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(branchShareLink:didComplete:withError:)]) {
        [self.delegate branchShareLink:self didComplete:completed withError:error];
    }
    if (completed && !error)
        [BranchEvent customEventWithName:BNCShareCompletedEvent contentItem:self.universalObject];
    NSDictionary *attributes = [self.universalObject getDictionaryWithCompleteLinkProperties:self.linkProperties];
    [BNCFabricAnswers sendEventWithName:@"Branch Share" andAttributes:attributes];
}

- (NSArray<UIActivityItemProvider*>*_Nonnull) activityItems {
    if (_activityItems) {
        return [_activityItems allObjects];
    }

    // Make sure we can share

    if (!(self.universalObject.canonicalIdentifier ||
          self.universalObject.canonicalUrl ||
          self.universalObject.title)) {
        BNCLogWarning(@"A canonicalIdentifier, canonicalURL, or title are required to uniquely"
               " identify content. In order to not break the end user experience with sharing,"
               " Branch SDK will proceed to create a URL, but content analytics may not properly"
               " include this URL.");
    }
    
    self.serverParameters =
        [[self.universalObject getParamsForServerRequestWithAddedLinkProperties:self.linkProperties]
            mutableCopy];
    if (self.linkProperties.matchDuration) {
        self.serverParameters[BRANCH_REQUEST_KEY_URL_DURATION] = @(self.linkProperties.matchDuration);
    }

    // Log share initiated event
    [BranchEvent customEventWithName:BNCShareInitiatedEvent contentItem:self.universalObject];

    NSMutableArray *items = [NSMutableArray new];
    BranchShareActivityItem *item = nil;
    if (self.shareText.length) {
        item = [[BranchShareActivityItem alloc] initWithPlaceholderItem:self.shareText];
        item.itemType = BranchShareActivityItemTypeShareText;
        item.parent = self;
        [items addObject:item];
    }

    NSString *URLString =
        [[Branch getInstance]
            getLongURLWithParams:self.serverParameters
            andChannel:self.linkProperties.channel
            andTags:self.linkProperties.tags
            andFeature:self.linkProperties.feature
            andStage:self.linkProperties.stage
            andAlias:self.linkProperties.alias];
    self.shareURL = [[NSURL alloc] initWithString:URLString];
    if (self.returnURL)
        item = [[BranchShareActivityItem alloc] initWithPlaceholderItem:self.shareURL];
    else
        item = [[BranchShareActivityItem alloc] initWithPlaceholderItem:self.shareURL.absoluteString];
    item.itemType = BranchShareActivityItemTypeBranchURL;
    item.parent = self;
    [items addObject:item];

    [_activityItems addPointer:(__bridge void * _Nullable)(item)];

    if (self.shareObject) {
        item = [[BranchShareActivityItem alloc] initWithPlaceholderItem:self.shareObject];
        item.itemType = BranchShareActivityItemTypeOther;
        item.parent = self;
        [items addObject:item];
    }

    _activityItems = [NSPointerArray weakObjectsPointerArray];
    for (item in items)
        [_activityItems addPointer:(__bridge void * _Nullable)(item)];

    return items;
}

- (void) presentActivityViewControllerFromViewController:(UIViewController*_Nullable)viewController
                                                  anchor:(id _Nullable)anchorViewOrButtonItem {

    UIActivityViewController *shareViewController =
        [[UIActivityViewController alloc]
            initWithActivityItems:self.activityItems
            applicationActivities:nil];
    shareViewController.title = self.title;

    if ([shareViewController respondsToSelector:@selector(completionWithItemsHandler)]) {

        shareViewController.completionWithItemsHandler =
            ^ (NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                [self shareDidComplete:completed activityError:activityError];
            };

    } else {

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        shareViewController.completionHandler =
            ^ (UIActivityType activityType, BOOL completed) {
                [self shareDidComplete:completed activityError:nil];
            };
        #pragma clang diagnostic pop
        
    }

    if (self.linkProperties.controlParams[BRANCH_LINK_DATA_KEY_EMAIL_SUBJECT]) {
        @try {
            [shareViewController
                setValue:self.linkProperties.controlParams[BRANCH_LINK_DATA_KEY_EMAIL_SUBJECT]
                forKey:@"subject"];
        }
        @catch (NSException*) {
            BNCLogWarning(@"Unable to setValue 'emailSubject' forKey 'subject' on UIActivityViewController.");
        }
    }

    UIViewController *presentingViewController = nil;
    if ([viewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        presentingViewController = viewController;
    } else {
        presentingViewController = [[BNCViewControllerManager alloc] init].currentViewController;
    }

    if (!presentingViewController) {
        BNCLogError(@"No view controller is present to show the share sheet. Not showing sheet.");
        return;
    }

    // Required for iPad/Universal apps on iOS 8+
    if ([presentingViewController respondsToSelector:@selector(popoverPresentationController)]) {
        if ([anchorViewOrButtonItem isKindOfClass:UIBarButtonItem.class]) {
            UIBarButtonItem *anchor = (UIBarButtonItem*) anchorViewOrButtonItem;
            shareViewController.popoverPresentationController.barButtonItem = anchor;
        } else
        if ([anchorViewOrButtonItem isKindOfClass:UIView.class]) {
            UIView *anchor = (UIView*) anchorViewOrButtonItem;
            shareViewController.popoverPresentationController.sourceView = anchor;
            shareViewController.popoverPresentationController.sourceRect = anchor.bounds;
        } else {
            shareViewController.popoverPresentationController.sourceView = presentingViewController.view;
            shareViewController.popoverPresentationController.sourceRect = CGRectMake(0.0, 0.0, 40.0, 40.0);
        }
    }
    [presentingViewController presentViewController:shareViewController animated:YES completion:nil];
}

- (id) shareObjectForItem:(BranchShareActivityItem*)activityItem
             activityType:(UIActivityType)activityType {

    _activityType = [activityType copy];
    self.linkProperties.channel =
        [BranchActivityItemProvider humanReadableChannelWithActivityType:self.activityType];

    if ([self.delegate respondsToSelector:@selector(branchShareLinkWillShare:)]) {
        [self.delegate branchShareLinkWillShare:self];
    }
    if (activityItem.itemType == BranchShareActivityItemTypeShareText) {
        return self.shareText;
    }
    if (activityItem.itemType == BranchShareActivityItemTypeOther) {
        return self.shareObject;
    }

    // Else activityItem.itemType == BranchShareActivityItemTypeURL

    // Because Facebook et al immediately scrape URLs, we add an additional parameter to the
    // existing list, telling the backend to ignore the first click.

    NSDictionary *scrapers = @{
        @"Facebook":    @1,
        @"Twitter":     @1,
        @"Slack":       @1,
        @"Apple Notes": @1
    };
    NSString *userAgentString = nil;
    if (self.linkProperties.channel && scrapers[self.linkProperties.channel]) {
        userAgentString = [BNCDeviceInfo userAgentString];
    }
    NSString *URLString =
        [[Branch getInstance]
            getShortURLWithParams:self.serverParameters
            andTags:self.linkProperties.tags
            andChannel:self.linkProperties.channel
            andFeature:self.linkProperties.feature
            andStage:self.linkProperties.stage
            andCampaign:self.linkProperties.campaign
            andAlias:self.linkProperties.alias
            ignoreUAString:userAgentString
            forceLinkCreation:YES];
    self.shareURL = [NSURL URLWithString:URLString];
    return (self.returnURL) ? self.shareURL :self.shareURL.absoluteString;
}

- (BOOL) returnURL {
    BOOL returnURL = YES;
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 11.0 &&
        [self.activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        returnURL = NO;
    }
    return returnURL;
}

@end
