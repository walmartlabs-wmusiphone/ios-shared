//
//  UIColor+SDExtensionsTests.m
//  ios-shared-Tests
//
//  Created by Steven Woolgar on 11/25/2013.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "UIColor+SDExtensions.h"

@interface UIColorTests : SenTestCase
{
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
}

@end

@implementation UIColorTests

- (void)setUp
{
    [super setUp];

    _red = 0.0f;
    _green = 0.0f;
    _blue = 0.0f;
    _alpha = 0.0f;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testUIColorNilUIColor
{
    UIColor* lazyWhiteNoAlpha = [UIColor colorWithHexValue:@"#fff"];
    STAssertTrue(lazyWhiteNoAlpha != nil, @"A valid color should have been returned.");
}

- (void)testUIColorLazyUIColor
{
    UIColor* lazyWhiteNoAlpha = [UIColor colorWithHexValue:@"#fff"];
    [lazyWhiteNoAlpha getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    STAssertTrue(_red == 255.0f / 255.0f && _green == 255.0f / 255.0f & _blue == 255.0f / 255.0f & _alpha == 255.0f / 255.0f, @"#fff returned the wrong value.");
}

- (void)testUIColorGreenUIColor
{
    UIColor* greenNoAlpha = [UIColor colorWithHexValue:@"#112233"];
    [greenNoAlpha getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    STAssertTrue(_red == 17.0f / 255.0f && _green == 34.0f / 255.0f & _blue == 51.0f / 255.0f & _alpha == 255.0f / 255.0f, @"#112233 returned the wrong value.");
}

- (void)testUIColorGreenWithAlphaUIColor
{
    UIColor* greenWithAlpha = [UIColor colorWithHexValue:@"#11223344"];
    [greenWithAlpha getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    STAssertTrue(_red == 17.0f / 255.0f && _green == 34.0f / 255.0f & _blue == 51.0f / 255.0f & _alpha == 68.0f / 255.0f, @"#11223344 returned the wrong value.");
}

- (void)testUIColorInvalidUIColor
{
    CGFloat whiteRed = 0.0f;
    CGFloat whiteGreen = 0.0f;
    CGFloat whiteBlue = 0.0f;
    CGFloat whiteAlpha = 0.0f;
    UIColor* white = [UIColor whiteColor];
    [white getRed:&whiteRed green:&whiteGreen blue:&whiteBlue alpha:&whiteAlpha];

    UIColor* invalidHexNoAlpha = [UIColor colorWithHexValue:@"#1"];
    [invalidHexNoAlpha getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    STAssertTrue(_red == whiteRed && _green == whiteGreen && _blue == whiteBlue & _alpha == whiteAlpha, @"A valid white color should have been returned.");
}

@end
