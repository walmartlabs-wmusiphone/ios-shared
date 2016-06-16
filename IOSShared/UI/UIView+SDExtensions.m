//
//  UIView+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "UIView+SDExtensions.h"
#import "UIDevice+machine.h"
#import "SDLog.h"

@implementation UIView (SDExtensions)

- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset
{
	self.frame = CGRectMake(self.frame.origin.x,
							argView.frame.origin.y + argView.frame.size.height + argOffset,
							self.frame.size.width,
							self.frame.size.height);
}

- (void)setFrameOriginY:(CGFloat)newY
{
    self.y = newY;
}

- (void)setFrameOriginX:(CGFloat)newX
{
    self.x = newX;
}

- (void)setIntegralCenter:(CGPoint)integralCenter
{
    self.center = integralCenter;
    self.frame = CGRectIntegral(self.frame);
}

- (CGPoint)integralCenter
{
	CGRect integralFrame = CGRectIntegral(self.frame);
    CGPoint centerPoint = CGPointMake(integralFrame.size.width * 0.5, integralFrame.size.height * 0.5);
	return centerPoint;
}

- (void)setIntegralFrame:(CGRect)viewFrame
{
	self.frame = CGRectIntegral(viewFrame);
}

- (CGRect)integralFrame
{
	return CGRectIntegral(self.frame);
}

- (id)firstSubviewOfClass:(Class)aViewClass
{
	NSArray *subs = [self subviews];
	id aView = nil;
	
	NSEnumerator *e = [subs objectEnumerator];
	while((aView = [e nextObject]))
	{
		if([aView isKindOfClass: aViewClass])
		{
			return aView;
		}
	}
	
	return nil;
}

- (UIView*)nearestAncestor:(UIView*)distantSubview
{
    for (UIView *view in [self subviews]) {
        if ([distantSubview isDescendantOfView:view]) {
            return view;
        }
    }
    return nil;
}

- (void)setX:(CGFloat)x
{
    CGRect f = self.frame;
    f.origin.x = x;
    self.frame = f;
}

- (void)setY:(CGFloat)y
{
    CGRect f = self.frame;
    f.origin.y = y;
    self.frame = f;
}

- (void)setWidth:(CGFloat)width
{
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (void)setHeight:(CGFloat)height;
{
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect f = self.frame;
    f.origin = origin;
    self.frame = f;
}

- (void)setSize:(CGSize)size;
{
    CGRect f = self.frame;
    f.size = size;
    self.frame = f;
}


- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y;
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGSize)size
{
    return self.frame.size;
}

- (UIView *)snapshot
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_1
    // if we're on ios7, use the system's snapshoView.
    if ([UIDevice bcdSystemVersion] >= 0x070000 && [self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        return [self snapshotViewAfterScreenUpdates:NO];
#endif
    
    // otherwise, we're doing backwards compatibility to 6.
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.layer.contents = (id)[self screenshot].CGImage;
    return view;
}

- (UIView *)snapshotAfterScreenUpdates:(BOOL)applyUpdates
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_1
    // if we're on ios7, use the system's snapshoView.
    if ([UIDevice bcdSystemVersion] >= 0x070000 && [self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        return [self snapshotViewAfterScreenUpdates:applyUpdates];
#endif
    
    // otherwise, we're doing backwards compatibility to 6.
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.layer.contents = (id)[self screenshot].CGImage;
    return view;
}

- (UIImage *)screenshot
{
    CGFloat currentScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, currentScale);

    UIImage *result = nil;

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        // renderInContext renders in the coordinate space of the layer.

        // apply the layer's geometry to the graphics context
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, self.center.x, self.center.y);
        CGContextConcatCTM(context, self.transform);
        CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);

        // Render the layer hierarchy to the current context

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_1
        // if we're on iOS 7, use the fast, system version.
        if ([UIDevice bcdSystemVersion] >= 0x070000 && [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
            [self drawViewHierarchyInRect:self.frame afterScreenUpdates:YES];
        else
#endif
            [self.layer renderInContext:context];

        // Restore the context
        CGContextRestoreGState(context);

        result = UIGraphicsGetImageFromCurrentImageContext();
    }
    else
        SDLog(@"Attempting to capture a screenshot of view without a graphics context!");

    return result;
}

@end
