//
//  SDStackView.m
//  SDStackViewTest
//
//  Created by Joel Bernstein on 7/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDStackView.h"

@implementation SDStackView

@synthesize stackItemViews = _stackItemViews;
@synthesize touchInset = _touchInset;

-(void)setStackItemViews:(NSArray *)stackItemViews
{
    _stackItemViews = [stackItemViews copy];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(UIView* itemView in stackItemViews.reverseObjectEnumerator)
    {
        [self addSubview:itemView];
    }

    self.contentSize = CGSizeMake(self.bounds.size.width * stackItemViews.count, self.bounds.size.height);
    
    [self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

-(void)layoutSubviews
{
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    for(NSUInteger i = 0; i < self.stackItemViews.count; i++)
    {
        CGPoint idealCenter = CGPointMake(center.x + i * self.bounds.size.width, center.y);
        
        CGPoint realCenter = CGPointMake(MIN(idealCenter.x, self.contentOffset.x + center.x), idealCenter.y);
        
        [[self.stackItemViews objectAtIndex:i] setCenter:i == 0 ? idealCenter : realCenter];
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, self.touchInset), point);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
