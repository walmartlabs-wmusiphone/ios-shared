//
//  UIView+PaintCode.h
//
//  Created by ricky cancro on 12/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PaintCodeDrawingBlock)();

@interface UIView(PaintCode)
- (UIImage *)imageWithBlock:(PaintCodeDrawingBlock)paintCodeBlock;
- (UIImage *)imageForSelector:(SEL)selector;
@end
