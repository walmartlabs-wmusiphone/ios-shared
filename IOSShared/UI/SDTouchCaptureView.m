//
//  SDTouchCaptureView.m
//  SetDirection
//
//  Created by Andrew Finnell on 5/22/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDTouchCaptureView.h"
#import "SDMacros.h"

@interface SDTouchCaptureView ()

@property (nonatomic, weak) UIView *parentView;

@property (nonatomic, strong) NSArray *parentViewConstraints;
@property (nonatomic, assign) BOOL modalViewTranslateAutoresizeMasksIntoConstraints;
@property (nonatomic, assign) CGRect modalViewFrame;

@property (nonatomic, weak) UIView *modalView;
@property (nonatomic, weak) UIView *touchCaptureView;
@property (nonatomic, copy) SDTouchCaptureViewTouchBlock dismissBlock;

@end

@implementation SDTouchCaptureView

- (void) beginModalWithView:(UIView *)modalView clippingView:(UIView *)clippingView touchOutsideBlock:(SDTouchCaptureViewTouchBlock)block
{
    if (self.touchCaptureView == nil)
    {
        [self saveParentViewState:modalView];
        
        UIView *rootView = [[[modalView window] subviews] lastObject];
        
        UIView *touchCaptureView = [[UIView alloc] initWithFrame:[rootView bounds]];
        [touchCaptureView setBackgroundColor:[UIColor clearColor]];
        [touchCaptureView addGestureRecognizer:[self dismissRecognizer]];
        [rootView addSubview:touchCaptureView];
        
        CGRect visualClippingFrame = [clippingView convertRect:[clippingView bounds] toView:touchCaptureView];
        UIView *visualClippingView = [[UIView alloc] initWithFrame:visualClippingFrame];
        [visualClippingView setBackgroundColor:[UIColor clearColor]];
        [visualClippingView setClipsToBounds:YES];
        [visualClippingView addGestureRecognizer:[self dismissRecognizer]];
        [touchCaptureView addSubview:visualClippingView];
        
        CGRect rootFrame = [modalView convertRect:[modalView bounds] toView:rootView];
        [visualClippingView addSubview:modalView];
        CGRect frame = [rootView convertRect:rootFrame toView:visualClippingView];
        
        if ( self.modalViewTranslateAutoresizeMasksIntoConstraints )
        {
            modalView.frame = frame;
        }
        else
        {
            [UIView performWithoutAnimation:^{
                NSDictionary *visualClippingMetrics = @{@"xOffset": @(visualClippingFrame.origin.x), @"yOffset": @(visualClippingFrame.origin.y), @"width": @(visualClippingFrame.size.width), @"height": @(visualClippingFrame.size.height)};
                [touchCaptureView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xOffset)-[visualClippingView(width)]" options:0 metrics:visualClippingMetrics views:NSDictionaryOfVariableBindings(visualClippingView)]];
                [touchCaptureView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(yOffset)-[visualClippingView(height)]" options:0 metrics:visualClippingMetrics views:NSDictionaryOfVariableBindings(visualClippingView)]];

                NSDictionary *metrics = @{@"xOffset": @(frame.origin.x), @"yOffset": @(frame.origin.y), @"width": @(frame.size.width), @"height": @(frame.size.height)};
                [visualClippingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xOffset)-[modalView(width)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(modalView)]];
                [visualClippingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(yOffset)-[modalView(height)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(modalView)]];
            }];
        }
        
        self.modalView = modalView;
        self.touchCaptureView = touchCaptureView;
        self.dismissBlock = block;
    }
}

- (void) endModal
{
    @strongify(self.touchCaptureView, touchCaptureView);
    
    if ( touchCaptureView != nil )
    {
        [self restoreParentViewState:self.modalView];
        
        [touchCaptureView removeFromSuperview];
        self.modalView = nil;
        self.dismissBlock = nil;
    }
}

- (UIGestureRecognizer*)dismissRecognizer
{
    return [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGesture:)];
}

- (void) dismissGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    @strongify(self.modalView, modalView);
    
    CGPoint location = [gestureRecognizer locationInView:modalView.superview];
    
    if ( !CGRectContainsPoint(modalView.frame, location) && self.dismissBlock != nil )
    {
        self.dismissBlock();
    }
}

- (void) saveParentViewState:(UIView *)modalView
{
    UIView *parentView = [modalView superview];
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in [parentView constraints])
    {
        if ( constraint.firstItem == modalView || constraint.secondItem == modalView )
            [constraints addObject:constraint];
    }
    
    self.parentView = parentView;
    self.parentViewConstraints = constraints;
    self.modalViewTranslateAutoresizeMasksIntoConstraints = modalView.translatesAutoresizingMaskIntoConstraints;
    self.modalViewFrame = modalView.frame;
}

- (void) restoreParentViewState:(UIView *)modalView
{
    @strongify(self.parentView, parentView);
    
    [parentView addSubview:modalView];
    
    if ( self.modalViewTranslateAutoresizeMasksIntoConstraints )
    {
        modalView.frame = self.modalViewFrame;
    }
    else
    {
        [parentView addConstraints:self.parentViewConstraints];
    }
    
    self.parentView = nil;
    self.parentViewConstraints = nil;
}

- (CGRect) convertFrame:(CGRect)frame
{
    @strongify(self.parentView, parentView);
    CGRect convertedFrame = frame;
    
    if ( parentView != nil )
    {
        @strongify(self.modalView, modalView);
        UIView *superview = [modalView superview];
        
        convertedFrame = [parentView convertRect:frame toView:superview];
    }
    
    return convertedFrame;
}
@end
