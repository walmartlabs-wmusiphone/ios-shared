//
//  UIScreen+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 9/19/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (SDExtensions)

/**
 Returns `YES` if the screen has a retina display. `NO` otherwise.
 */
+ (BOOL)hasRetinaDisplay;

@end
