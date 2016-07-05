//
//  NSDate+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "NSDate+SDExtensions.h"


@implementation NSDate (SDExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)argDateString
{
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    });
    
	return [sFormatter dateFromString:argDateString];
}

+ (NSDate *)dateFromISO8601StringWithMilliseconds:(NSString *)argDateString
{
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    });
    
	return [sFormatter dateFromString:argDateString];
}


+ (NSDate *)dateFromRFC822String:(NSString *)argDateString
{
	static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    });
    
    return [sFormatter dateFromString:argDateString];
}

/**
 Takes a string of format M/d/y and returns an NSDate.
 */
+ (NSDate *)dateFromMonthDayYearString:(NSString *)argDateString
{
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [sFormatter setDateFormat:@"M/d/y"];
    });
    
    return [sFormatter dateFromString:argDateString];
}

+ (NSDate *)dateAtBeginningOfMonthForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [[NSCalendar alloc ] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month) of the input date
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    [dateComps setDay:1];
	
    // Convert back
    NSDate *beginningOfMonth = [calendar dateFromComponents:dateComps];
    return beginningOfMonth;
}


// ---------------------------------------------------------------- //
// Time interval comparison convenience methods

-(BOOL)happenedMoreThanNSecondsAgo:(NSInteger)numSeconds
{
	if([self timeIntervalSinceNow] < -numSeconds)
	{
		return YES;
	}
	return NO;
}

-(BOOL)happenedMoreThanNMinutesAgo:(NSInteger)numMinutes
{
	return [self happenedMoreThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedMoreThanNHoursAgo:(NSInteger)numHours
{
	return [self happenedMoreThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedMoreThanNDaysAgo:(NSInteger)numDays
{
	return [self happenedMoreThanNHoursAgo: numDays * 24];
}

-(BOOL)happenedLessThanNSecondsAgo:(NSInteger)numSeconds
{
	if([self timeIntervalSinceNow] > -numSeconds)
	{
		return YES;
	}	
	return NO;
}

-(BOOL)happenedLessThanNMinutesAgo:(NSInteger)numMinutes
{
	return [self happenedLessThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedLessThanNHoursAgo:(NSInteger)numHours
{
	return [self happenedLessThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedLessThanNDaysAgo:(NSInteger)numDays
{
	return [self happenedLessThanNHoursAgo: numDays * 24];
}

// Compares this date with the current time and returns YES if they are
// the same
- (BOOL)isToday
{
    BOOL isToday = NO;
    
    NSCalendar *calendar = [[NSCalendar alloc ] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];

    NSDateComponents *components = [calendar components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:components];
    
    components = [calendar components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSDate *thisDate = [calendar dateFromComponents:components];
    
    if ([thisDate isEqualToDate:today])
    {
        isToday = YES;
    }
    
    return isToday;
}

#pragma mark - additional methods

- (NSDate *) dateWithYear:(NSNumber *) year month:(NSNumber *) month day:(NSNumber *) day hour:(NSNumber *) hour minute:(NSNumber *) minute second:(NSNumber *) second;
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:self];
    if (year != nil) {
        dateComponents.year = [year integerValue];
    }
    if (month != nil) {
        dateComponents.month = [month integerValue];
    }
    if (day != nil) {
        dateComponents.day = [day integerValue];
    }
    if (hour != nil) {
        dateComponents.hour = [hour integerValue];
    }
    if (minute != nil) {
        dateComponents.minute = [minute integerValue];
    }
    if (second != nil) {
        dateComponents.second = [second integerValue];
    }
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

- (NSInteger) calendarDaysRelativeToDate:(NSDate *) argDate;
{
    NSDate *argDateAtMidnight = [argDate dateWithYear:nil month:nil day:nil hour:@0 minute:@0 second:@0];
    NSDate *selfAtMidnight = [self dateWithYear:nil month:nil day:nil hour:@0 minute:@0 second:@0];
    NSTimeInterval timeInterval = [selfAtMidnight timeIntervalSinceDate:argDateAtMidnight];
    static NSTimeInterval oneDay = (24.0*60.0*60.0);
    NSInteger days = (int) ((timeInterval + ((timeInterval < 0) ? -1 : 1)) / oneDay);
    return days;
}

+ (NSString *)timeStringFromSeconds:(NSTimeInterval)totalSeconds
{
    NSUInteger hoursLeft = (NSUInteger)totalSeconds / (60*60);
    NSUInteger hoursRemainder = (NSUInteger)totalSeconds % (60*60);
    NSUInteger minutesLeft = hoursRemainder / 60;
    NSUInteger minutesRemainder = hoursRemainder % 60;
    NSUInteger secondsLeft = minutesRemainder;
    if (secondsLeft > 29) {
        ++minutesLeft;
        if (minutesLeft == 60) {
            minutesLeft = 0;
            ++hoursLeft;
        }
    }
    NSString *timeString = nil;
    if (hoursLeft && minutesLeft) { // hours and minutes
        NSString *minutes = nil;
        NSString *hours = nil;
        if (minutesLeft > 1) { // minutes
            minutes = [NSString stringWithFormat:@"%lu minutes", (unsigned long)minutesLeft];
        }
        else {
            minutes = [NSString stringWithFormat:@"%lu minute", (unsigned long)minutesLeft];
        }
        if (hoursLeft > 1) { // hours
            hours = [NSString stringWithFormat:@"%lu hours", (unsigned long)hoursLeft];
        }
        else {
            hours = [NSString stringWithFormat:@"%lu hour", (unsigned long)hoursLeft];
        }
        timeString = [NSString stringWithFormat:@"%@ %@", hours, minutes];
    }
    else if (hoursLeft && !minutesLeft) { // exact number of hours
        if (hoursLeft == 1) {
            timeString = [NSString stringWithFormat:@"%lu hour", (unsigned long)hoursLeft];
        }
        else {
            timeString = [NSString stringWithFormat:@"%lu hours", (unsigned long)hoursLeft];
        }
    }
    else if (!hoursLeft && minutesLeft) { // just minutes
        if (minutesLeft == 1) {
            timeString = [NSString stringWithFormat:@"%lu minute", (unsigned long)minutesLeft];
        }
        else {
            timeString = [NSString stringWithFormat:@"%lu minutes", (unsigned long)minutesLeft];
        }
    }
    return timeString;
}

- (NSString *)mediumDateString {
    static NSDateFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSDateFormatter alloc] init];
        [sFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
    });
    
    return [sFormatter stringFromDate:self];
}

@end
