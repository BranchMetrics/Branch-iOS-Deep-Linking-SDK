//
//  BranchOpenRequest.h
//  Branch-TestBed
//
//  Created by Graham Mueller on 5/26/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BNCServerRequest.h"
#import "BNCCallbacks.h"

@interface BranchOpenRequestLinkParams : NSObject
@property (copy, nonatomic) NSString *linkClickIdentifier;
@property (copy, nonatomic) NSString *spotlightIdentifier;
@property (copy, nonatomic) NSString *universalLinkUrl;
@property (copy, nonatomic) NSString *referringURL;
@property (copy, nonatomic) NSString *externalIntentURI;
@property (assign, nonatomic) BOOL dropURLOpen;
@end

@interface BranchOpenRequest : BNCServerRequest

// URL that triggered this install or open event
@property (nonatomic, copy, readwrite) NSString *urlString;
@property (nonatomic, copy) callbackWithStatus callback;
@property (nonatomic, copy, readwrite) BranchOpenRequestLinkParams *linkParams;

+ (void) waitForOpenResponseLock;
+ (void) releaseOpenResponseLock;
+ (void) setWaitNeededForOpenResponseLock;

- (id)initWithCallback:(callbackWithStatus)callback;
- (id)initWithCallback:(callbackWithStatus)callback isInstall:(BOOL)isInstall;

@end
