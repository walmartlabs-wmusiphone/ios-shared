//
// Created by Steve Riggins on 3/10/14.
// Copyright (c) 2014 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSLayoutConstraint(SDExtensions)

/*
 * Return an array of constraints between the childView and its superView for the leading edge, trailing edge, top edge and bottom edge with a specified gap
 *
 * @param childView The view to create the constraints for
 * @param gap a GGFloat gap to use between the childView and its superView
 *
 * @return NSArray of constraints
 */
+ (NSArray *)constraintsFromViewToSuperView:(UIView *)childView withGap:(CGFloat)gap;
@end