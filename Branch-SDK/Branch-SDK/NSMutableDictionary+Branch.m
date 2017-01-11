//
//  NSMutableDictionary+Branch.m
//  Branch
//
//  Created by Edward Smith on 1/11/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//


#import "NSMutableDictionary+Branch.h"


@implementation NSMutableDictionary (Branch)

- (void) bnc_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
	if (anObject) {
		[self setObject:anObject forKey:aKey];
	}
}

@end
