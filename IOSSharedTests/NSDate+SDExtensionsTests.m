//
//  NSDate+SDExtensionsTests.m
//  ios-shared
//
//  Created by Peter Marks on 4/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+SDExtensions.h"

@interface NSDateTests : XCTestCase
{
}

@end

@implementation NSDateTests

- (void)testDateAtBeginningOfMonthForDate
{
    NSTimeZone *currentTimeZone = [NSTimeZone systemTimeZone];
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.year = 2014;
    dateComponents.month = 4;
    dateComponents.day = 15;
    dateComponents.timeZone = currentTimeZone;
    NSDate *taxDay = [gregorianCalendar dateFromComponents:dateComponents];

    dateComponents.day = 1;
    NSDate *aprilFoolsDay = [gregorianCalendar dateFromComponents:dateComponents];

    NSDate *convertedFirstDayOfMonth = [NSDate dateAtBeginningOfMonthForDate:taxDay];
    XCTAssertTrue([convertedFirstDayOfMonth isEqualToDate:aprilFoolsDay]);
}

- (void)testIsToday
{
    NSDate *now = [NSDate date];
    
    XCTAssertTrue([now isToday]);
}

- (void)testIsNotTodayAndInDistantPast
{
    NSDate *past = [NSDate distantPast];
    
    XCTAssertFalse([past isToday]);
}

- (void)testIsNotTodayAndInDistantFuture
{
    NSDate *future = [NSDate distantFuture];
    
    XCTAssertFalse([future isToday]);
}
@end
