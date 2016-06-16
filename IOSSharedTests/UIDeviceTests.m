//
//  UIDeviceTests.m
//  ios-shared-Tests
//
//  Created by Steven Woolgar on 06/25/2013.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIDevice+machine.h"

typedef NS_ENUM(NSUInteger, SystemVersionReturnValues)
{
    eSystemReturn5,
    eSystemReturn50,
    eSystemReturn500,
    eSystemReturn501,
    eSystemReturn502,
    eSystemReturn510,
    eSystemReturn511,
    eSystemReturn6,
    eSystemReturn60,
    eSystemReturn600,
    eSystemReturn601,
    eSystemReturn602,
    eSystemReturn610,
    eSystemReturn611,
    eSystemReturn7,
    eSystemReturn70,
    eSystemReturn700,
    eSystemReturn701,
    eSystemReturn702,
    eSystemReturn710,
    eSystemReturn711,
    eSystemReturn8,
    eSystemReturn80,
    eSystemReturn800,
    eSystemReturn801,
    eSystemReturn802,
    eSystemReturn810,
    eSystemReturn811
};

static NSUInteger sCurrentSystemReturnValue = eSystemReturn500;

@interface UIDevice(TestsOverride)

@property(nonatomic,readonly,retain) NSString    *systemVersion;     // e.g. @"4.0"

@end

@implementation UIDevice(TestsOverride)

- (NSString*) systemVersion
{
    NSString *systemVersionString = nil;

    switch (sCurrentSystemReturnValue)
    {
        case eSystemReturn5:
            systemVersionString = @"5";
            break;
        case eSystemReturn50:
            systemVersionString = @"5.0";
            break;
        case eSystemReturn500:
            systemVersionString = @"5.0.0";
            break;
        case eSystemReturn501:
            systemVersionString = @"5.0.1";
            break;
        case eSystemReturn502:
            systemVersionString = @"5.0.2";
            break;
        case eSystemReturn510:
            systemVersionString = @"5.1.0";
            break;
        case eSystemReturn511:
            systemVersionString = @"5.1.1";
            break;
        case eSystemReturn6:
            systemVersionString = @"6";
            break;
        case eSystemReturn60:
            systemVersionString = @"6.0";
            break;
        case eSystemReturn600:
            systemVersionString = @"6.0.0";
            break;
        case eSystemReturn601:
            systemVersionString = @"6.0.1";
            break;
        case eSystemReturn602:
            systemVersionString = @"6.0.2";
            break;
        case eSystemReturn610:
            systemVersionString = @"6.1.0";
            break;
        case eSystemReturn611:
            systemVersionString = @"6.1.1";
            break;
        case eSystemReturn7:
            systemVersionString = @"7";
            break;
        case eSystemReturn70:
            systemVersionString = @"7.0";
            break;
        case eSystemReturn700:
            systemVersionString = @"7.0.0";
            break;
        case eSystemReturn701:
            systemVersionString = @"7.0.1";
            break;
        case eSystemReturn702:
            systemVersionString = @"7.0.2";
            break;
        case eSystemReturn710:
            systemVersionString = @"7.1.0";
            break;
        case eSystemReturn711:
            systemVersionString = @"7.1.1";
            break;
        case eSystemReturn8:
            systemVersionString = @"8";
            break;
        case eSystemReturn80:
            systemVersionString = @"8.0";
            break;
        case eSystemReturn800:
            systemVersionString = @"8.0.0";
            break;
        case eSystemReturn801:
            systemVersionString = @"8.0.1";
            break;
        case eSystemReturn802:
            systemVersionString = @"8.0.2";
            break;
        case eSystemReturn810:
            systemVersionString = @"8.1.0";
            break;
        case eSystemReturn811:
            systemVersionString = @"8.1.1";
            break;
    }

    return systemVersionString;
}

@end

@interface UIDeviceTests : XCTestCase
@end

@implementation UIDeviceTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBcdSystemVersion
{
    sCurrentSystemReturnValue = eSystemReturn5;
    uint32_t system5 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system5 == 0x050000, @"bcdSystemVersion did not understand 5");

    sCurrentSystemReturnValue = eSystemReturn50;
    uint32_t system50 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system50 == 0x050000, @"bcdSystemVersion did not understand 5.0");

    sCurrentSystemReturnValue = eSystemReturn500;
    uint32_t system500 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system500 == 0x050000, @"bcdSystemVersion did not understand 5.0.0");

    sCurrentSystemReturnValue = eSystemReturn501;
    uint32_t system501 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system501 == 0x050001, @"bcdSystemVersion did not understand 5.0.1");

    sCurrentSystemReturnValue = eSystemReturn502;
    uint32_t system502 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system502 == 0x050002, @"bcdSystemVersion did not understand 5.0.2");

    sCurrentSystemReturnValue = eSystemReturn510;
    uint32_t system510 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system510 == 0x050100, @"bcdSystemVersion did not understand 5.1.0");

    sCurrentSystemReturnValue = eSystemReturn511;
    uint32_t system511 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system511 == 0x050101, @"bcdSystemVersion did not understand 5.1.1");

    sCurrentSystemReturnValue = eSystemReturn6;
    uint32_t system6 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system6 == 0x060000, @"bcdSystemVersion did not understand 6");

    sCurrentSystemReturnValue = eSystemReturn60;
    uint32_t system60 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system60 == 0x060000, @"bcdSystemVersion did not understand 6.0");

    sCurrentSystemReturnValue = eSystemReturn600;
    uint32_t system600 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system600 == 0x060000, @"bcdSystemVersion did not understand 6.0.0");

    sCurrentSystemReturnValue = eSystemReturn601;
    uint32_t system601 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system601 == 0x060001, @"bcdSystemVersion did not understand 6.0.1");

    sCurrentSystemReturnValue = eSystemReturn602;
    uint32_t system602 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system602 == 0x060002, @"bcdSystemVersion did not understand 6.0.2");

    sCurrentSystemReturnValue = eSystemReturn610;
    uint32_t system610 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system610 == 0x060100, @"bcdSystemVersion did not understand 6.1.0");

    sCurrentSystemReturnValue = eSystemReturn611;
    uint32_t system611 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system611 == 0x060101, @"bcdSystemVersion did not understand 6.1.1");

    sCurrentSystemReturnValue = eSystemReturn7;
    uint32_t system7 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system7 == 0x070000, @"bcdSystemVersion did not understand 7");

    sCurrentSystemReturnValue = eSystemReturn70;
    uint32_t system70 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system70 == 0x070000, @"bcdSystemVersion did not understand 7.0");
    
    sCurrentSystemReturnValue = eSystemReturn700;
    uint32_t system700 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system700 == 0x070000, @"bcdSystemVersion did not understand 7.0.0");

    sCurrentSystemReturnValue = eSystemReturn701;
    uint32_t system701 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system701 == 0x070001, @"bcdSystemVersion did not understand 7.0.1");

    sCurrentSystemReturnValue = eSystemReturn702;
    uint32_t system702 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system702 == 0x070002, @"bcdSystemVersion did not understand 7.0.2");

    sCurrentSystemReturnValue = eSystemReturn710;
    uint32_t system710 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system710 == 0x070100, @"bcdSystemVersion did not understand 7.1.0");

    sCurrentSystemReturnValue = eSystemReturn711;
    uint32_t system711 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system711 == 0x070101, @"bcdSystemVersion did not understand 7.1.1");

    sCurrentSystemReturnValue = eSystemReturn8;
    uint32_t system8 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system8 == 0x080000, @"bcdSystemVersion did not understand 8");

    sCurrentSystemReturnValue = eSystemReturn80;
    uint32_t system80 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system80 == 0x080000, @"bcdSystemVersion did not understand 8.0");

    sCurrentSystemReturnValue = eSystemReturn800;
    uint32_t system800 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system800 == 0x080000, @"bcdSystemVersion did not understand 8.0.0");

    sCurrentSystemReturnValue = eSystemReturn801;
    uint32_t system801 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system801 == 0x080001, @"bcdSystemVersion did not understand 8.0.1");

    sCurrentSystemReturnValue = eSystemReturn802;
    uint32_t system802 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system802 == 0x080002, @"bcdSystemVersion did not understand 8.0.2");

    sCurrentSystemReturnValue = eSystemReturn810;
    uint32_t system810 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system810 == 0x080100, @"bcdSystemVersion did not understand 8.1.0");

    sCurrentSystemReturnValue = eSystemReturn811;
    uint32_t system811 = [UIDevice bcdSystemVersion];
    XCTAssertTrue(system811 == 0x080101, @"bcdSystemVersion did not understand 8.1.1");
}

@end
