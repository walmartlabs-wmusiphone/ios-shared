//
//  SDImageButton.m
//  ipad
//
//  Created by Brandon Sneed on 7/13/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDImageButton.h"

@implementation SDImageButton

@synthesize image;
@synthesize selectedImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.selected)
        [selectedImage drawAtPoint:CGPointMake(0, 0)];
    else
        [image drawAtPoint:CGPointMake(0, 0)];//InRect:CGRectMake(0, 0, image.size.width, image.size.height)];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
    
    self.selected = YES;
    
    return result;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.selected = NO;
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    self.selected = NO;
}

@end
