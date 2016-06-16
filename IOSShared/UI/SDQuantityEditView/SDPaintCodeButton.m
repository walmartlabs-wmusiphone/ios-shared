//
//  SDPaintCodeButton.m
//
//  Created by ricky cancro on 12/20/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDPaintCodeButton.h"
#import "UIView+PaintCode.h"

@interface SDPaintCodeButton()
@property (nonatomic, strong) UIImage* normalStateImage;
@property (nonatomic, strong) UIImage* highlightedStateImage;
@property (nonatomic, strong) UIImage* disabledStateImage;
@end

@implementation SDPaintCodeButton

- (UIEdgeInsets)capInsets
{
    return UIEdgeInsetsZero;
}

- (void)createButtonStates
{
    self.normalStateImage = [[self imageForSelector:@selector(drawButtonNormal)] resizableImageWithCapInsets:[self capInsets]];
    self.highlightedStateImage = [[self imageForSelector:@selector(drawButtonHighlighted)] resizableImageWithCapInsets:[self capInsets]];
    self.disabledStateImage = [[self imageForSelector:@selector(drawButtonDisabled)] resizableImageWithCapInsets:[self capInsets]];

    [self setBackgroundImage:self.normalStateImage forState:UIControlStateNormal];
    [self setBackgroundImage:self.highlightedStateImage forState:UIControlStateHighlighted];
    [self setBackgroundImage:self.disabledStateImage forState:UIControlStateDisabled];
}



- (void)drawButtonDisabled
{
    
}

- (void)drawButtonNormal
{
    
}

- (void)drawButtonHighlighted
{
    
}

@end


