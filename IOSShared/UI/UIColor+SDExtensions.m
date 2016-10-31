//
//  UIColor+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 3/19/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "UIColor+SDExtensions.h"

#import "NSString+SDExtensions.h"

@implementation UIColor (SDExtensions)

+ (UIColor *)colorWith8BitRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

/*
 * Returns a UIColor objects for the string's hex representation:
 *
 * For example: [@"#fff" uicolor] returns a UIColor of white.
 *              [@"#118653" uicolor] returns something green.
 *              [@"#1186537F" uicolor] returns something green with a 50% alpha value
 */
+ (UIColor *)colorWithHexValue:(NSString *)hexValueString;
{
    UIColor *color = [hexValueString uicolor];
    return color;
}

+ (UIColor *)randomColor
{
    NSUInteger red = arc4random() % 256;
    NSUInteger green = arc4random() % 256;
    NSUInteger blue = arc4random() % 256;
    UIColor *color = [self colorWith8BitRed:red green:green blue:blue alpha:1.0];
    return color;
}

+ (instancetype)colorWithRGBHex:(uint32_t)RGBHex
{
    CGFloat red = (RGBHex >> 16) & 0xFF;
    CGFloat green = (RGBHex >> 8) & 0xFF;
    CGFloat blue = RGBHex & 0xFF;
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

+ (instancetype)colorWithRGBAHex:(uint32_t)RGBAHex {
    CGFloat red = (RGBAHex >> 24) & 0xFF;
    CGFloat green = (RGBAHex >> 16) & 0xFF;
    CGFloat blue = (RGBAHex >> 8) & 0xFF;
    CGFloat alpha = RGBAHex & 0xFF;
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
@end
