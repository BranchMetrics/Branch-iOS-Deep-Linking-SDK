//
//  BNCAvailability.h
//  Branch-SDK
//
//  Created by Edward on 10/26/16.
//  Copyright © 2016 Branch Metrics. All rights reserved.
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
#warning Warning: Compiling with iOS 9 / Xcode 7 support.

@interface NSLocale (BranchAvailability)
- (NSString*) countryCode;
- (NSString*) languageCode;
@end

typedef NSString * UIActivityType;
typedef NSString * UIApplicationOpenURLOptionsKey;

#endif

#ifndef NS_STRING_ENUM
#define NS_STRING_ENUM
#endif

#ifndef CSSearchableItemActionType
#define CSSearchableItemActionType @"com.apple.corespotlightitem"
#endif

#ifndef CSSearchableItemActivityIdentifier
#define CSSearchableItemActivityIdentifier @"kCSSearchableItemActivityIdentifier"
#endif
