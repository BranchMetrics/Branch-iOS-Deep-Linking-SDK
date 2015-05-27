//
//  BranchShortUrlRequest.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 5/26/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BranchShortUrlRequest.h"
#import "BNCPreferenceHelper.h"
#import "BNCEncodingUtils.h"

@interface BranchShortUrlRequest ()

@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) NSString *alias;
@property (assign, nonatomic) BranchLinkType type;
@property (assign, nonatomic) NSInteger matchDuration;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *feature;
@property (strong, nonatomic) NSString *stage;
@property (strong, nonatomic) NSDictionary *params;
@property (strong, nonatomic) BNCLinkCache *linkCache;
@property (strong, nonatomic) BNCLinkData *linkData;
@property (strong, nonatomic) callbackWithUrl callback;

@end

@implementation BranchShortUrlRequest

- (id)initWithTags:(NSArray *)tags alias:(NSString *)alias type:(BranchLinkType)type matchDuration:(NSInteger)duration channel:(NSString *)channel feature:(NSString *)feature stage:(NSString *)stage params:(NSDictionary *)params linkData:(BNCLinkData *)linkData linkCache:(BNCLinkCache *)linkCache callback:(callbackWithUrl)callback {
    if (self = [super init]) {
        _tags = tags;
        _alias = alias;
        _type = type;
        _matchDuration = duration;
        _channel = channel;
        _feature = feature;
        _stage = stage;
        _params = params;
        _callback = callback;
        _linkCache = linkCache;
        _linkData = linkData;
    }
    
    return self;
}

- (void)makeRequest:(BNCServerInterface *)serverInterface key:(NSString *)key callback:(BNCServerCallback)callback {
    [serverInterface postRequest:self.linkData.data url:[BNCPreferenceHelper getAPIURL:@"url"] key:key callback:callback];
}

- (void)processResponse:(BNCServerResponse *)response error:(NSError *)error {
    if (error) {
        if (self.callback) {
            NSString *failedUrl = nil;
            NSString *userUrl = [BNCPreferenceHelper getUserURL];
            if (![userUrl isEqualToString:NO_STRING_VALUE]) {
                failedUrl = [self createLongUrlForUserUrl:userUrl];
            }
            
            self.callback(failedUrl, error);
        }
        
        return;
    }
    
    NSString *url = response.data[@"url"];
    
    // cache the link
    if (url) {
        [self.linkCache setObject:url forKey:self.linkData];
    }
    
    if (self.callback) {
        self.callback(url, nil);
    }
}

- (NSString *)createLongUrlForUserUrl:(NSString *)userUrl {
    NSMutableString *longUrl = [[NSMutableString alloc] initWithFormat:@"%@?", userUrl];
    
    for (NSString *tag in self.tags) {
        [longUrl appendFormat:@"tags=%@&", tag];
    }
    
    if ([self.alias length]) {
        [longUrl appendFormat:@"alias=%@&", self.alias];
    }
    
    if ([self.channel length]) {
        [longUrl appendFormat:@"channel=%@&", self.channel];
    }
    
    if ([self.feature length]) {
        [longUrl appendFormat:@"feature=%@&", self.feature];
    }
    
    if ([self.stage length]) {
        [longUrl appendFormat:@"stage=%@&", self.stage];
    }
    
    [longUrl appendFormat:@"type=%ld&", (long)self.type];
    [longUrl appendFormat:@"matchDuration=%ld&", (long)self.matchDuration];
    
    NSData *jsonData = [BNCEncodingUtils encodeDictionaryToJsonData:self.params];
    NSString *base64EncodedParams = [BNCEncodingUtils base64EncodeData:jsonData];
    [longUrl appendFormat:@"data=%@", base64EncodedParams];
    
    return longUrl;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _tags = [decoder decodeObjectForKey:@"tags"];
        _alias = [decoder decodeObjectForKey:@"alias"];
        _type = [decoder decodeIntegerForKey:@"type"];
        _matchDuration = [decoder decodeIntegerForKey:@"duration"];
        _channel = [decoder decodeObjectForKey:@"channel"];
        _feature = [decoder decodeObjectForKey:@"feature"];
        _stage = [decoder decodeObjectForKey:@"stage"];
        _params = [BNCEncodingUtils decodeJsonStringToDictionary:[decoder decodeObjectForKey:@"params"]];
        
        // Set up link data
        self.linkData = [[BNCLinkData alloc] init];
        [self.linkData setObject:[BNCPreferenceHelper getDeviceFingerprintID] forKey:@"device_fingerprint_id"];
        [self.linkData setObject:[BNCPreferenceHelper getIdentityID] forKey:@"identity_id"];
        [self.linkData setObject:[BNCPreferenceHelper getSessionID] forKey:@"session_id"];
        [self.linkData setupType:_type];
        [self.linkData setupTags:_tags];
        [self.linkData setupChannel:_channel];
        [self.linkData setupFeature:_feature];
        [self.linkData setupStage:_stage];
        [self.linkData setupAlias:_alias];
        [self.linkData setupMatchDuration:_matchDuration];
        [self.linkData setupParams:[BNCEncodingUtils encodeDictionaryToJsonString:_params]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.alias forKey:@"alias"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeInteger:self.matchDuration forKey:@"duration"];
    [coder encodeObject:self.channel forKey:@"channel"];
    [coder encodeObject:self.feature forKey:@"feature"];
    [coder encodeObject:self.stage forKey:@"stage"];
    [coder encodeObject:[BNCEncodingUtils encodeDictionaryToJsonString:self.params needSource:NO] forKey:@"params"];
}

@end
