//
//  UIActivityIndicatorView+SDExtensions.m
//  SetDirection
//
//  Created by Brandon Sneed on 8/18/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "UIActivityIndicatorView+SDExtensions.h"

@implementation UIActivityIndicatorView (SDExtensions)

- (void)show
{
    self.hidden = NO;
    [self startAnimating];
    [UIView animateWithDuration:0.1 animations:^(void) {
        self.alpha = 1.0;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.1 animations:^(void) {
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self stopAnimating];
        self.hidden = YES;
    }];
}

@end
