//
//  ContentDiscoverer.h
//  Branch-TestBed
//
//  Created by Sojan P.R. on 8/17/16.
//  Copyright © 2016 Branch Metrics. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ContentDiscoveryManifest.h"

#ifndef ContentDiscoverer_h
#define ContentDiscoverer_h


#endif /* ContentDiscoverer_h */

@interface ContentDiscoverer : NSObject
+ (ContentDiscoverer *)getInstance:(ContentDiscoveryManifest *)manifest;
- (void) startContentDiscoveryTask;
+ (ContentDiscoverer *)getInstance;
- (void) stopContentDiscoveryTask;

@end
