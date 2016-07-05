//
//  SDCardNumber.m
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import <Foundation/Foundation.h>
#import "SDCardType.h"

@interface SDCardNumber : NSObject

@property (nonatomic, readonly) SDCardType cardType;
@property (nonatomic, readonly) NSString* lastGroup;
@property (nonatomic, readonly) NSString* string;
@property (nonatomic, readonly) NSString* formattedString;
@property (nonatomic, readonly) NSString* formattedStringWithTrail;

+ (instancetype)cardNumberWithString:(NSString*)string;
- (instancetype)initWithString:(NSString *)string;
- (SDCardType)cardType;
- (NSString*)lastGroup;
- (NSString*)string;
- (NSString*)formattedString;
- (NSString*)formattedStringWithTrail;
- (BOOL)isValid;
- (BOOL)isValidLength;
- (BOOL)isValidLuhn;
- (BOOL)isPartiallyValid;

@end
