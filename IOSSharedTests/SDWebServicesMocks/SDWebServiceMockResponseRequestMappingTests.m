//
//  SDWebServiceMockResponseRequestMappingTests.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SDWebServiceMockResponseRequestMapping.h"

NSString * const kTest_rootPath = @"/";
NSString * const kTest_partialPath = @"path1";
NSString * const kTest_pathA = @"/path1/path2";
NSString * const kTest_pathB = @"/path2/path1";

NSString * const kTest_queryParam1 = @"param1";
NSString * const kTest_queryParam2 = @"param2";
NSString * const kTest_queryParam3 = @"param3";
NSString * const kTest_queryValue1 = @"abcdef";
NSString * const kTest_queryValue2 = @"1001";
NSString * const kTest_queryValue3 = @"noparam";

NSString * const kTest_urlString_nil = nil;
NSString * const kTest_urlString_bareNoQuery = @"http://example.com";
NSString * const kTest_urlString_rootNoQuery = @"http://example.com/";
NSString * const kTest_urlString_pathANoQuery = @"http://example.com/path1/path2";
NSString * const kTest_urlString_pathBNoQuery = @"http://example.com/path2/path1";
NSString * const kTest_urlString_bareWithQueryA = @"http://example.com?param1=abcdef&param2=1001";
NSString * const kTest_urlString_rootWithQueryA = @"http://example.com/?param1=abcdef&param2=1001";
NSString * const kTest_urlString_pathAWithQueryA = @"http://example.com/path1/path2?param1=abcdef&param2=1001";
NSString * const kTest_urlString_pathBWithQueryA = @"http://example.com/path2/path1?param1=abcdef&param2=1001";
NSString * const kTest_urlString_pathAWithQueryB = @"http://example.com/path1/path2?param1=abcdefghij&param2=1001234";
NSString * const kTest_urlString_pathAWithQueryC = @"http://example.com/path1/path2?param1=abcdef&param2=1001234";

#define expect(E,M,U) \
{ \
    NSURL *url = [NSURL URLWithString:U]; \
    BOOL actual = [M matchesRequest:[NSURLRequest requestWithURL:url]]; \
    if (E) \
    { \
        XCTAssertTrue(actual, @"expect mapping (%@) to match URL (%@)", M, U); \
    } \
    else \
    { \
        XCTAssertFalse(actual, @"expect mapping (%@) to NOT match URL (%@)", M, U); \
    } \
}

#define exactRegex(S) [NSString stringWithFormat:@"^%@$", S]

@interface SDWebServiceMockResponseRequestMappingTests : XCTestCase
@end

@implementation SDWebServiceMockResponseRequestMappingTests

- (void)testEmptyMapping
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:nil queryParameters:nil];
    expect(YES,mapping,kTest_urlString_nil);
    expect(YES,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_pathANoQuery);
    expect(YES,mapping,kTest_urlString_pathBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testRootPathExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:exactRegex(kTest_rootPath) queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testRootPathPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_rootPath queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(YES,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_pathANoQuery);
    expect(YES,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testPathAExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:exactRegex(kTest_pathA) queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testPathAPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_pathA queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testPartialPathExactMatch
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:exactRegex(kTest_partialPath) queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testPartialPathPattern
{
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_partialPath queryParameters:nil];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(YES,mapping,kTest_urlString_pathANoQuery);
    expect(YES,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathBWithQueryA);
}

- (void)testQueryOneParamExactMatch
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:exactRegex(kTest_queryValue1)
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathBWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryB);
    expect(YES,mapping,kTest_urlString_pathAWithQueryC);
}

- (void)testQueryOneParamPattern
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:kTest_queryValue1
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryB);
    expect(YES,mapping,kTest_urlString_pathAWithQueryC);
}

- (void)testQueryTwoParamsExactMatch
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:exactRegex(kTest_queryValue1),
      kTest_queryParam2:exactRegex(kTest_queryValue2)
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathBWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryB);
    expect(NO,mapping,kTest_urlString_pathAWithQueryC);
}

- (void)testQueryTwoParamsPattern
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:kTest_queryValue1,
      kTest_queryParam2:kTest_queryValue2
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(YES,mapping,kTest_urlString_bareWithQueryA);
    expect(YES,mapping,kTest_urlString_rootWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryA);
    expect(YES,mapping,kTest_urlString_pathAWithQueryB);
    expect(YES,mapping,kTest_urlString_pathAWithQueryC);
}


- (void)testQueryThreeParamsExactMatch
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:exactRegex(kTest_queryValue1),
      kTest_queryParam2:exactRegex(kTest_queryValue2),
      kTest_queryParam3:exactRegex(kTest_queryValue3)
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathBWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryB);
    expect(NO,mapping,kTest_urlString_pathAWithQueryC);
}

- (void)testQueryThreeParamsPattern
{
    NSDictionary *queryParameters =
    @{
      kTest_queryParam1:kTest_queryValue1,
      kTest_queryParam2:kTest_queryValue2,
      kTest_queryParam3:kTest_queryValue3
      };
    SDWebServiceMockResponseRequestMapping *mapping = [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:kTest_urlString_nil queryParameters:queryParameters];
    expect(NO,mapping,kTest_urlString_nil);
    expect(NO,mapping,kTest_urlString_bareNoQuery);
    expect(NO,mapping,kTest_urlString_rootNoQuery);
    expect(NO,mapping,kTest_urlString_pathANoQuery);
    expect(NO,mapping,kTest_urlString_pathBNoQuery);
    expect(NO,mapping,kTest_urlString_bareWithQueryA);
    expect(NO,mapping,kTest_urlString_rootWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryA);
    expect(NO,mapping,kTest_urlString_pathAWithQueryB);
    expect(NO,mapping,kTest_urlString_pathAWithQueryC);
}

@end
