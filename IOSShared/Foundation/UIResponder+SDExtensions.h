//
//  UIResponder+SDExtensions.h
//  SetDirection
//
//  Created by Steven Woolgar on 02/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder(machine)

/**
 Find the current first responder.
 */

- (instancetype)currentFirstResponder;

@end
