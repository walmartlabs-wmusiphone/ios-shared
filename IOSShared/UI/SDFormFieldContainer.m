//
//  SDFormFieldContainer.m
//  ios-shared

//
//  Created by Brandon Sneed on 1/16/14.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDFormFieldContainer.h"
#import "UIColor+SDExtensions.h"

@implementation SDFormFieldContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self configureView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self configureView];
    return self;
}

- (void)configureView
{
    self.separatorColor = [UIColor colorWith8BitRed:200 green:199 blue:204 alpha:1.0];
    self.separatorInset = 0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [self.separatorColor set];

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 1.0);
    CGContextMoveToPoint(currentContext, self.separatorInset, self.bounds.size.height);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(currentContext);
}


@end
