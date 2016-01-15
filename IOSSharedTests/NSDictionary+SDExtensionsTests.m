//
//  NSDictionaryTests.m
//  ios-shared
//
//  Created by Peter Marks on 4/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"

@interface NSDictionaryTests : XCTestCase

@end

@implementation NSDictionaryTests

- (void)testSectionDictionaryFromArrayWithSortBlock
{
    NSDictionary *object1 = @{@"date": [NSDate dateFromRFC822String:@"2014-04-01T07:00:00-0000"], @"name": @"April Fools"};
    NSDictionary *object2 = @{@"date": [NSDate dateFromRFC822String:@"2014-04-15T07:00:00-0000"], @"name": @"Tax Day"};
    NSDictionary *object3 = @{@"date": [NSDate dateFromRFC822String:@"2014-01-01T07:00:00-0000"], @"name": @"New Years Day"};
    NSArray *objectArray = @[object1, object2, object3];
    NSDictionary *resultDictionary = [NSDictionary sectionDictionaryFromArray:objectArray withSectionKeyBlock:^(id blockObject) {
        if ([blockObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *object = (NSDictionary*)blockObject;
            NSDate *date = [object objectForKey:@"date"];
            return [NSDate dateAtBeginningOfMonthForDate:date];
        }
        else
        {
            return [NSDate date]; // have to provide a date
        }
    }];
    XCTAssertTrue([resultDictionary allKeys].count == 2);
}

@end
