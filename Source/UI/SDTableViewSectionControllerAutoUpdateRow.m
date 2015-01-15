//
//  SDTableViewSectionControllerAutoUpdateRow.m
//  walmart
//
//  Created by Steve Riggins on 11/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTableViewSectionControllerAutoUpdateRow.h"
#import "SDTableViewSectionControllerAutoAlwaysUpdateRow.h"

@interface SDTableViewSectionControllerAutoUpdateRow()
@property (nonatomic, assign) NSInteger attributeHash;
@property (nonatomic, assign) NSUInteger internalHash;
@end

@implementation SDTableViewSectionControllerAutoUpdateRow

+ (instancetype)genericRowOne
{
    SDTableViewSectionControllerAutoUpdateRow *row = [[self alloc] initWithHash:1 attributeHash:0];
    return row;
}

+ (instancetype)genericAlwaysUpdateWithHash:(NSUInteger)hash
{
    SDTableViewSectionControllerAutoAlwaysUpdateRow *row = [[SDTableViewSectionControllerAutoAlwaysUpdateRow alloc] initWithHash:hash attributeHash:0];
    return row;
}

- (instancetype)initWithHash:(NSUInteger)hash attributeHash:(NSInteger)attributeHash
{
    if (self = [super init])
    {
        _attributeHash = attributeHash;
        _internalHash = hash;
    }
    return self;
}

- (instancetype)initWithHash:(NSUInteger)hash
{
    if (self = [super init])
    {
        _attributeHash = 0;
        _internalHash = hash;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    
    if (object == self)
    {
        isEqual = YES;
    }
    else if (object && ([[object class] isEqual:[self class]]) && ([object hash] == [self hash]))
    {
        isEqual = YES;
    }
    return isEqual;
}

- (NSUInteger)hash
{
    return self.internalHash;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.attributeHash=%zd", self.attributeHash];
    [description appendFormat:@", self.internalHash=%tu", self.internalHash];
    [description appendString:@">"];
    return description;
}


@end
