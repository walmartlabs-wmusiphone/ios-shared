//
//  UIView+PaintCode.m
//
//  Created by ricky cancro on 12/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIView+PaintCode.h"
#import "UIView+SDExtensions.h"

@implementation UIView(PaintCode)

- (UIImage*)imageForSelector:(SEL)selector
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
	
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)imageWithBlock:(PaintCodeDrawingBlock)paintCodeBlock
{
    UIImage* result = nil;
    if (paintCodeBlock)
    {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
        paintCodeBlock();
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return result;
}

@end
