//
//  SDHitButton.m
//  ios-shared

//
//  Created by Steve Riggins on 1/22/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDHitButton.h"
#import "UIView+SDExtensions.h"

@implementation SDHitButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hitInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _minimumHitSize = CGSizeMake(0, 0);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hitInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _minimumHitSize = CGSizeMake(0, 0);
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    
    if (!self.enabled || self.hidden)
    {
        pointInside = [super pointInside:point withEvent:event];
    }
    else if(UIEdgeInsetsEqualToEdgeInsets(self.hitInsets, UIEdgeInsetsZero) && (CGSizeEqualToSize(self.minimumHitSize, CGSizeZero)))
    {
        pointInside = [super pointInside:point withEvent:event];
    }
    else if (!UIEdgeInsetsEqualToEdgeInsets(self.hitInsets, UIEdgeInsetsZero))
    {
        
        CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.hitInsets);
        pointInside = CGRectContainsPoint(hitFrame, point);
    }
    else
    {
        CGFloat minW = MAX(self.width, self.minimumHitSize.width);
        CGFloat minH = MAX(self.height, self.minimumHitSize.height);
        
        CGFloat insetW = (self.width - minW) / 2.0;
        CGFloat insetH = (self.height - minH) / 2.0;
        CGRect hitFrame = CGRectInset(self.bounds, insetW, insetH);
        pointInside = CGRectContainsPoint(hitFrame, point);
    }
   
    return pointInside;
}

@end
