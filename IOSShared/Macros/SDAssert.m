//
//  SDAssert.m
//  walmart
//
//  Created by Cody Garvin on 11/19/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDAssert.h"

#if defined(DEBUG)
BOOL SDAssertProcess(void)
{
    static BOOL sInterceptAssert = NO;
    
    // Only check the environment variables once.
    static dispatch_once_t sDispatchOnce;
    dispatch_once(&sDispatchOnce, ^
                  {
                      NSDictionary* environmentDictionary = [[NSProcessInfo processInfo] environment];
                      BOOL isUnitTesting = [environmentDictionary[@"isUnitTesting"] boolValue];
                      if(isUnitTesting)
                          sInterceptAssert = YES;
                  });
    
    return sInterceptAssert;
}
#else
BOOL SDAssertProcess(void)
{
    return YES;
}
#endif
