//
//  Branch_SDK_test.m
//  Branch-SDK test
//
//  Created by Qinwei Gong on 2/19/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//


#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "BNCPreferenceHelper.h"
#import "BNCServerInterface.h"
#import "BNCConfig.h"
#import "BNCEncodingUtils.h"
#import "BNCServerRequestQueue.h"
#import "BNCTestCase.h"
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>


NSString * const TEST_BRANCH_KEY = @"key_live_78801a996de4287481fe73708cc95da2";  //temp
NSString * const TEST_DEVICE_FINGERPRINT_ID = @"94938498586381084";
NSString * const TEST_BROWSER_FINGERPRINT_ID = @"69198153995256641";
NSString * const TEST_IDENTITY_ID = @"95765863201768032";
NSString * const TEST_SESSION_ID = @"97141055400444225";
NSString * const TEST_IDENTITY_LINK = @"https://bnc.lt/i/3N-xr0E-_M";
NSString * const TEST_SHORT_URL = @"https://bnc.lt/l/3PxZVFU-BK";
NSString * const TEST_LOGOUT_IDENTITY_ID = @"98274447349252681";
NSString * const TEST_NEW_IDENTITY_ID = @"85782216939930424";
NSString * const TEST_NEW_SESSION_ID = @"98274447370224207";
NSString * const TEST_NEW_USER_LINK = @"https://bnc.lt/i/2kkbX6k-As";
NSInteger const  TEST_CREDITS = 30;


@interface BranchSDKFunctionalityTests : BNCTestCase <BranchDelegate>
@property (assign, nonatomic) BOOL hasExceededExpectations;

@property (assign, nonatomic) NSInteger notificationOrder;
@property (strong, nonatomic) XCTestExpectation *branchWillOpenURLExpectation;
@property (strong, nonatomic) XCTestExpectation *branchWillOpenURLNotificationExpectation;
@property (strong, nonatomic) XCTestExpectation *branchDidOpenURLExpectation;
@property (strong, nonatomic) XCTestExpectation *branchDidOpenURLNotificationExpectation;
@property (strong, nonatomic) NSDictionary *deepLinkParams;
@end


@implementation BranchSDKFunctionalityTests

- (void)test00OpenOrInstall {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);

    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch.branchKey = @"key_live_foo";
    
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];
    
    BNCServerResponse *openInstallResponse = [[BNCServerResponse alloc] init];
    openInstallResponse.data = @{
        @"browser_fingerprint_id": TEST_BROWSER_FINGERPRINT_ID,
        @"device_fingerprint_id": TEST_DEVICE_FINGERPRINT_ID,
        @"identity_id": TEST_IDENTITY_ID,
        @"link": TEST_IDENTITY_LINK,
        @"session_id": TEST_SESSION_ID
    };
    
    __block BNCServerCallback openOrInstallCallback;
    id openOrInstallCallbackCheckBlock = [OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
        openOrInstallCallback = callback;
        return YES;
    }];
    
    id openOrInstallInvocation = ^(NSInvocation *invocation) {
        openOrInstallCallback(openInstallResponse, nil);
    };

    id openOrInstallUrlCheckBlock = [OCMArg checkWithBlock:^BOOL(NSString *url) {
        return [url rangeOfString:@"open"].location != NSNotFound || [url rangeOfString:@"install"].location != NSNotFound;
    }];
    [[[serverInterfaceMock expect]
        andDo:openOrInstallInvocation]
        postRequest:[OCMArg any]
        url:openOrInstallUrlCheckBlock
        key:[OCMArg any]
        callback:openOrInstallCallbackCheckBlock];
    
    XCTestExpectation *openExpectation = [self expectationWithDescription:@"Test open"];
    [branch initSessionWithLaunchOptions:@{} andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(preferenceHelper.sessionID, TEST_SESSION_ID);
        [openExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:NULL];
}

- (void)test01SetIdentity {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"foo"];
    
    // mock logout synchronously
    preferenceHelper.identityID = @"98274447349252681";
    preferenceHelper.userUrl = @"https://bnc.lt/i/3R7_PIk-77";
    preferenceHelper.userIdentity = nil;
    preferenceHelper.installParams = nil;
    preferenceHelper.sessionParams = nil;
    [preferenceHelper clearUserCreditsAndCounts];
    
    BNCServerResponse *setIdentityResponse = [[BNCServerResponse alloc] init];
    setIdentityResponse.data = @{
        @"identity_id": @"98687515069776101",
        @"link_click_id": @"87925296346431956",
        @"link": @"https://bnc.lt/i/3SawKbU-1Z",
        @"referring_data": @"{\"$og_title\":\"Kindred\",\"key1\":\"test_object\",\"key2\":\"here is another object!!\",\"$og_image_url\":\"https://s3-us-west-1.amazonaws.com/branchhost/mosaic_og.png\",\"source\":\"ios\"}"
    };
    
    // Stub setIdentity server call, call callback immediately.
    __block BNCServerCallback setIdentityCallback;
    [[[serverInterfaceMock expect] andDo:^(NSInvocation *invocation) {
        setIdentityCallback(setIdentityResponse, nil);
    }] postRequest:[OCMArg any] url:[preferenceHelper getAPIURL:@"profile"] key:[OCMArg any] callback:[OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
        setIdentityCallback = callback;
        return YES;
    }]];
    
    XCTestExpectation *setIdentityExpectation = [self expectationWithDescription:@"Test setIdentity"];
    __weak Branch *nonRetainedBranch = branch;
    [branch setIdentity:@"test_user_10" withCallback:^(NSDictionary *params, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(params);
        
        XCTAssertEqualObjects(preferenceHelper.identityID, @"98687515069776101");
        NSDictionary *installParams = [nonRetainedBranch getFirstReferringParams];
        
        XCTAssertEqualObjects(installParams[@"$og_title"], @"Kindred");
        XCTAssertEqualObjects(installParams[@"key1"], @"test_object");
        
        [self safelyFulfillExpectation:setIdentityExpectation];
    }];
    
    [self awaitExpectations];
    [serverInterfaceMock verify];
}

- (void)test02GetShortURLAsync {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];

    BNCServerResponse *fbLinkResponse = [[BNCServerResponse alloc] init];
    fbLinkResponse.statusCode = @200;
    fbLinkResponse.data = @{ @"url": @"https://bnc.lt/l/4BGtJj-03N" };
    
    BNCServerResponse *twLinkResponse = [[BNCServerResponse alloc] init];
    twLinkResponse.statusCode = @200;
    twLinkResponse.data = @{ @"url": @"https://bnc.lt/l/-03N4BGtJj" };
    
    __block BNCServerCallback fbCallback;
    [[[serverInterfaceMock expect]
        andDo:^(NSInvocation *invocation) {
            fbCallback(fbLinkResponse, nil);
        }]
        postRequest:[OCMArg any]
        url:[preferenceHelper getAPIURL:@"url"]
        key:[OCMArg any]
        callback:[OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
            fbCallback = callback;
            return YES;
        }]];
    
    [[serverInterfaceMock reject] postRequestSynchronous:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
        return [params[@"channel"] isEqualToString:@"facebook"];
    }] url:[preferenceHelper getAPIURL:@"url"] key:[OCMArg any]];
    
    [[[serverInterfaceMock expect] andReturn:twLinkResponse] postRequestSynchronous:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
        return [params[@"channel"] isEqualToString:@"twitter"];
    }] url:[preferenceHelper getAPIURL:@"url"] key:[OCMArg any]];
    
    XCTestExpectation *getShortURLExpectation = [self expectationWithDescription:@"Test getShortURL"];
    
    [branch getShortURLWithParams:nil
        andChannel:@"facebook"
        andFeature:nil
        andCallback:^(NSString *url, NSError *error) {
            XCTAssertNil(error);
            XCTAssertNotNil(url);
        
            NSString *returnURL = url;
        
            [branch getShortURLWithParams:nil
                andChannel:@"facebook"
                andFeature:nil
                andCallback:^(NSString *url, NSError *error) {
                    XCTAssertNil(error);
                    XCTAssertNotNil(url);
                    XCTAssertEqualObjects(url, returnURL);
                }];
        
            NSString *urlFB = [branch getShortURLWithParams:nil andChannel:@"facebook" andFeature:nil];
            XCTAssertEqualObjects(urlFB, url);
            
            NSString *urlTT = [branch getShortURLWithParams:nil andChannel:@"twitter" andFeature:nil];
            XCTAssertNotNil(urlTT);
            XCTAssertNotEqualObjects(urlTT, url);
            
            [self safelyFulfillExpectation:getShortURLExpectation];
        }];
    
    [self awaitExpectations];
    [serverInterfaceMock verify];
}

- (void)test03GetShortURLSync {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];

    XCTestExpectation *getShortURLExpectation = [self expectationWithDescription:@"Test getShortURL Sync"];
    [branch initSessionWithLaunchOptions:@{} andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        BNCServerResponse *fbLinkResponse = [[BNCServerResponse alloc] init];
        fbLinkResponse.statusCode = @200;
        fbLinkResponse.data = @{ @"url": @"https://bnc.lt/l/4BGtJj-03N" };
        
        BNCServerResponse *twLinkResponse = [[BNCServerResponse alloc] init];
        twLinkResponse.statusCode = @200;
        twLinkResponse.data = @{ @"url": @"https://bnc.lt/l/-03N4BGtJj" };
        
        // FB should only be called once
        [[[serverInterfaceMock expect] andReturn:fbLinkResponse] postRequestSynchronous:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
            return [params[@"channel"] isEqualToString:@"facebook"];
        }] url:[preferenceHelper getAPIURL:@"url"] key:[OCMArg any]];
        
        [[serverInterfaceMock reject] postRequestSynchronous:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
            return [params[@"channel"] isEqualToString:@"facebook"];
        }] url:[preferenceHelper getAPIURL:@"url"] key:[OCMArg any]];
        
        // TW should be allowed still
        [[[serverInterfaceMock expect] andReturn:twLinkResponse] postRequestSynchronous:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
            return [params[@"channel"] isEqualToString:@"twitter"];
        }] url:[preferenceHelper getAPIURL:@"url"] key:[OCMArg any]];
        
        NSString *url1 = [branch getShortURLWithParams:nil andChannel:@"facebook" andFeature:nil];
        XCTAssertNotNil(url1);
        
        NSString *url2 = [branch getShortURLWithParams:nil andChannel:@"facebook" andFeature:nil];
        XCTAssertEqualObjects(url1, url2);
        
        NSString *url3 = [branch getShortURLWithParams:nil andChannel:@"twitter" andFeature:nil];
        XCTAssertNotNil(url3);
        XCTAssertNotEqualObjects(url1, url3);
        
        [self safelyFulfillExpectation:getShortURLExpectation];
    }];
    
    [self awaitExpectations];
    [serverInterfaceMock verify];
}

- (void)test04GetRewardsChanged {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];

    [preferenceHelper setCreditCount:NSIntegerMax forBucket:@"default"];
    
    BNCServerResponse *loadCreditsResponse = [[BNCServerResponse alloc] init];
    loadCreditsResponse.data = @{ @"default": @(NSIntegerMin) };
    
    __block BNCServerCallback loadCreditsCallback;
    [[[serverInterfaceMock expect] andDo:^(NSInvocation *invocation) {
        loadCreditsCallback(loadCreditsResponse, nil);
    }] getRequest:[OCMArg any] url:[preferenceHelper getAPIURL:[NSString stringWithFormat:@"%@/%@", @"credits", preferenceHelper.identityID]] key:[OCMArg any] callback:[OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
        loadCreditsCallback = callback;
        return YES;
    }]];
    
    XCTestExpectation *getRewardExpectation = [self expectationWithDescription:@"Test getReward"];
    
    [branch loadRewardsWithCallback:^(BOOL changed, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(changed);
        
        [self safelyFulfillExpectation:getRewardExpectation];
    }];
    
    [self awaitExpectations];
}

- (void)test05GetRewardsUnchanged {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];

    [preferenceHelper setCreditCount:1 forBucket:@"default"];
    
    BNCServerResponse *loadRewardsResponse = [[BNCServerResponse alloc] init];
    loadRewardsResponse.data = @{ @"default": @1 };
    
    __block BNCServerCallback loadRewardsCallback;
    [[[serverInterfaceMock expect]
        andDo:^(NSInvocation *invocation) {
            loadRewardsCallback(loadRewardsResponse, nil);
        }]
        getRequest:[OCMArg any]
        url:[preferenceHelper
        getAPIURL:[NSString stringWithFormat:@"%@/%@", @"credits", preferenceHelper.identityID]]
        key:[OCMArg any]
        callback:[OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
            loadRewardsCallback = callback;
            return YES;
    }]];
    
    XCTestExpectation *getRewardExpectation = [self expectationWithDescription:@"Test getReward"];
    
    [branch loadRewardsWithCallback:^(BOOL changed, NSError *error) {
        XCTAssertNil(error);
        XCTAssertFalse(changed);
        
        [self safelyFulfillExpectation:getRewardExpectation];
    }];

    [self awaitExpectations];
}

- (void)test12GetCreditHistory {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];

    [preferenceHelper setCreditCount:1 forBucket:@"default"];
    
    BNCServerResponse *creditHistoryResponse = [[BNCServerResponse alloc] init];
    creditHistoryResponse.data = @[
        [@{
            @"transaction": @{
                @"id": @"112281771218838351",
                @"bucket": @"default",
                @"type": @0,
                @"amount": @5,
                @"date": @"2015-04-02T20:58:06.946Z"
            },
            @"referrer": @"test_user_10",
            @"referree": [NSNull null]
        } mutableCopy]
    ];
    
    __block BNCServerCallback creditHistoryCallback;
    [[[serverInterfaceMock expect]
        andDo:^(NSInvocation *invocation) {
            creditHistoryCallback(creditHistoryResponse, nil);
        }]
        postRequest:[OCMArg any]
        url:[preferenceHelper getAPIURL:@"credithistory"]
        key:[OCMArg any]
        callback:[OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
            creditHistoryCallback = callback;
            return YES;
        }]];
    
    XCTestExpectation *getCreditHistoryExpectation =
        [self expectationWithDescription:@"Test getCreditHistory"];
    [branch getCreditHistoryWithCallback:^(NSArray *list, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(list);
        XCTAssertGreaterThan(list.count, 0);
        
        [self safelyFulfillExpectation:getCreditHistoryExpectation];
    }];
    
    [self awaitExpectations];
}

// Test scenario
// * Initialize the session
// * Get a short url.
// * Log out.
// * Get the same url:  should be the same.
- (void)test13GetShortURLAfterLogout {
    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [self setupDefaultStubsForServerInterfaceMock:serverInterfaceMock];

    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch *branch =
		[[Branch alloc]
			initWithInterface:serverInterfaceMock
			queue:[[BNCServerRequestQueue alloc] init]
			cache:[[BNCLinkCache alloc] init]
			preferenceHelper:preferenceHelper
			key:@"key_live_foo"];

    // Init session

    XCTestExpectation *initSessionExpectation =
        [self expectationWithDescription:@"Expect Session"];
    
    [branch initSessionWithLaunchOptions:@{}
              andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
                XCTAssert(!error);
                NSLog(@"Fullfilled 1.");
                [self safelyFulfillExpectation:initSessionExpectation];
              }];

    [self awaitExpectations];

    // Get short URL

    NSString * urlTruthString = @"https://bnc.lt/l/4BGtJj-03N";
    BNCServerResponse *urlResp = [[BNCServerResponse alloc] init];
    urlResp.statusCode = @200;
    urlResp.data = @{ @"url": urlTruthString };

    [[[serverInterfaceMock expect]
        andReturn:urlResp]
            postRequestSynchronous:[OCMArg any]
            url:[preferenceHelper getAPIURL:@"url"]
            key:[OCMArg any]];

    NSString *url1 = [branch getShortURLWithParams:nil andChannel:nil andFeature:nil];
    XCTAssertEqual(urlTruthString, url1);

    // Log out

    BNCServerResponse *logoutResp = [[BNCServerResponse alloc] init];
    logoutResp.data = @{ @"session_id": @"foo", @"identity_id": @"foo", @"link": @"http://foo" };

    __block BNCServerCallback logoutCallback;
    [[[serverInterfaceMock expect]
        andDo:^(NSInvocation *invocation) {
            logoutCallback(logoutResp, nil);
        }]
            postRequest:[OCMArg any]
            url:[preferenceHelper
            getAPIURL:@"logout"]
            key:[OCMArg any]
            callback:[OCMArg
            checkWithBlock:^BOOL(BNCServerCallback callback) {
                logoutCallback = callback;
                return YES;
            }]];

    XCTestExpectation *logoutExpectation =
        [self expectationWithDescription:@"Logout Session"];

    [branch logoutWithCallback:^(BOOL changed, NSError * _Nullable error) {
        XCTAssertNil(error);
        NSLog(@"Fullfilled 2.");
        [self safelyFulfillExpectation:logoutExpectation];
    }];

    self.hasExceededExpectations = NO;
    [self awaitExpectations];

    // Get short URL

    [[[serverInterfaceMock expect]
        andReturn:urlResp]
            postRequestSynchronous:[OCMArg any]
            url:[preferenceHelper getAPIURL:@"url"]
            key:[OCMArg any]];

    NSString *url2 = [branch getShortURLWithParams:nil andChannel:nil andFeature:nil];
    XCTAssertEqualObjects(url1, url2);
}

// Test that Branch notifications work.
// Test that they 1) work and 2) are sent in the right order.
- (void) testNotifications {

    self.notificationOrder = 0;
    self.branchWillOpenURLExpectation =
        [self expectationWithDescription:@"branchWillOpenURLExpectation"];
    self.branchWillOpenURLNotificationExpectation =
        [self expectationWithDescription:@"branchWillOpenURLNotificationExpectation"];
    self.branchDidOpenURLExpectation =
        [self expectationWithDescription:@"branchDidOpenURLExpectation"];
    self.branchDidOpenURLNotificationExpectation =
        [self expectationWithDescription:@"branchDidOpenURLNotificationExpectation"];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(branchWillStartSessionNotification:)
        name:BranchWillStartSessionNotification
        object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(branchDidStartSessionNotification:)
        name:BranchDidStartSessionNotification
        object:nil];

    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);

    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    Branch.branchKey = @"key_live_foo";
    
    Branch *branch =
        [[Branch alloc]
            initWithInterface:serverInterfaceMock
            queue:[[BNCServerRequestQueue alloc] init]
            cache:[[BNCLinkCache alloc] init]
            preferenceHelper:preferenceHelper
            key:@"key_live_foo"];
    branch.delegate = self;

    BNCServerResponse *openInstallResponse = [[BNCServerResponse alloc] init];
    openInstallResponse.data = @{
        @"data": @"{\"$og_title\":\"Content Title\",\"$identity_id\":\"423237095633725879\",\"~feature\":\"Sharing Feature\",\"$desktop_url\":\"http://branch.io\",\"$canonical_identifier\":\"item/12345\",\"~id\":423243086454504450,\"~campaign\":\"some campaign\",\"+is_first_session\":false,\"~channel\":\"Distribution Channel\",\"$ios_url\":\"https://dev.branch.io/getting-started/sdk-integration-guide/guide/ios/\",\"$exp_date\":0,\"$currency\":\"$\",\"$publicly_indexable\":1,\"$content_type\":\"some type\",\"~creation_source\":3,\"$amount\":1000,\"$og_description\":\"My Content Description\",\"+click_timestamp\":1506983962,\"$og_image_url\":\"https://pbs.twimg.com/profile_images/658759610220703744/IO1HUADP.png\",\"+match_guaranteed\":true,\"+clicked_branch_link\":true,\"deeplink_text\":\"This text was embedded as data in a Branch link with the following characteristics:\\n\\ncanonicalUrl: https://dev.branch.io/getting-started/deep-link-routing/guide/ios/\\n  title: Content Title\\n  contentDescription: My Content Description\\n  imageUrl: https://pbs.twimg.com/profile_images/658759610220703744/IO1HUADP.png\\n\",\"$one_time_use\":false,\"$canonical_url\":\"https://dev.branch.io/getting-started/deep-link-routing/guide/ios/\",\"~referring_link\":\"https://bnctestbed.app.link/izPBY2xCqF\"}",
        @"device_fingerprint_id": @"439892172783867901",
        @"identity_id": @"439892172804841307",
        @"link": @"https://bnctestbed.app.link?%24identity_id=439892172804841307",
        @"session_id": @"443529761084512316",
    };

    __block BNCServerCallback openOrInstallCallback;
    id openOrInstallCallbackCheckBlock = [OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
        openOrInstallCallback = callback;
        return YES;
    }];
    
    id openOrInstallInvocation = ^(NSInvocation *invocation) {
        openOrInstallCallback(openInstallResponse, nil);
    };

    id openOrInstallUrlCheckBlock = [OCMArg checkWithBlock:^BOOL(NSString *url) {
        return [url rangeOfString:@"open"].location != NSNotFound ||
               [url rangeOfString:@"install"].location != NSNotFound;
    }];
    [[[serverInterfaceMock expect]
        andDo:openOrInstallInvocation]
        postRequest:[OCMArg any]
        url:openOrInstallUrlCheckBlock
        key:[OCMArg any]
        callback:openOrInstallCallbackCheckBlock];

    XCTestExpectation *openExpectation = [self expectationWithDescription:@"Test open"];
    [branch initSessionWithLaunchOptions:@{}
        andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            // Callback block. Order: 2.
            XCTAssertNil(error);
            XCTAssertEqualObjects(preferenceHelper.sessionID, @"443529761084512316");
            XCTAssertTrue(self.notificationOrder == 2);
            self.notificationOrder++;
            self.deepLinkParams = params;
            [openExpectation fulfill];
        }
    ];
    
    [self waitForExpectationsWithTimeout:5.0 handler:NULL];
    XCTAssertTrue(self.notificationOrder == 5);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Delegate method. Order: 0.
- (void) branch:(Branch*)branch willStartSessionWithURL:(NSURL*)url {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertTrue(self.notificationOrder == 0);
    self.notificationOrder++;
    [self.branchWillOpenURLExpectation fulfill];
}

// Notification method. Order: 1.
- (void) branchWillStartSessionNotification:(NSNotification*)notification {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertTrue(self.notificationOrder == 1);
    self.notificationOrder++;

    NSError *error = notification.userInfo[BranchErrorKey];
    XCTAssertNil(error);

    NSURL *URL = notification.userInfo[BranchURLKey];
    XCTAssertNil(URL);

    BranchUniversalObject *object = notification.userInfo[BranchUniversalObjectKey];
    XCTAssertNil(object);

    BranchLinkProperties *properties = notification.userInfo[BranchLinkPropertiesKey];
    XCTAssertNil(properties);

    [self.branchWillOpenURLNotificationExpectation fulfill];
}

// Delegate method. Order: 3.
- (void) branch:(Branch*)branch
didStartSessionWithURL:(NSURL*)url
     branchLink:(BranchLink*)branchLink {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertTrue(self.notificationOrder == 3);
    self.notificationOrder++;
    XCTAssertNotNil(branchLink.universalObject);
    XCTAssertNotNil(branchLink.linkProperties);
    [self.branchDidOpenURLExpectation fulfill];
}

// Delegate method. Order: Not called.
- (void) branch:(Branch*)branch
     didOpenURL:(NSURL*)url
      withError:(NSError*)error {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertTrue(self.notificationOrder == 3);
    self.notificationOrder++;
    XCTAssertNotNil(error);
    [NSException raise:NSInternalInconsistencyException format:@"Shouldn't return an error here."];
    [self.branchDidOpenURLExpectation fulfill];
}

// Notification method. Order: 4
- (void) branchDidStartSessionNotification:(NSNotification*)notification {
    XCTAssertTrue([NSThread isMainThread]);
    XCTAssertTrue(self.notificationOrder == 4);
    self.notificationOrder++;

    NSError *error = notification.userInfo[BranchErrorKey];
    XCTAssertNil(error);

    NSURL *URL = notification.userInfo[BranchURLKey];
    XCTAssertNotNil(URL);

    BranchUniversalObject *object = notification.userInfo[BranchUniversalObjectKey];
    XCTAssertNotNil(object);

    BranchLinkProperties *properties = notification.userInfo[BranchLinkPropertiesKey];
    XCTAssertNotNil(object);

    NSDictionary *d = [object getDictionaryWithCompleteLinkProperties:properties];
    NSMutableDictionary *truth = [NSMutableDictionary dictionaryWithDictionary:self.deepLinkParams];
    truth[@"~duration"] = @(0);         // ~duration not added because zero value?
    truth[@"$locally_indexable"] = @(0);
    XCTAssertTrue(d.count == truth.count);
    XCTAssertTrue(!d || [d isEqualToDictionary:truth]);

    [self.branchDidOpenURLNotificationExpectation fulfill];
}

#pragma mark - Test Utility

- (void)safelyFulfillExpectation:(XCTestExpectation *)expectation {
    if (!self.hasExceededExpectations) {
        [expectation fulfill];
    }
}

- (void)awaitExpectations {
    [self waitForExpectationsWithTimeout:6.0 handler:^(NSError *error) {
        self.hasExceededExpectations = YES;
    }];
}

- (void)setupDefaultStubsForServerInterfaceMock:(id)serverInterfaceMock {
    BNCServerResponse *openInstallResponse = [[BNCServerResponse alloc] init];
    openInstallResponse.data = @{
        @"session_id": TEST_SESSION_ID,
        @"identity_id": TEST_IDENTITY_ID,
        @"device_fingerprint_id": TEST_DEVICE_FINGERPRINT_ID,
        @"browser_fingerprint_id": TEST_BROWSER_FINGERPRINT_ID,
        @"link": TEST_IDENTITY_LINK,
        @"new_identity_id": TEST_NEW_IDENTITY_ID
    };
    
    // Stub open / install
    __block BNCServerCallback openOrInstallCallback;
    id openOrInstallCallbackCheckBlock = [OCMArg checkWithBlock:^BOOL(BNCServerCallback callback) {
        openOrInstallCallback = callback;
        return YES;
    }];
    
    id openOrInstallInvocation = ^(NSInvocation *invocation) {
        openOrInstallCallback(openInstallResponse, nil);
    };
    
    id openOrInstallUrlCheckBlock = [OCMArg checkWithBlock:^BOOL(NSString *url) {
        return [url rangeOfString:@"open"].location != NSNotFound ||
               [url rangeOfString:@"install"].location != NSNotFound;
    }];
    [[[serverInterfaceMock expect]
        andDo:openOrInstallInvocation]
        postRequest:[OCMArg any]
        url:openOrInstallUrlCheckBlock
        key:[OCMArg any]
        callback:openOrInstallCallbackCheckBlock];
}

@end

