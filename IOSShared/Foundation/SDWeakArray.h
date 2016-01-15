//
//  SDWeakArray.h
//  SetDirection
//
//  Created by Andrew Finnell on 10/14/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

// Like NSMutableArray, except objects are boxed with weak pointers.
@interface SDWeakArray : NSObject <NSCopying, NSFastEnumeration>

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (NSUInteger)indexOfObject:(id)anObject;
- (void)removeObject:(id)anObject;

- (void) compact;


@end
