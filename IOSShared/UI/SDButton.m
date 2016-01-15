//
//  SDButton.m
//  ios-shared
//
//  Created by Peter Marks on 1/20/14.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDButton.h"
#import "UIDevice+machine.h"

@implementation SDButton

- (void)drawRect:(CGRect)rect
{
    if ([UIDevice systemMajorVersion] < 7.0)
    {
        // don't do shit.
    }
    else
    {
        [super drawRect:rect];
    }
}

@end
