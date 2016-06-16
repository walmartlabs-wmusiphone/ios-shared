//
//  NSNumber+SDExtensions.m
//  ios-shared
//
//  Created by Sam Grover on 6/28/13.
//  Copyright (c) 2013 SetDirection All rights reserved.
//

#import "NSNumber+SDExtensions.h"

@implementation NSNumber (SDExtensions)

+ (NSNumber *)numberFromDollarString:(NSString *)argDollarString
{
    static NSNumberFormatter *sFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sFormatter = [[NSNumberFormatter alloc] init];
        [sFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [sFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    
    return [sFormatter numberFromString:argDollarString];
}

/**
 Note that this is currently set to locale en_US but should be set to the correct locale
 once it needs to be localized to other regions and languages.
 */
+ (NSString *)dollarStringFromNumber:(NSNumber *)argNumber
{
    static NSNumberFormatter *currencyFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    
    return [currencyFormatter stringFromNumber:argNumber];
}

+ (NSNumber *)numberFromString:(NSString *)argString
{
    static NSNumberFormatter *numberFormatter = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    
    return [numberFormatter numberFromString:argString];
}

+ (NSString *)stringFromNumber:(NSNumber *)argNumber
{
    static NSNumberFormatter *numberFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    
    return [numberFormatter stringFromNumber:argNumber];
}
@end
