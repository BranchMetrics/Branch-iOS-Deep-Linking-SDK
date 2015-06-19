//
//  BranchApplyPromoCodeRequest.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 5/26/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BranchApplyPromoCodeRequest.h"
#import "BNCPreferenceHelper.h"
#import "BNCError.h"
#import "BranchConstants.h"

@interface BranchApplyPromoCodeRequest ()

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) callbackWithParams callback;
@property (assign, nonatomic) BOOL useOld;

@end

@implementation BranchApplyPromoCodeRequest

- (id)initWithCode:(NSString *)code useOld:(BOOL)useOld callback:(callbackWithParams)callback {
    if (self = [super init]) {
        _code = code;
        _callback = callback;
        _useOld = useOld;
    }
    
    return self;
}

- (void)makeRequest:(BNCServerInterface *)serverInterface key:(NSString *)key callback:(BNCServerCallback)callback {
    NSDictionary *params = @{
        BRANCH_REQUEST_KEY_BRANCH_IDENTITY: [BNCPreferenceHelper getIdentityID],
        BRANCH_REQUEST_KEY_DEVICE_FINGERPRINT_ID: [BNCPreferenceHelper getDeviceFingerprintID],
        BRANCH_REQUEST_KEY_SESSION_ID: [BNCPreferenceHelper getSessionID]
    };
    
    NSString *endpoint = self.useOld ? @"applycode/" : @"apply-promo-code/";
    NSString *url = [[BNCPreferenceHelper getAPIURL:endpoint] stringByAppendingString:self.code];
    [serverInterface postRequest:params url:url key:key callback:callback];
}

- (void)processResponse:(BNCServerResponse *)response error:(NSError *)error {
    if (error) {
        if (self.callback) {
            self.callback(nil, error);
        }
        return;
    }

    NSString *codeKey = self.useOld ? BRANCH_RESPONSE_KEY_REFERRAL_CODE : BRANCH_RESPONSE_KEY_PROMO_CODE;
    if (!response.data[codeKey]) {
        error = [NSError errorWithDomain:BNCErrorDomain code:BNCInvalidPromoCodeError userInfo:@{ NSLocalizedDescriptionKey: @"Promo code is invalid - it may have already been used or the code might not exist" }];
    }
    
    if (self.callback) {
        self.callback(response.data, error);
    }
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _code = [decoder decodeObjectForKey:@"code"];
        _useOld = [decoder decodeBoolForKey:@"useOld"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.code forKey:@"code"];
    [coder encodeBool:self.useOld forKey:@"useOld"];
}

@end
