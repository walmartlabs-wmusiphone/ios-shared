//
//  SDWeakArray.m
//  SetDirection
//
//  Created by Andrew Finnell on 10/14/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWeakArray.h"

@interface SDWeakPointer : NSObject

- (instancetype) initWithObject:(id)object;

@property (nonatomic, weak) id object;

@end

@implementation SDWeakPointer

- (instancetype) initWithObject:(id)object
{
    self = [super init];
    if ( self != nil )
    {
        _object = object;
    }
    return self;
}

- (NSUInteger) hash
{
    return [_object hash];
}

- (BOOL) isEqual:(id)object
{
    BOOL isEqual = NO;
    if ( [object isKindOfClass:[SDWeakPointer class]] )
    {
        SDWeakPointer *other = object;
        isEqual = [_object isEqual:other->_object];
    }
    return isEqual;
}

@end

@implementation SDWeakArray {
    NSMutableArray *_boxedObjects;
}

- (instancetype) init
{
    self = [super init];
    if ( self != nil )
    {
        _boxedObjects = [NSMutableArray array];
    }
    return self;
}

- (NSUInteger)count
{
    return [_boxedObjects count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    SDWeakPointer *boxedValue = _boxedObjects[index];
    return boxedValue.object;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    SDWeakPointer *boxedValue = [_boxedObjects objectAtIndexedSubscript:idx];
    return boxedValue.object;
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    [_boxedObjects setObject:[[SDWeakPointer alloc] initWithObject:obj] atIndexedSubscript:idx];
}

- (void)addObject:(id)anObject
{
    [_boxedObjects addObject:[[SDWeakPointer alloc] initWithObject:anObject]];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [_boxedObjects insertObject:[[SDWeakPointer alloc] initWithObject:anObject] atIndex:index];
}

- (void)removeLastObject
{
    [_boxedObjects removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_boxedObjects removeObjectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    __block NSUInteger foundIndex = NSNotFound;
    [_boxedObjects enumerateObjectsUsingBlock:^(SDWeakPointer *obj, NSUInteger idx, BOOL *stop)
    {
        if ( [obj.object isEqual:anObject] )
        {
            foundIndex = idx;
            *stop = YES;
        }
    }];
    return foundIndex;
}

- (void)removeObject:(id)anObject
{
    NSUInteger index = [self indexOfObject:anObject];
    if ( index != NSNotFound )
        [self removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_boxedObjects replaceObjectAtIndex:index withObject:[[SDWeakPointer alloc] initWithObject:anObject]];
}

- (void) compact
{
    NSMutableArray *indicesToRemove = [NSMutableArray array];
    
    [_boxedObjects enumerateObjectsUsingBlock:^(SDWeakPointer *obj, NSUInteger idx, BOOL *stop)
    {
        if ( obj.object == nil )
            [indicesToRemove addObject:@(idx)];
    }];
    
    NSEnumerator *enumerator = [indicesToRemove reverseObjectEnumerator];
    for (NSNumber *index in enumerator)
        [_boxedObjects removeObjectAtIndex:[index unsignedIntegerValue]];
}

- (id)copyWithZone:(NSZone *)zone
{
    SDWeakArray *copy = [[SDWeakArray allocWithZone:zone] init];
    for (id obj in self)
        [copy addObject:obj];
    return copy;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    static unsigned long sMutations = 1;
    
    NSUInteger count = 0;
    
    switch (state->state) {
        case 0: // First run case
            state->mutationsPtr = &sMutations;
            state->state = 1;
            state->extra[0] = 0; // Offset into the values array
            // FALLTHROUGH
            
        case 1: // Not the first run case
            state->itemsPtr = buffer;
            count = MIN([_boxedObjects count] - state->extra[0], len);
            for (NSUInteger i = 0; i < count; ++i ) {
                SDWeakPointer *boxedValue = _boxedObjects[state->extra[0] + i];
                state->itemsPtr[i] = boxedValue.object;
            }
            state->extra[0] += count;
            break;
    }
    
    return count;
}

@end
