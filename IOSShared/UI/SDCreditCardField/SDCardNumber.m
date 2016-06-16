//
//  SDCardNumber.m
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import "SDCardNumber.h"

@interface SDCardNumber()
@property (nonatomic, strong) NSString* number;
@end

@implementation SDCardNumber

+ (instancetype)cardNumberWithString:(NSString*)string
{
    return [[self alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString*)string
{
    self = [super init];
    if(self != nil)
    {
        // Strip non-digits
        _number = [string stringByReplacingOccurrencesOfString:@"\\D"
                                                    withString:@""
                                                       options:NSRegularExpressionSearch
                                                         range:NSMakeRange(0, string.length)];
    }

    return self;
}

- (SDCardType)cardType
{
    // Handle the Personal Label Credit Cards for Sams.
    if(self.number.length >= 6)
    {
        NSString* first6Chars = [self.number substringWithRange:NSMakeRange(0, 6)];
        if([first6Chars isEqualToString:@"601136"])                   { return SDCardTypeSamsClub; }
        else if([first6Chars isEqualToString:@"601137"])              { return SDCardTypeSamsClubBusiness; }
    }

    // Handle the base credit cards kinds.
    if(self.number.length < 2) return SDCardTypeUnknown;
    NSString* firstChars = [self.number substringWithRange:NSMakeRange(0, 2)];
    NSInteger range = [firstChars integerValue];

    if(range >= 40 && range <= 49)                                    { return SDCardTypeVisa; }
    else if(range >= 50 && range <= 59)                               { return SDCardTypeMasterCard; }
    else if(range == 34 || range == 37)                               { return SDCardTypeAmex; }
    else if(range == 60 || range == 62 || range == 64 || range == 65) { return SDCardTypeDiscover; }
    else if(range == 35)                                              { return SDCardTypeJCB; }
    else if(range == 30 || range == 36 || range == 38 || range == 39) { return SDCardTypeDinersClub; }

    return SDCardTypeUnknown;
}

- (NSString*)lastGroup
{
    NSString* result = nil;

    if(self.cardType == SDCardTypeAmex)
    {
        if(self.number.length >= 5)
        {
            result = [self.number substringFromIndex:(self.number.length - 5)];
        }
    }
    else
    {
        if(self.number.length >= 4)
        {
            result = [self.number substringFromIndex:(self.number.length - 4)];
        }
    }

    return result;
}

- (NSString*)string
{
    return self.number;
}

- (NSString*)formattedString
{
    NSRegularExpression* regex = nil;

    if(self.cardType == SDCardTypeAmex)
    {
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,4})(\\d{1,6})?(\\d{1,5})?" options:0 error:NULL];
    }
    else if(self.cardType == SDCardTypeDinersClub)
    {
		regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,4})(\\d{1,6})?(\\d{1,4})?" options:0 error:NULL];
	}
	else
    {
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,4})" options:0 error:NULL];
    }

    NSArray* matches = [regex matchesInString:self.number options:0 range:NSMakeRange(0, self.number.length)];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:matches.count];

    for(NSTextCheckingResult* match in matches)
    {
        for(NSUInteger i = 1; i < [match numberOfRanges]; i++)
        {
            NSRange range = [match rangeAtIndex:i];

            if(range.length > 0)
            {
                NSString* matchText = [self.number substringWithRange:range];
                [result addObject:matchText];
            }
        }
    }

    return [result componentsJoinedByString:@" "];
}

- (NSString*)formattedStringWithTrail
{
    NSString* string = [self formattedString];
    NSRegularExpression* regex = nil;
    
    // No trailing space needed

    if([self isValidLength] == NO)
    {
        if(self.cardType == SDCardTypeAmex)
        {
            regex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d{4}|\\d{4}\\s\\d{6})$" options:0 error:NULL];
        }
        else
        {
            regex = [NSRegularExpression regularExpressionWithPattern:@"(?:^|\\s)(\\d{4})$" options:0 error:NULL];
        }
        
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
        
        if(numberOfMatches != 0)
        {
            string = [NSString stringWithFormat:@"%@ ", string];
        }
    }

    return string;
}

- (BOOL)isValid
{
    return self.isValidLength && self.isValidLuhn;
}

- (BOOL)isValidLength
{
    return self.number.length == self.lengthForCardType;
}

- (BOOL)isValidLuhn
{
    NSMutableArray* digits = [NSMutableArray arrayWithCapacity:self.number.length];
    
    for(NSUInteger i = 0; i < self.number.length; i++)
    {
        [digits addObject:[self.number substringWithRange:NSMakeRange(i, 1)]];
    }

    BOOL odd = YES;
    int sum = 0;
    for(NSString* digitString in [digits reverseObjectEnumerator])
    {
        int digit = [digitString intValue];
        if((odd = !odd)) digit *= 2;
        if(digit > 9) digit -= 9;
        sum += digit;
    }
    
    return sum % 10 == 0;
}

- (BOOL)isPartiallyValid
{
    return self.number.length <= [self lengthForCardType];
}

- (NSInteger)lengthForCardType
{
    NSInteger length = 16;

    SDCardType type = self.cardType;
    if(type == SDCardTypeAmex)
    {
        length = 15;
    }
    else if(type == SDCardTypeDinersClub)
    {
        length = 14;
    }

    return length;
}

@end
