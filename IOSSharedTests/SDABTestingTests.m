//
//  SDABTestingTests.m
//  ios-shared
//
//  Created by Brandon Sneed on 8/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDABTesting.h"

@interface SDABTesting (Private)
+ (instancetype)sharedInstance;
- (BOOL)boolForDefaultsKey:(NSString *)keyName;
- (void)setBool:(BOOL)value forDefaultsKey:(NSString *)keyName;
@end

@interface SDABTestingTests : XCTestCase

@end

@implementation SDABTestingTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    // remove the userdefaults key that we'll be storing under.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SDABTesting"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

// TODO: This is crashing (and hence failing the test). the private methods are
//       not implemented anywhere that I can find. That crashes with an unrecognized selector.
//
//- (void)testStorage
//{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);

//    [[SDABTesting sharedInstance] setBool:YES forDefaultsKey:@"testKey"];
//    BOOL value = [[SDABTesting sharedInstance] boolForDefaultsKey:@"testKey"];
//
//    XCTAssertTrue(value, @"value is not true, your default did not get written!");
//}

@end
