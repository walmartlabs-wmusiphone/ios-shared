//
//  UIDevice+machine.h
//  SetDirection
//
//  Created by Justin Zealand on 4/1/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice(machine)

- (NSString *)machine;
+ (BOOL)systemVersionGreaterThanOrEqualToVersion:(NSString *)minVersion;
+ (BOOL)systemVersionLessThanVersion:(NSString *)minVersion;

/**
 Returns the OS version as BCD stored in a 4 byte unsigned integer.
 Here's an example of its use:

    if ([UIDevice bcdSystemVersion] >= 0x040301)

 Which will check to see if the device is running an OS of 4.3.1 or higher.
 */
+ (uint32_t)bcdSystemVersion;

/**
 Returns the OS major version as an NSInteger.
 Here's an example of its use:
 
    if ([UIDevice systemMajorVersion] >= 4)
*/
+ (NSInteger)systemMajorVersion;

/**
 Returns YES/NO as to whether the current device is an iPad.
 */
+ (BOOL)iPad;

@end
