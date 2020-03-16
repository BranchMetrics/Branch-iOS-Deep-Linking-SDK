//
//  BNCCallbackMapTests.m
//  Branch-SDK-Tests
//
//  Created by Ernest Cho on 2/25/20.
//  Copyright © 2020 Branch, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BNCCallbackMap.h"

// expose private storage object for state checks
@interface BNCCallbackMap()
@property (nonatomic, strong, readwrite) NSMapTable *callbacks;
@end

@interface BNCCallbackMapTests : XCTestCase

@end

@implementation BNCCallbackMapTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSingleSave {
    BNCCallbackMap *map = [BNCCallbackMap new];
    
    // block variable callback will update
    __block BOOL successResult = NO;
    __block NSString *statusMessageResult = @"no callback";
    
    // store a request and callback block
    BNCServerRequest *request = [BNCServerRequest new];
    [map storeRequest:request withCompletion:^(BOOL success, NSString * _Nonnull statusMessage) {
        successResult = success;
        statusMessageResult = statusMessage;
    }];
    
    // confirm there's one entry
    XCTAssert([map containsRequest:request] != NO);
    XCTAssert(map.callbacks.count == 1);
    
    // call callback
    [map callCompletionForRequest:request withSuccessStatus:YES message:@"callback"];
    
    // check if variable was updated
    XCTAssertTrue(successResult);
    XCTAssert([@"callback" isEqualToString:statusMessageResult]);
}

- (void)testDeletedRequest {
    BNCCallbackMap *map = [BNCCallbackMap new];
    
    // block variable callback will update
    __block BOOL successResult = NO;
    __block NSString *statusMessageResult = @"no callback";
    
    // store a request and callback block
    BNCServerRequest *request = [BNCServerRequest new];
    [map storeRequest:request withCompletion:^(BOOL success, NSString * _Nonnull statusMessage) {
        successResult = success;
        statusMessageResult = statusMessage;
    }];
    
    // confirm there's one entry
    XCTAssert([map containsRequest:request] != NO);
    XCTAssert(map.callbacks.count == 1);
    
    // confirm a new request results in no callback
    request = [BNCServerRequest new];
    XCTAssert([map containsRequest:request] == NO);
    [map callCompletionForRequest:request withSuccessStatus:YES message:@"callback"];
    
    // check if variable was updated
    XCTAssertFalse(successResult);
    XCTAssert([@"no callback" isEqualToString:statusMessageResult]);
}

- (void)testSeveralBlocks {
    BNCCallbackMap *map = [BNCCallbackMap new];

    __block int count = 0;
    
    BNCServerRequest *request = [BNCServerRequest new];
    [map storeRequest:request withCompletion:^(BOOL success, NSString * _Nonnull statusMessage) {
        count++;
    }];
    
    for (int i=0; i<100; i++) {
        BNCServerRequest *tmp = [BNCServerRequest new];
        [map storeRequest:tmp withCompletion:^(BOOL success, NSString * _Nonnull statusMessage) {
             count++;
        }];
    }
    
    // confirm there's less than 100 entries.  By not retaining the tmp request, they should be getting ARC'd
    XCTAssert(map.callbacks.count < 100);
    
    [map callCompletionForRequest:request withSuccessStatus:YES message:@"callback"];
    XCTAssert(count == 1);
}

@end
