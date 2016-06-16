//
//  SDPullNavigationAutomation.m
//  ios-shared

//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationAutomation.h"

#import "objc/runtime.h"

NSString* const SDPullNavigationControllerKey = @"SDPullNavigationControllerKey";
NSString* const SDPullNavigationCommandKey = @"SDPullNavigationCommandKey";
NSString* const SDPullNavigationDataKey = @"SDPullNavigationDataKey";

static void* SDPullNavigationAutomationClassKey = "SDPullNavigationAutomationClassKey";
static void* SDPullNavigationAutomationCommandKey = "SDPullNavigationAutomationCommandKey";
static void* SDPullNavigationAutomationDataKey = "SDPullNavigationAutomationDataKey";

@implementation UIView(SDPullNavigationAutomation)

- (Class)pullNavigationAutomationClass
{
    Class automationSupportClass = objc_getAssociatedObject(self, SDPullNavigationAutomationClassKey);
    return automationSupportClass;
}

- (void)setPullNavigationAutomationClass:(Class)automationClass
{
    NSAssert(class_conformsToProtocol(automationClass, @protocol(SDPullNavigationAutomation)), @"Class must conform to SDPullNavigationAutomation");
    objc_setAssociatedObject(self, SDPullNavigationAutomationClassKey, automationClass, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString*)pullNavigationAutomationCommand
{
    NSString* automationSupportCommand = objc_getAssociatedObject(self, SDPullNavigationAutomationCommandKey);
    return automationSupportCommand;
}

- (void)setPullNavigationAutomationCommand:(NSString*)automationCommand
{
    objc_setAssociatedObject(self, SDPullNavigationAutomationCommandKey, automationCommand, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)pullNavigationAutomationData
{
    NSString* automationSupportCommand = objc_getAssociatedObject(self, SDPullNavigationAutomationDataKey);
    return automationSupportCommand;
}

- (void)setPullNavigationAutomationData:(NSString*)automationData
{
    objc_setAssociatedObject(self, SDPullNavigationAutomationDataKey, automationData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)resetPullNavigationAutomationCommand
{
    [self setPullNavigationAutomationCommand:nil];
    [self setPullNavigationAutomationData:nil];
}

@end
