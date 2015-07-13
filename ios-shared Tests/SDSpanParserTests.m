//
//  SDSpanParserTests.m
//  ios-shared
//
//  Created by Cody Garvin on 10/1/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDSpanParser.h"
#import "SDLog.h"

@interface SDSpanParserTests : XCTestCase

@end

typedef NS_ENUM(NSUInteger, SRSpanMatchType)
{
    SRSpanMatchTypeOpen = 0,
    SRSpanMatchTypeClose
};

@interface SRSpanMatch : NSObject
@property (nonatomic, assign, readwrite) NSRange               classRange;
@property (nonatomic, assign, readonly) NSRange               spanRange;
@property (nonatomic, assign, readonly) SRSpanMatchType       type;
+ (NSArray *)matchesIn:(NSString *)string;
- (NSRange)properRangeForSpanWithClassOnString:(NSString *)string error:(NSError **)error;
@end

@interface SRSTestHelper : NSObject
+ (NSString *)stringForMockFile:(NSString *)mockfile;
@end

@implementation SRSTestHelper

+ (NSString *)stringForMockFile:(NSString *)mockfile
{
    NSString *mockString = nil;
    
    NSString *safeFilename = [mockfile lastPathComponent];
    NSString *finalPath = [[NSBundle bundleForClass:[self class]] pathForResource:safeFilename ofType:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *mockData = nil;
    
    if (finalPath && [fileManager fileExistsAtPath:finalPath])
    {
        SDLog(@"*** Using mock data file '%@'", safeFilename);
        mockData = [NSData dataWithContentsOfFile:finalPath];
        mockString = [mockData stringRepresentation];
    }
    else
        SDLog(@"*** Unable to find mock file '%@'", safeFilename);
    
    return mockString;
}


@end

@implementation SDSpanParserTests
{
    SDSpanParser *spanParser;
}


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParseWithStyles
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_basic.txt"];
    
    NSDictionary *styles = @{@"homecardsubtitle": @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"Cochin" size:15],
                                 NSForegroundColorAttributeName : [UIColor redColor]}};

    
    NSAttributedString *testString = [SDSpanParser parse:stringToTest withStyles:styles];
    
    NSDictionary *attributes = [testString attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertTrue([((UIFont *)[attributes objectForKey:@"NSFont"]).fontName isEqualToString:@"Cochin"], @"The font should return Cochin");
}

- (void)testProperRangeForSpanWithClassOnString
{
    // Test a good range is coming back
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_basic.txt"];
    if (stringToTest)
    {
        NSArray *rawMatches = [SRSpanMatch matchesIn:stringToTest];
        if ([rawMatches count] > 0)
        {
            SRSpanMatch *spanMatch = [rawMatches firstObject];
            NSRange basicRange = [spanMatch properRangeForSpanWithClassOnString:stringToTest error:nil];
            XCTAssertTrue(basicRange.location == 13 && basicRange.length == 16, @"The range returned should start at index 13 and have a length of 16");
        }
    }
    
    // Test a multi-line
    stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_multispans.txt"];
    if (stringToTest)
    {
        NSArray *rawMatches = [SRSpanMatch matchesIn:stringToTest];
        if ([rawMatches count] > 1)
        {
            SRSpanMatch *spanMatch = [rawMatches objectAtIndex:1];
            // Manually set the classRange 56/15
            spanMatch.classRange = NSMakeRange(57, 15);
            
            NSRange basicRange = [spanMatch properRangeForSpanWithClassOnString:stringToTest error:nil];
            XCTAssertTrue(basicRange.location == 65 && basicRange.length == 6, @"The range returned should start at index 13 and have a length of 16");
        }
    }
    
    // Test nserror is working
    stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_missingclass.txt"];
    if (stringToTest)
    {
        NSArray *rawMatches = [SRSpanMatch matchesIn:stringToTest];
        if ([rawMatches count] > 1)
        {
            SRSpanMatch *spanMatch = [rawMatches objectAtIndex:1];
            
            NSError *error = nil;
            [spanMatch properRangeForSpanWithClassOnString:stringToTest error:&error];
            XCTAssertTrue(error && error.localizedDescription.length > 0, @"An error should return for a class not being found");
        }
    }
}

- (void)testMatchesInBasic
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_basic.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same");

}

- (void)testMatchesInMissingClass
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_missingclass.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same");
    
}

- (void)testMatchesInMultiSpans
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_multispans.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same, there should be multi-matches");
    
}

- (void)testMatchesInMultiSpansNoClass
{
    NSString *stringToTest = [SRSTestHelper stringForMockFile:@"SpanTest_multispans_noclass.txt"];
    NSArray *verifyArray = [SRSpanMatch matchesIn:stringToTest];
    NSInteger totalOpened = 0;
    NSInteger totalClosed = 0;
    for (SRSpanMatch *result in verifyArray)
    {
        if (result.type == SRSpanMatchTypeOpen)
        {
            ++totalOpened;
        }
        else
        {
            ++totalClosed;
        }
    }
    
    XCTAssertTrue(totalOpened == totalClosed, @"The total SRSpanMatch elements should be the same, there should be multi-matches");
    
}

- (void)testSpanHasClass
{
    NSArray *filenames = @[@"SpanTest_basic.txt", @"SpanTest_extraspace.txt", @"SpanTest_multispans.txt", @"SpanTest_multispans_noclass.txt", @"SpanTest_missingclass.txt"];
    NSArray *acceptableValues = @[@"homecardsubtitle", @"class1", @"class2", @"class3", @"class4"];
    for (NSString *filename in filenames)
    {
        NSString *stringToTest = [SRSTestHelper stringForMockFile:filename];
        
        if (!stringToTest)
        {
            continue;
        }
        
        NSArray *rawMatches = [SRSpanMatch matchesIn:stringToTest];

        NSUInteger currentIndex = 0;

        if ([rawMatches count] > 0)
        {
            for (SRSpanMatch *match in rawMatches)
            {
                NSUInteger spanLocation = match.spanRange.location;
                if (spanLocation > currentIndex)
                {
                    NSRange subRange = NSMakeRange(currentIndex, spanLocation - currentIndex);

                    currentIndex += subRange.length;
                }
                
                if (spanLocation == currentIndex)
                {
                    if (match.type == SRSpanMatchTypeOpen)
                    {
                        NSError *error = nil;
                        NSString *styleName = [stringToTest substringWithRange:[match properRangeForSpanWithClassOnString:stringToTest error:&error]];
                        if (styleName.length > 0 && !error)
                        {
                            XCTAssertTrue([acceptableValues indexOfObject:styleName] != NSNotFound, @"The object %@ was not found", styleName);
                        }
                    }
                }
            }
        }
        else
        {
            XCTFail(@"There should be matches within this file");
        }
    }
}

@end
