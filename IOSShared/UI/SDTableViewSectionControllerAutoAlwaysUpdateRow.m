//
//  SDTableViewSectionControllerAutoAlwaysUpdateRow.m
//  walmart
//
//  Created by Steve Cotner on 1/13/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import "SDTableViewSectionControllerAutoAlwaysUpdateRow.h"

@implementation SDTableViewSectionControllerAutoAlwaysUpdateRow

+ (NSInteger)incrementingAttributeHash
{
    static NSInteger hash = 0;
    return ++hash;
}

-(NSInteger)attributeHash
{
    NSInteger hash = [SDTableViewSectionControllerAutoAlwaysUpdateRow incrementingAttributeHash];
    return hash;
}

@end
