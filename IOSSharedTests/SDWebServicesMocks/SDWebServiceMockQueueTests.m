//
//  SDWebServiceMockQueueTests.m
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

@interface TestSDWebServiceA : SDWebService
@property (nonatomic,weak) XCTestCase *testCase;
@end
@implementation TestSDWebServiceA
- (SDWebServiceMockResponseQueueProvider *)checkForMockResponseQueueProvider
{
    _XCTPrimitiveFail(self.testCase, @"Should not call checkForMockResponseQueueProvider (methods in SDWebService are deprecated, use methods on mockResponseProvider instance directly");
    return nil;
}
@end

@interface SDWebServiceMockQueueTests : XCTestCase
@property (nonatomic,strong) TestSDWebServiceA *webService;
@property (nonatomic,strong) SDWebServiceMockResponseQueueProvider *mockResponseQueueProvider;
@property (nonatomic,strong) NSBundle *bundle;
@end

@implementation SDWebServiceMockQueueTests

- (void)setUp
{
    [super setUp];

    self.bundle = [NSBundle bundleForClass:[self class]];

    self.webService = [[TestSDWebServiceA alloc] initWithSpecification:@"SDWebServiceMockTests"];
    self.webService.testCase = self;
    self.webService.maxConcurrentOperationCount = 1; // to ensure predictable testing

    self.mockResponseQueueProvider = [[SDWebServiceMockResponseQueueProvider alloc] init];
    self.webService.mockResponseProvider = self.mockResponseQueueProvider;
}

#pragma mark - pragma helper methods

- (void) checkWebServiceWithBlock:(void (^)(NSData *responseData, NSError *error)) block
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"webService request completed"];
    [self.webService performRequestWithMethod:@"testGETNoRouteParams"
                                      headers:nil
                            routeReplacements:nil
                          dataProcessingBlock:^id(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
                              block(responseData, error);
                              [expectation fulfill];
                              return nil;
                          } uiUpdateBlock:nil];
}

- (NSData *) pushMockResponseWithFilename:(NSString *) filename
{
    [self.mockResponseQueueProvider pushMockResponseFile:filename bundle:self.bundle];
    NSString *filepath = [self.bundle pathForResource:filename ofType:nil];
    return [NSData dataWithContentsOfFile:filepath];
}

- (NSArray *) pushMockResponsesWithFilenames:(NSArray *) filenames
{
    [self.mockResponseQueueProvider pushMockResponseFiles:filenames bundle:self.bundle];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:[filenames count]];
    for (NSString *filename in filenames)
    {
        NSString *filepath = [self.bundle pathForResource:filename ofType:nil];
        [dataArray addObject:[NSData dataWithContentsOfFile:filepath]];
    }
    return [dataArray copy];
}

#pragma mark - miscellaneous tests

- (void)testDefaultAutoPop
{
    XCTAssertTrue(self.mockResponseQueueProvider.autoPopMocks);
}

#pragma mark - single response tests

- (void)testSingleMockResponseWithAutoPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from any mock response");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSingleMockResponseWithNoAutoPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];

    self.mockResponseQueueProvider.autoPopMocks = NO;

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testSingleMockResponseWithManualPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];

    self.mockResponseQueueProvider.autoPopMocks = NO;

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self.mockResponseQueueProvider popMockResponseFile];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from any mock response");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - multiple response tests

- (void)testMultipleMockResponseWithAutoPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];
    NSData *checkDataB = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleB.json"];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataB, responseData, @"mock should supply data from mock response B pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from any mock response");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testMultipleMockResponseWithNoAutoPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];

    self.mockResponseQueueProvider.autoPopMocks = NO;

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testMultipleMockResponseWithManualPop
{
    NSData *checkDataA = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleA.json"];
    NSData *checkDataB = [self pushMockResponseWithFilename:@"SDWebServiceMockTest_bundleB.json"];

    self.mockResponseQueueProvider.autoPopMocks = NO;

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataA, responseData, @"mock should supply data from mock response A pushed above");
    }];

    [self.mockResponseQueueProvider popMockResponseFile];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataB, responseData, @"mock should supply data from mock response B pushed above");
    }];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqualObjects(checkDataB, responseData, @"mock should supply data from mock response B pushed above");
    }];

    [self.mockResponseQueueProvider popMockResponseFile];

    [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
        XCTAssertEqual(0, [responseData length], @"mock should NOT supply data from any mock response");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testMultipleMockResponseWithPushingMultipleFilenames;
{
    NSArray *filenames = @[@"SDWebServiceMockTest_bundleA.json", @"SDWebServiceMockTest_bundleB.json"];
    NSArray *dataArray = [self pushMockResponsesWithFilenames:filenames];
    XCTAssertEqual([filenames count], [dataArray count]);

    for (NSUInteger idx=0; idx<[dataArray count]; idx++)
    {
        NSData *checkData = dataArray[idx];
        [self checkWebServiceWithBlock:^(NSData *responseData, NSError *error) {
            XCTAssertEqualObjects(checkData, responseData, @"mock should supply data from mock response %ld pushed above", (long)idx);
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end
