//
//  NSShadow+SDExtensions.m
//  SetDirection
//
//  Created by Steven Woolgar on 02/06/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "NSShadow+SDExtensions.h"

@implementation NSShadow (SDExtensions)

/**
 A convenience method to create a shadow with clear color and no offset.
 */
+ (NSShadow*)noShadow
{
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, 0);

    return shadow;
}

@end
