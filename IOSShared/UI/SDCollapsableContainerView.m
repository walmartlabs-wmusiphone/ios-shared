//
//  SDCollapsableContainerView.m
//
//  Created by Steven W. Riggins on 4/28/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//
//  Inspired by Jason Foreman & Tim Trautmann

#import "SDCollapsableContainerView.h"



@implementation SDCollapsableContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES; // This is needed to clip when collapsed
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.clipsToBounds = YES; // This is needed to clip when collapsed
    }
    return self;
}


- (void)didAddSubview:(UIView *)subview
{
    NSAssert(self.subviews.count < 2, @"Cannot add more than 1 subview to this view");
    [super didAddSubview:subview];
    [self p_applyContraints];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    [self p_applyContraints];
}

- (void)setCollapsed:(BOOL)collapsed
{
    if (collapsed != _collapsed)
    {
        _collapsed = collapsed;
        [self p_applyContraints];
    }
}

- (void)p_applyContraints
{
    // Remove all constraints on this container view.
    [self removeConstraints:self.constraints];
    
    // If collapsed, set a height of 0
    if (self.collapsed)
    {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    else
    {
        if (self.subviews.count)
        {
            UIView *view = self.subviews[0];
            
            [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[view]-(bottom)-|"
                                                                          options:0
                                                                          metrics:@{ @"top" : @(self.edgeInsets.top),
                                                                                     @"bottom" : @(self.edgeInsets.bottom) }
                                                                            views:NSDictionaryOfVariableBindings(view)]];
            
            [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[view]-(right)-|"
                                                                          options:0
                                                                          metrics:@{ @"left" : @(self.edgeInsets.left),
                                                                                     @"right" : @(self.edgeInsets.right) }
                                                                            views:NSDictionaryOfVariableBindings(view)]];
        }
    }
    [self setNeedsUpdateConstraints];
}

@end
