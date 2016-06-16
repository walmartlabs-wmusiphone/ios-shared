//
// Created by Steve Riggins on 3/10/14.
// Copyright (c) 2014 Walmart. All rights reserved.
//

#import "NSLayoutConstraint+SDExtensions.h"


@implementation NSLayoutConstraint(SDExtensions)
+ (NSArray *)constraintsFromViewToSuperView:(UIView *)childView withGap:(CGFloat)gap
{
    NSDictionary *viewsDictionary = @{@"childView" : childView};
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:2];

    NSString *formatString = [NSString stringWithFormat:@"H:|-%f-[childView]-%f-|", gap, gap];
    NSArray *theseConstraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    [constraints addObjectsFromArray:theseConstraints];

    formatString = [NSString stringWithFormat:@"V:|-%f-[childView]-%f-|", gap, gap];
    theseConstraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    [constraints addObjectsFromArray:theseConstraints];

    return [constraints copy];
}


@end