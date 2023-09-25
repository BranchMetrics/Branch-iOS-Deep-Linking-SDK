//
//  BNCServerAPI.m
//  BranchSDK
//
//  Created by Nidhi Dixit on 8/29/23.
//

#import "BNCServerAPI.h"
#import "BNCPreferenceHelper.h"
#import "BNCSystemObserver.h"
#import "BNCConfig.h"
#import "BranchConstants.h"

@implementation BNCServerAPI

+ (BNCServerAPI *)sharedInstance {
    static BNCServerAPI *serverAPI;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        serverAPI = [[BNCServerAPI alloc] init];
    });
    
    return serverAPI;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.useTrackingDomain = NO;
        self.useEUServers = NO;
        self.automaticallyEnableTrackingDomain = YES;
    }
    return self;
}

- (NSString *)installServiceURL{
    return [[self getBaseURL] stringByAppendingString: @"/v1/install"];
}

- (NSString *)openServiceURL {
    return [[self getBaseURL] stringByAppendingString: @"/v1/open"];
}

- (NSString *)standardEventServiceURL{
    return [[self getBaseURL] stringByAppendingString: @"/v2/event/standard"];
}

- (NSString *)customEventServiceURL{
    return [[self getBaseURL] stringByAppendingString: @"/v2/event/custom"];
}

- (NSString *)linkServiceURL {
    return [[self getBaseURLForLinkingEndpoints] stringByAppendingString: @"/v1/url"];
}

// Currently we switch to tracking domains if we detect IDFA, indicating that Ad Tracking is enabled
- (BOOL)optedIntoIDFA {
    NSString* optedInStatus = [BNCSystemObserver attOptedInStatus];
    if ([optedInStatus isEqualToString:@"authorized"]){
        return TRUE;
    }
    return FALSE;
}

// Linking endpoints are not used for Ads tracking
- (NSString *)getBaseURLForLinkingEndpoints {
    NSString * urlString;
    if (self.useEUServers){
        urlString = BNC_EU_API_URL;
    } else {
        urlString = BNC_API_URL;
    }
    
    return urlString;
}

- (NSString *)getBaseURL {
    if (self.automaticallyEnableTrackingDomain) {
        self.useTrackingDomain = [self optedIntoIDFA];
    }
    
    NSString * urlString;
    
    if (self.useTrackingDomain && self.useEUServers){
        urlString = BNC_SAFETRACK_EU_API_URL;
    } else if (self.useTrackingDomain) {
        urlString = BNC_SAFETRACK_API_URL;
    } else if (self.useEUServers){
        urlString = BNC_EU_API_URL;
    } else {
        urlString = BNC_API_URL;
    }
    
    return urlString;
}

@end
