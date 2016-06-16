//
//  SDWebServiceValidateDeprecatedMockProviderTests.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 11/10/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SDWebService.h"
#import "SDWebServiceMockResponseProvider.h"
#import "SDWebServiceMockResponseQueueProvider.h"

@interface SDWebService(testHelper)
- (SDWebServiceMockResponseQueueProvider *)checkForMockResponseQueueProvider;
@end

@interface TestSDWebServiceB : SDWebService
@property (nonatomic,assign) NSInteger callCount_checkForMockResponseQueueProvider;
@end
@implementation TestSDWebServiceB
- (SDWebServiceMockResponseQueueProvider *)checkForMockResponseQueueProvider
{
    self.callCount_checkForMockResponseQueueProvider += 1;
    return [super checkForMockResponseQueueProvider];
}
@end

@interface SDWebServiceValidateDeprecatedMockProviderTests : XCTestCase
@property (nonatomic,strong) TestSDWebServiceB *webService;
@property (nonatomic,strong) NSBundle *bundle;
@end

@implementation SDWebServiceValidateDeprecatedMockProviderTests

- (void)setUp
{
    [super setUp];

    self.bundle = [NSBundle bundleForClass:[self class]];

    self.webService = [[TestSDWebServiceB alloc] initWithSpecification:@"SDWebServiceMockTests"];
}

- (void)testCheckForMockResponseQueueProvider;
{
    id result = [self.webService checkForMockResponseQueueProvider];
    XCTAssertTrue([result isKindOfClass:[SDWebServiceMockResponseQueueProvider class]]);
}

- (void)testCallAutoPopMocksGetter
{
    XCTAssertTrue(self.webService.autoPopMocks);
    XCTAssertTrue(self.webService.callCount_checkForMockResponseQueueProvider > 0);
}

- (void)testCallAutoPopMocksSetter
{
    self.webService.autoPopMocks = NO;
    XCTAssertTrue(self.webService.callCount_checkForMockResponseQueueProvider > 0);
}

- (void)testCallPushMockResponseFile
{
    [self.webService pushMockResponseFile:@"SDWebServiceMockTest_bundleA.json" bundle:self.bundle];
    XCTAssertTrue(self.webService.callCount_checkForMockResponseQueueProvider > 0);
}

- (void)testCallPushMockResponseFiles
{
    [self.webService pushMockResponseFiles:@[@"SDWebServiceMockTest_bundleA.json"] bundle:self.bundle];
    XCTAssertTrue(self.webService.callCount_checkForMockResponseQueueProvider > 0);
}

- (void)testCallPopMockResponseFile
{
    [self.webService popMockResponseFile];
    XCTAssertTrue(self.webService.callCount_checkForMockResponseQueueProvider > 0);
}

@end
