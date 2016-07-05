//
//  SDMultilineLabel.m
//  LayoutTests
//
//  Created by Steve Riggins on 1/24/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDMultilineLabel.h"

@implementation SDMultilineLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Not happy with self. here
        self.numberOfLines = 0;
    }
    return self;
}

// This allows the label to lay out properly with auto layout. It works on iOS 7 and iOS 8.1+
- (void)layoutSubviews
{
    self.preferredMaxLayoutWidth = self.frame.size.width;
    [super layoutSubviews];
}

// The use of setFrame/setBounds is for iOS 8.0, where layoutSubviews is not called, oddly enough.
- (void)setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.preferredMaxLayoutWidth = CGRectGetWidth(frame);
}

- (void)setBounds:(CGRect)bounds;
{
    [super setBounds:bounds];
    self.preferredMaxLayoutWidth = CGRectGetWidth(bounds);
}

@end
