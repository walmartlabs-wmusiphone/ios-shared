//
//  NSObject+SDExtensionsTests.m
//  ios-shared
//
//  Created by Brandon Sneed on 7/10/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+SDExtensions.h"

@interface NSObject_SDExtensionsTests : XCTestCase

@end

@implementation NSObject_SDExtensionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAsyncWaitMainThread {
    
    __block BOOL slept = NO;
    __block BOOL completed = NO;
    [self performBlockInBackground:^{
        sleep(5);
        slept = YES;
    } completion:^{
        [self completeAsynchronousTask];
        completed = YES;
    }];
    
    [self waitForAsynchronousTask];
    XCTAssertTrue(slept, "The async task was supposed to sleep for 5 seconds, and it didn't!");
    XCTAssertTrue(completed, "The async task was supposed to complete, and it didn't!");
}

- (void)testAsyncWaitBackgroundThread {
    
    __block BOOL slept = NO;
    __block BOOL completed = NO;
    [self performBlockInBackground:^{
        sleep(5);
        slept = YES;
        [self completeAsynchronousTask];
    } completion:^{
        completed = YES;
    }];
    
    [self waitForAsynchronousTask];
    XCTAssertTrue(slept, "The async task was supposed to sleep for 5 seconds, and it didn't!");
    XCTAssertTrue(!completed, "The async task wasn't supposed to reach the completion block, and it did!");
}

@end
