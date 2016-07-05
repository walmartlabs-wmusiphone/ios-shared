//
//  NSArray+SDExtensionsTests.m
//  ios-shared-Tests
//
//  Created by Steven Woolgar on 01/17/2014.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+SDExtensions.h"

@interface NSArrayTests : XCTestCase
{
}

@end

@implementation NSArrayTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNSArrayFromArrays
{
    NSArray* arrayOfArrays = @[ @[@"a", @"b", @"c"], @[@"d", @"e", @"f"], @[@"g", @"h", @"i"] ];
    NSArray* preComputedResultArray = @[ @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i" ];

    XCTAssertTrue([[NSArray arrayFromArrays:arrayOfArrays] isEqualToArray:preComputedResultArray], @"The arrays should match");
}

@end
