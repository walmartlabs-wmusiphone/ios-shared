//
//  NSCachedURLResponse+LeakFix.m
//  SetDirection
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012-2014 SetDirection. All rights reserved.
//

#import "NSCachedURLResponse+LeakFix.h"
#import "UIDevice+machine.h"


@implementation NSCachedURLResponse (LeakFix)

#ifndef __clang_analyzer__

// The memory leak that plagued ioS 5 and 6 appears to have been fixed in iOS 7
// The hacky code in this method crashes on iOS 7, so use a quick method to determing
// if we are on iOS 6 or earlier.  In that case, still apply the hack, otherwise
// simply return the data that this method was wrapping
- (NSData *)responseData
{
    NSData *result = nil;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if ([UIDevice bcdSystemVersion] < 0x070000)
    {
        __unsafe_unretained NSData *first = self.data;
        NSInteger firstCount = CFGetRetainCount((__bridge CFTypeRef)first);
        __unsafe_unretained NSData *second = self.data;
        NSInteger secondCount = CFGetRetainCount((__bridge CFTypeRef)second);
        result = first;

        if (first == second)
        {
            if (firstCount != secondCount)
            {
                // this os build has the leak...  commence serious bullshit.

                // release our 2 total accesses that incurred a retain.
                CFRelease((__bridge CFTypeRef)result);
                CFRelease((__bridge CFTypeRef)result);
            }
        }
    }
    else
#endif
        result = self.data;

    return result;
}

#endif

@end
