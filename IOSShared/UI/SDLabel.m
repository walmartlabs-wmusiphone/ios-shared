//
//  SDLabel.m
//  SetDirection
//
//  Created by Sam Grover on 3/5/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDLabel.h"
#import "UIDevice+machine.h"

@implementation SDLabel

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (CGFloat)textHeight
{
    if (self.text == nil)
        return 0;

    CGSize theSize = CGSizeZero;

    if([UIDevice systemVersionGreaterThanOrEqualToVersion:@"7"])
    {
        NSStringDrawingContext* context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = self.minimumScaleFactor;
        theSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, INFINITY)
                                          options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName : self.font }
                                          context:context].size;
    }
    else
    {
        theSize = [self.text sizeWithFont:self.font
                        constrainedToSize:CGSizeMake(self.frame.size.width, INFINITY)
                            lineBreakMode:self.lineBreakMode];
    }

    return theSize.height;
}

#pragma clang diagnostic pop

- (void)setText:(NSString *)argText
{
	[super setText:argText];
	CGFloat height = [self textHeight];
	CGRect theFrame = self.frame;
	theFrame.size.height = height;
	self.frame = theFrame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = [self textHeight];
	return size;
}

@end
