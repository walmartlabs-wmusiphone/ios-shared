//
//  UIResponder+SDExtensions.m
//  SetDirection
//
//  Created by Steven Woolgar on 02/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//
//  Based upon code by http://stackoverflow.com/users/1361982/vjk user.
//

#import "UIResponder+SDExtensions.h"
#import <objc/message.h>

static char const* const kSDFirstResponderKey = "kSDFirstResponderKey";

@implementation UIResponder(SDExtensions)

/**
 Find the current first responder.

 This little technique works around the lack of a way to determine the firstResponder.

 sendAction: knows the firstResponder internally, so we send the first responder an action to call our method.
 When it calls us, the supplied 'sender' variable is the firstResponder. Since we are a class extension, we have
 no ivar to communicate back, so we use an associated object. Once back in the method, we pull that out, nil it
 and return that value back to the caller.

 NB: Do not store the returned pointer. Do your work with it without storing it otherwise you might be accessing
 a pointer to an object that has been released.
 */

- (instancetype)currentFirstResponder
{
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:self forEvent:nil];
    id obj = objc_getAssociatedObject(self, kSDFirstResponderKey);
    objc_setAssociatedObject(self, kSDFirstResponderKey, nil, OBJC_ASSOCIATION_ASSIGN);

    return obj;
}

- (void)setCurrentFirstResponder:(id)responder
{
    objc_setAssociatedObject(self, kSDFirstResponderKey, responder, OBJC_ASSOCIATION_ASSIGN);
}

- (void)findFirstResponder:(id)sender
{
    [sender setCurrentFirstResponder:self];
}

@end
