//
//  SDAssert.h
//  walmart
//
//  Created by Cody Garvin on 11/19/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Determines if Assertions should run. Mainly a check for disabling during
/// unit testing.
///
/// @return - Returns YES if the assert should run.
BOOL SDAssertProcess(void);

/// Redefinition of NSAssert to allow checking if assertions should run while
/// in debug mode. @see SDAssertProcess
#if defined(DEBUG)
#define SDAssert(condition, desc, ...)	\
    do {				\
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition) && !SDAssertProcess()) {		\
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
            object:self file:[NSString stringWithUTF8String:__FILE__] \
            lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
        }				\
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#else
#define SDAssert(x...)
#endif