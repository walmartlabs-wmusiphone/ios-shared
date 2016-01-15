//
//  UIDevice+machine.m
//  SetDirection
//
//  Created by Justin Zealand on 4/1/11.
//  Copyright 2011 SetDirection. All rights reserved.
//
//  Based upon http://iphonedevelopertips.com/device/determine-if-iphone-is-3g-or-3gs-determine-if-ipod-is-first-or-second-generation.html

#import "UIDevice+machine.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice(machine)

- (NSString *)machine
{
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [NSString stringWithUTF8String:name];
	
	free(name);
	
    return machine;
}

+ (BOOL)systemVersionGreaterThanOrEqualToVersion:(NSString *)minVersion 
{
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
	NSComparisonResult result = [sysVersion compare:minVersion options:NSNumericSearch];
	if (result == NSOrderedDescending || result == NSOrderedSame)
		return YES;
    return NO;
}

+ (BOOL)systemVersionLessThanVersion:(NSString *)minVersion 
{
    if ([UIDevice systemVersionGreaterThanOrEqualToVersion:minVersion])
		return NO;
	return YES;
}

// Returns the OS version as BCD stored in a 4 byte unsigned integer.
// Here is an example of it's use:
//
//   if ([UIDevice bcdSystemVersion] >= 0x040301)
//
// Which will check to see if the device is running an OS of 4.3.1 or higher.

+ (uint32_t)bcdSystemVersion
{
    static NSUInteger version = 0;

#ifndef DEBUG
    if (version == 0)
#else
    version = 0;
#endif
    {
        NSString *versionString = [[UIDevice currentDevice] systemVersion];
        NSArray *components = [versionString componentsSeparatedByString:@"."];

        if (components.count > 2)
        {
            version |= 0x000000FF & (uint)[[components objectAtIndex: 2] integerValue];
        }
        if (components.count > 1)
        {
            version |= (0x000000FF & (uint)[[components objectAtIndex: 1] integerValue]) << 8;
        }
        if (components.count)
        {
            version |= (0x000000FF & (uint)[[components objectAtIndex: 0] integerValue]) << 16;
        }
    }

    return (uint32_t)version;
}

+ (NSInteger)systemMajorVersion
{
    static NSInteger version = 0;

#ifndef DEBUG
    if (version == 0)
#else
    version = 0;
#endif
    {
        NSString *versionString = [[UIDevice currentDevice] systemVersion];
        NSArray *components = [versionString componentsSeparatedByString:@"."];

        if (components.count > 0)
        {
            NSString *stringVersion = [components objectAtIndex:0];
            version = [stringVersion integerValue];
        }
    }

    return version;
}

+ (BOOL)iPad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES; // Device is iPad.
    return NO;
}

@end
