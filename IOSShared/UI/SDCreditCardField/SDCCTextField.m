//
//  SDCCTextField.m
//
//  Created by Michaël Villar on 03/20/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "SDCCTextField.h"
#import "SDMacros.h"

static NSString* const kSDTextFieldSpaceChar = @"\u200B";

@implementation SDCCTextField

+ (NSString*)textByRemovingUselessSpacesFromString:(NSString*)string
{
    return [string stringByReplacingOccurrencesOfString:kSDTextFieldSpaceChar withString:@""];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.text = kSDTextFieldSpaceChar;
        [self addObserver:self forKeyPath:@"text" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"text"];
}

- (void)drawPlaceholderInRect:(CGRect)rect {}

- (void)drawRect:(CGRect)rect
{
    if(self.text.length == 0 || [self.text isEqualToString:kSDTextFieldSpaceChar])
    {
        CGRect placeholderRect = self.bounds;
        [super drawPlaceholderInRect:placeholderRect];
    }
    else
    {
        [super drawRect:rect];
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if([keyPath isEqualToString:@"text"] && object == self)
    {
        if(self.text.length == 0)
        {
            @strongify(self.delegate, delegate);

            if([delegate respondsToSelector:@selector(ccTextFieldDidBackSpaceWhileTextIsEmpty:)])
            {
                [delegate performSelector:@selector(ccTextFieldDidBackSpaceWhileTextIsEmpty:) withObject:self];
            }
            self.text = kSDTextFieldSpaceChar;
        }

        [self setNeedsDisplay];
    }
}

@end
