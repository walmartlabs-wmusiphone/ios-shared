//
//  SDPromise.h
//  asda
//
//  Created by Andrew Finnell on 12/16/14.
//  Copyright (c) 2014 Asda. All rights reserved.
//

#import <Foundation/Foundation.h>

// The block can return NSError to have failBlocks propogated. Any other returned
//  value, including nil, will fire any dependant promise thenBlocks.
typedef id (^SDPromiseThenBlock)(id dataObject);
typedef void (^SDPromiseFailBlock)(NSError *error);

@interface SDPromise : NSObject

@property (nonatomic, readonly) BOOL isFulfilled;

// Consumer interface. The returned SDPromise is the promise for the result of
//  the thenBlock. This allows you to easily chain promise results.
- (SDPromise *) then:(SDPromiseThenBlock)block;
- (void) failed:(SDPromiseFailBlock)block;

// Producer interface
- (void) resolve:(id)dataObject;
- (void) reject:(NSError *)error;

@end

