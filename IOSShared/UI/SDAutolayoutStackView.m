//
//  SDAutolayoutStackView.m
//  StackedContainerViewDemo
//
//  Created by Tim Trautmann on 1/28/14.
//  Copyright (c) 2014 SetDirection All rights reserved.
//

#import "SDAutolayoutStackView.h"

@implementation SDAutolayoutStackView

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    [self p_applyConstraints];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    [self p_applyConstraints];
}

- (void)p_applyConstraints
{
    // Remove all constraints on this container view.
    [self removeConstraints:self.constraints];
    
    NSLayoutConstraint *lastConstraint = nil;
    UIView *previousView = nil;
    
    for (UIView *view in self.subviews)
    {
        switch (self.orientation) {
            case SDAutolayoutStackViewOrientationVertical:
            {
                // If this is the first (topmost) view, attach it to the parent view at the top.
                if ([self.subviews.firstObject isEqual:view])
                {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:self.edgeInsets.top]];
                }
                // Otherwise attach this view to the previous view's bottom.
                else
                {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:previousView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:self.gap]];
                }
                
                // All child views have leading and trailing constraints.
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[view]-(right)-|"
                                                                             options:0
                                                                             metrics:@{ @"left" : @(self.edgeInsets.left),
                                                                                        @"right" : @(self.edgeInsets.right) }
                                                                               views:NSDictionaryOfVariableBindings(view)]];
                
                // If there is already a last constraint, remove it.
                if (lastConstraint)
                    [self removeConstraint:lastConstraint];
                
                
                // Add the last constraint to attach view to the bottom of container
                // view.
                lastConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:-self.edgeInsets.bottom];
                
                [self addConstraint:lastConstraint];

                break;
            }
            case SDAutolayoutStackViewOrientationHorizontal:
            {
                // If this is the first (leading) view, attach it to the parent view's leading side.
                if ([self.subviews.firstObject isEqual:view])
                {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:self.edgeInsets.top]];
                }
                // Otherwise attach this view to the previous view's trailing side.
                else
                {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:previousView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:self.gap]];
                }
                
                // All child views have top and bottom constraints.
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[view]-(bottom)-|"
                                                                             options:0
                                                                             metrics:@{ @"top" : @(self.edgeInsets.top),
                                                                                        @"bottom" : @(self.edgeInsets.bottom) }
                                                                               views:NSDictionaryOfVariableBindings(view)]];
                
                // If there is already a last constraint, remove it.
                if (lastConstraint)
                    [self removeConstraint:lastConstraint];
                
                
                // Add the last constraint to attach view to the trailing edge of container
                // view.
                lastConstraint = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-self.edgeInsets.right];
                
                [self addConstraint:lastConstraint];
                
                break;
            }
            default:
                break;
        }
        
        // Set this view to previousView for next iteration of this loop.
        previousView = view;
    }
    
    [self setNeedsUpdateConstraints];
}

@end
