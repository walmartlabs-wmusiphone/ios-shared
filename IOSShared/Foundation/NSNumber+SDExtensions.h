//
//  NSNumber+SDExtensions.h
//  ios-shared
//
//  Created by Sam Grover on 6/28/13.
//  Copyright (c) 2013 SetDirection All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (SDExtensions)

/**
 Takes a string of format $1,000,000.00 and returns an NSNumber.
 */
+ (NSNumber *)numberFromDollarString:(NSString *)argDollarString;

/**
 Takes an NSNumber and returns a string of format $1,000,000.00.
 */
+ (NSString *)dollarStringFromNumber:(NSNumber *)argNumber;

/**
 Takes an NSString that is known to be a number and returns an NSNumber
 */
+ (NSNumber *)numberFromString:(NSString *)argString;

/**
 Takes an NSNumber and returns a NSString of format 1,000
 */
+ (NSString *)stringFromNumber:(NSNumber *)argNumber;

@end
