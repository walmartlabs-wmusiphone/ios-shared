//
//  SDDragDropGestureRecognizer.m
//  testdrag
//
//  Created by Brandon Sneed on 8/23/11.
//  Copyright 2011-2013 SetDirection. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "SDDragDropGestureRecognizer.h"
#import "SDDragDropManager.h"

@interface SDDragDropGestureRecognizer()
@property (nonatomic, assign) UIView *currentDropTarget;
@end

@implementation SDDragDropGestureRecognizer

@synthesize dragView;
@synthesize dragViewDelegate;
@synthesize currentDropTarget;

- (id)init
{
    self = [super initWithTarget:self action:@selector(processAction:)];
    if (self) {
        // Initialization code here.
        self.delaysTouchesBegan = NO;
        self.cancelsTouchesInView = YES;
    }
    
    return self;
}


#pragma mark - Properties

- (void)setCurrentDropTarget:(UIView *)aDropTarget
{
    if (currentDropTarget != aDropTarget)
    {
        if (aDropTarget == nil)
        {
            if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragView:didLeaveTarget:)])
                [dragViewDelegate dragView:dragView didLeaveTarget:currentDropTarget];
        }

        currentDropTarget = aDropTarget;

        if (currentDropTarget != nil)
        {
            if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragView:didEnterTarget:)])
                [dragViewDelegate dragView:dragView didEnterTarget:currentDropTarget];
        }
    }
}

#pragma mark - Utilities

- (void)processAction:(SDDragDropGestureRecognizer *)gesture
{
    // do nothing.
//    SDLog(@"state in-action = %u", self.state);
    
}

- (void)startDrag
{
    if (!originalSuperview)
    {
        if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragViewDidStartDragging:)])
            [dragViewDelegate dragViewDidStartDragging:dragView];
        
        originalFrame = dragView.frame;
        originalSuperview = [dragView superview];
        [[SDDragDropManager sharedManager].dragContainer addSubview:dragView];
        
        CGPoint position = [self locationInView:[SDDragDropManager sharedManager].dragContainer];
        CGPoint newPosition = CGPointMake(position.x - touchOffset.x, position.y - touchOffset.y);
        originalCenterInContainer = newPosition;
        dragView.center = newPosition;
    }            
}

- (void)cancelDrag
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        dragView.center = originalCenterInContainer;
    } completion:^(BOOL finished) {
        dragView.frame = originalFrame;
        [originalSuperview addSubview:dragView];
        originalSuperview = nil;
    }];
    
    [self setCurrentDropTarget:nil];
}

- (void)dropOnTarget:(UIView<SDDropTargetProtocol> *)targetView
{
    if (targetView && [targetView respondsToSelector:@selector(dropTarget:canAcceptView:fromGestureRecognizer:)])
    {
        BOOL canDrop = [targetView dropTarget:targetView canAcceptView:dragView fromGestureRecognizer:self];
        if (!canDrop)
            [self cancelDrag];
    }
    
    BOOL shouldReturnToContainer = YES;
    if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragViewShouldReturnToOriginalContainer:)])
        shouldReturnToContainer = [dragViewDelegate dragViewShouldReturnToOriginalContainer:dragView];
    
    if (shouldReturnToContainer)
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            dragView.alpha = 0;
        } completion:^(BOOL finished) {
            dragView.frame = originalFrame;
            [originalSuperview addSubview:dragView];
            originalSuperview = nil;
            
            [UIView beginAnimations:nil context:nil];
            dragView.alpha = 1.0;
            [UIView commitAnimations];
        }];        
    }   
    
    if (targetView && [targetView respondsToSelector:@selector(dropTarget:droppedView:fromGestureRecognizer:)])
        [targetView dropTarget:targetView droppedView:self.dragView fromGestureRecognizer:self];
    
    [self setCurrentDropTarget:nil];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (void)setState:(UIGestureRecognizerState)state
{
    [super setState:state];
//    SDLog(@"state = %u", self.state);
    if (state == UIGestureRecognizerStateBegan)
    {
        [self performSelector:@selector(startDrag) withObject:nil afterDelay:0.1];
    }
    else
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed)
    {
        if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragViewDidEndDragging:)])
            [dragViewDelegate dragViewDidEndDragging:dragView];
    }
}

#pragma mark - Touch Handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	if (!self.enabled)
		return;
    CGPoint center = dragView.center;
    CGPoint startPosition = [self locationInView:[dragView superview]];
    touchOffset = CGPointMake(startPosition.x - center.x, startPosition.y - center.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
	if (!self.enabled)
		return;

    if (self.state == UIGestureRecognizerStateChanged)
    {
        BOOL superChanged = NO;
        if (!originalSuperview)
        {
            //if (dragViewDelegate && [dragViewDelegate respondsToSelector:@selector(dragViewDidStartDragging:)])
            //    [dragViewDelegate dragViewDidStartDragging:dragView];

            originalFrame = dragView.frame;
            originalSuperview = [dragView superview];
            [[SDDragDropManager sharedManager].dragContainer addSubview:dragView];
            superChanged = YES;
        }
        
        // position change was here.
        CGPoint position = [self locationInView:[SDDragDropManager sharedManager].dragContainer];
        CGPoint newPosition = CGPointMake(position.x - touchOffset.x, position.y - touchOffset.y);
                
        if (superChanged)
        {
            originalCenterInContainer = newPosition;
            dragView.center = newPosition;
        }

        // test to see if we're in our drop targets
        for (UIView *view in [SDDragDropManager sharedManager].dropTargets)
        {
            CGPoint positionInView = [self locationInView:view];
            if ([view pointInside:positionInView withEvent:nil])
            {
                // if we are, we should center the dragView position under their finger.
                // this allows for size/transform animations around the view's center point while
                // keeping said view under their finger.
                touchOffset = CGPointMake(0, 0);
                newPosition = CGPointMake(position.x - touchOffset.x, position.y - touchOffset.y);
                self.currentDropTarget = view;
                break;
            }
            else
                self.currentDropTarget = nil;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.05];
        [UIView setAnimationBeginsFromCurrentState:YES];
        dragView.center = newPosition;
        [UIView commitAnimations];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
	if (!self.enabled)
		return;
    
    BOOL dropped = NO;
    if (self.state == UIGestureRecognizerStateEnded && originalSuperview)
    {
        for (UIView<SDDropTargetProtocol> *view in [SDDragDropManager sharedManager].dropTargets)
        {
            CGPoint positionInView = [self locationInView:view];
            if ([view pointInside:positionInView withEvent:nil])
            {
                // send something to our delegate
                [self dropOnTarget:view];
                dropped = YES;
                break;
            }
        }
    }
    
    if (!dropped && originalSuperview)
        [self cancelDrag];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
	if (!self.enabled)
		return;
    if (originalSuperview)
        [self cancelDrag];
}

@end
