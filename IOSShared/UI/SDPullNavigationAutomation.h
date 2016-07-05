//
//  SDPullNavigationAutomation.h
//  ios-shared

//
//  Created by Steven Woolgar on 01/02/2014.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const SDPullNavigationControllerKey;
extern NSString* const SDPullNavigationCommandKey;
extern NSString* const SDPullNavigationDataKey;

@protocol SDPullNavigationAutomation <NSObject>
@required

- (void)processAutomationCommand:(NSString*)command withData:(NSString*)commandData;
- (NSArray*)automationCommands;

@end

@interface UIView(SDPullNavigationAutomation)

- (Class)pullNavigationAutomationClass;
- (void)setPullNavigationAutomationClass:(Class)automationClass;
- (NSString*)pullNavigationAutomationCommand;
- (void)setPullNavigationAutomationCommand:(NSString*)automationCommand;
- (NSString*)pullNavigationAutomationData;
- (void)setPullNavigationAutomationData:(NSString*)automationData;
- (void)resetPullNavigationAutomationCommand;

@end
