//
//  SDStackView.h
//  SDStackViewTest
//
//  Created by Joel Bernstein on 7/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This class provides a view for displaying a set of views in an ordered visual stack.
 */

@interface SDStackView : UIScrollView

/**
 The ordered list of the views to show in the stack. The 0th one is at the top of the stack.
 */
@property (nonatomic, copy) NSArray* stackItemViews;

/**
 The inset by which to alter the area where touches are registered for this view.
 */
@property (nonatomic, assign) UIEdgeInsets touchInset;

@end
