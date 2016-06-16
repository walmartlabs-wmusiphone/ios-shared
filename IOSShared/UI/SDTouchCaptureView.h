//
//  SDTouchCaptureView.h
//  SetDirection
//
//  Created by Andrew Finnell on 5/22/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SDTouchCaptureViewTouchBlock)(void);

@interface SDTouchCaptureView : NSObject

- (void) beginModalWithView:(UIView *)view clippingView:(UIView *)clippingView touchOutsideBlock:(SDTouchCaptureViewTouchBlock)block;
- (void) endModal;

- (CGRect) convertFrame:(CGRect)frame;

@end
