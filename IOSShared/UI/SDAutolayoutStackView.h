//
//  SDAutolayoutStackView.h
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 SetDirection All rights reserved.
//

/*
 
 +---------------------------------------------------------------------------+
 | SDAutolayoutStackView                                                     |
 | +-----------------------------------------------------------------------+ |
 | | subview                                                               | |
 | |                                                                       | |
 | |                                                                       | |
 | +-----------------------------------------------------------------------+ |
 | +-----------------------------------------------------------------------+ |
 | | subview                                                               | |
 | |                                                                       | |
 | |                                                                       | |
 | +-----------------------------------------------------------------------+ |
 | +-----------------------------------------------------------------------+ |
 | | subview                                                               | |
 | |                                                                       | |
 | |                                                                       | |
 | +-----------------------------------------------------------------------+ |
 |                                     O                                     |
 |                                     O                                     |
 |                                     O                                     |
 +---------------------------------------------------------------------------+
 
 */

#import <UIKit/UIKit.h>

/**
 Similar to SDStackView, this class provides a view for displaying a set of views
 in an ordered visual stack using auto layout techniques.
 */


typedef NS_ENUM(NSUInteger, SDAutolayoutStackViewOrientation)
{
    SDAutolayoutStackViewOrientationVertical,
    SDAutolayoutStackViewOrientationHorizontal
};

@interface SDAutolayoutStackView : UIView

/**
 The inset margins for the subviews. (Default is 0 for each inset)
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 The gap between each subview. (Default is 0)
 */
@property (nonatomic, assign) CGFloat gap;


/**
 The orientation of the stack view. Vertical (default) or horizontal layout
 */
@property (nonatomic, assign) SDAutolayoutStackViewOrientation orientation;

@end
