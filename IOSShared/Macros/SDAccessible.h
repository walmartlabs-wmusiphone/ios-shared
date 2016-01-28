//
//  SDAccessible.h
//  walmart
//
//  Created by Cody Garvin on 3/26/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Convenience definition for Appium testing to add accessibility only in those
/// cases when APPIUM is defined.
#if defined(APPIUM)
#define SDAccessible(view, accessibilityLabel)	\
    do {				\
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        [view setIsAccessibilityElement:YES]; \
        [view setAccessibilityLabel:accessibilityLabel]; \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#else
#define SDAccessible(view, x...) [view self]
#endif
