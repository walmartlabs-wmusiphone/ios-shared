//
//  SDDragDropGestureRecognizer.h
//  testdrag
//
//  Created by Brandon Sneed on 8/23/11.
//  Copyright 2011-2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDDragViewDelegate <NSObject>
@optional
- (void)dragViewDidStartDragging:(UIView *)view;
- (void)dragViewDidEndDragging:(UIView *)view;
- (BOOL)dragViewShouldReturnToOriginalContainer:(UIView *)view;
- (void)dragView:(UIView *)view didEnterTarget:(UIView *)dropTarget;
- (void)dragView:(UIView *)view didLeaveTarget:(UIView *)dropTarget;
@end


@interface SDDragDropGestureRecognizer : UILongPressGestureRecognizer
{
    UIView *originalSuperview;
    CGRect originalFrame;
    CGPoint originalCenterInContainer;
    CGPoint touchOffset;
    UIView *__unsafe_unretained currentDropTarget;
}

@property (nonatomic, unsafe_unretained) UIView *dragView;
@property (nonatomic, readonly, assign) UIView *currentDropTarget;
@property (nonatomic, unsafe_unretained) id<SDDragViewDelegate> dragViewDelegate;

@end
