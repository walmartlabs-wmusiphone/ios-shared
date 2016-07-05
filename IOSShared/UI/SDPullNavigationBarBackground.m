//
//  SDPullNavigationBarBackground.m
//  ios-shared

//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBarBackground.h"

@implementation SDPullNavigationBarBackground

- (void)setDelegate:(id<SDPullNavigationBarOverlayProtocol>)delegate
{
    if (delegate && [delegate respondsToSelector:@selector(drawOverlayRect:)])
    {
        _delegate = delegate;
        return;
    }

    _delegate = nil;
}

- (void)drawRect:(CGRect)rect
{
    [self.delegate drawOverlayRect:rect];
}

@end
