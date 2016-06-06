//
//  UIApplicationSDExtensionsTests.m
//  walmart
//
//  Created by David Pettigrew on 5/26/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "UIApplication+SDExtensions.h"
#import "OCMock.h"

@interface UIApplicationSDExtensionsTests : XCTestCase

@end

@implementation UIApplicationSDExtensionsTests

- (void)setUp {
    [super setUp];
    NSLog(@"Deployment target: %i", __IPHONE_OS_VERSION_MIN_REQUIRED);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0 // Deployment target < iOS 8.0

- (void)test_isPushEnabled_iOS7_NO {
    id mockUIApplication = OCMClassMock([UIApplication class]);
    OCMStub([mockUIApplication sharedApplication]).andReturn(mockUIApplication);

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) // when run on an iOS 8.x device/simulator
    {
        OCMStub([mockUIApplication isRegisteredForRemoteNotifications]).andReturn(NO);
    }
    else // when run on an iOS 7.x device/simulator
    {
        OCMStub([mockUIApplication enabledRemoteNotificationTypes]).andReturn(UIRemoteNotificationTypeNone);
    }

    XCTAssertFalse([UIApplication isPushEnabled], @"isPushEnabled");
    [mockUIApplication stopMocking];
}

- (void)test_isPushEnabled_iOS7_YES {
    id mockUIApplication = OCMClassMock([UIApplication class]);
    OCMStub([mockUIApplication sharedApplication]).andReturn(mockUIApplication);

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) // when run on an iOS 8.x device/simulator

    {
        OCMStub([mockUIApplication isRegisteredForRemoteNotifications]).andReturn(YES);
    }
    else // when run on an iOS 7.x device/simulator
    {
        OCMStub([mockUIApplication enabledRemoteNotificationTypes]).andReturn(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert);
    }

    XCTAssertTrue([UIApplication isPushEnabled], @"isPushEnabled");
    [mockUIApplication stopMocking];
}

#else // Deployment target > iOS 8.0

// commenting out until we decide what to do about OCMClassMock external
//- (void)test_isPushEnabled_iOS8_NO {
//    id mockUIApplication = OCMClassMock([UIApplication class]);
//    OCMStub([mockUIApplication sharedApplication]).andReturn(mockUIApplication);
//    OCMStub([mockUIApplication isRegisteredForRemoteNotifications]).andReturn(NO);
//
//    XCTAssertFalse([UIApplication isPushEnabled], @"isPushEnabled");
//    [mockUIApplication stopMocking];
//}
//
//- (void)test_isPushEnabled_iOS8_YES {
//    id mockUIApplication = OCMClassMock([UIApplication class]);
//    OCMStub([mockUIApplication sharedApplication]).andReturn(mockUIApplication);
//    OCMStub([mockUIApplication isRegisteredForRemoteNotifications]).andReturn(YES);
//
//    XCTAssertTrue([UIApplication isPushEnabled], @"isPushEnabled");
//    [mockUIApplication stopMocking];
//}

#endif


@end
