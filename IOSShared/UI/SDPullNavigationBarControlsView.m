//
//  SDPullNavigationBarControlsView.m
//  ios-shared
//
//  This is a simple list of controls that live in the pullnav.
//
//  Created by Steven Woolgar on 12/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBarControlsView.h"
#import "UIView+SDExtensions.h"

@implementation SDPullNavigationBarControlsView

- (instancetype)initWithEdge:(UIRectEdge)edge
{
    NSAssert(edge == UIRectEdgeLeft || edge == UIRectEdgeRight, @"Only left or right edges are supported.");
    
    CGFloat defaultWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 200.0f : 40.0f;
    self = [super initWithFrame:(CGRect){ CGPointZero, { defaultWidth, 44.0f } }];
    if( self != nil )
    {
        self.backgroundColor = [UIColor clearColor];
        _edge = edge;

        // This is temporary. It is the right idea for the controls to grow to use the space up to
        // the title, but this is making it shrink the title and cause the controls to no longer take taps.
        // Needs further study. SW:2014-03-26

        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

- (void)layoutWithBarItems:(NSArray*)barItems
{
    self.barItems = barItems;

    NSArray* subviews = [self.subviews copy];
    for(UIControl* subview in subviews)
        [subview removeFromSuperview];

    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fitSize = [super sizeThatFits:size];

    CGFloat fitWidth = 0.0f;
    for(UIControl* control in self.barItems)
    {
        fitWidth += control.size.width;
    }

    fitSize.width = fitWidth;

    return fitSize;
}

// Layout from left to right for the edge == UIRectEdgeLeft and from right to left for the edge == UIRectEdgeRight

- (void)layoutSubviews
{
    CGFloat currentX = self.edge == UIRectEdgeLeft ? 0.0f : self.size.width;
    for(UIControl* control in self.barItems)
    {
        if(self.edge == UIRectEdgeRight)
            currentX -= control.size.width;

        control.frame = (CGRect){ { currentX, self.size.height * 0.5f - control.size.height * 0.5f }, control.size };
        [self addSubview:control];

        if(self.edge == UIRectEdgeLeft)
            currentX += control.size.width;
    }
}

#pragma mark - BarItems API

- (void)addBarItem:(UIView*)view
{
    if(self.barItems == nil)
        self.barItems = [NSArray arrayWithObject:view];
    else
        self.barItems = [self.barItems arrayByAddingObject:view];
    [self layoutWithBarItems:self.barItems];
}

- (void)addBarItemSpacerWithWidth:(CGFloat)spacerWidth
{
    UIView* spacer = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { spacerWidth, 2.0f }}];

    if(self.barItems == nil)
        self.barItems = [NSArray arrayWithObject:spacer];
    else
        self.barItems = [self.barItems arrayByAddingObject:spacer];

    [self layoutWithBarItems:self.barItems];
}

@end
