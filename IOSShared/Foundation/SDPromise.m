//
//  SDPromise.m
//  asda
//
//  Created by Andrew Finnell on 12/16/14.
//  Copyright (c) 2014 Asda. All rights reserved.
//

#import "SDPromise.h"

typedef NS_ENUM(NSUInteger, SDPromiseState)
{
    SDPromiseStatePending,
    SDPromiseStateFulfilled,
    SDPromiseStateRejected
};

@interface SDPromiseThen : NSObject

- (instancetype) initWithBlock:(SDPromiseThenBlock)block resultPromise:(SDPromise *)promise;

- (void) resolve:(id)result;

@end

#pragma mark -

@interface SDPromise ()

@property (nonatomic, strong) NSMutableArray *thenBlocks;
@property (nonatomic, strong) NSMutableArray *failedBlocks;
@property (nonatomic, assign) SDPromiseState state;
@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *error;

@end

@implementation SDPromise

- (instancetype) init
{
    self = [super init];
    if ( self != nil )
    {
        _thenBlocks = [NSMutableArray array];
        _failedBlocks = [NSMutableArray array];
    }
    return self;
}

- (BOOL) isFulfilled
{
    BOOL isFulfilled = NO;
    @synchronized(self)
    {
        isFulfilled = self.state != SDPromiseStatePending;
    }
    return isFulfilled;
}

// Consumer interface
- (SDPromise *) then:(SDPromiseThenBlock)block
{
    SDPromise *resultPromise = [[SDPromise alloc] init];
    SDPromiseThen *then = [[SDPromiseThen alloc] initWithBlock:block resultPromise:resultPromise];
    
    @synchronized(self)
    {
        if ( self.state == SDPromiseStateFulfilled )
        {
            // Already done, but don't call back right now
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [then resolve:self.result];
            });
        }
        else if ( self.state == SDPromiseStateRejected )
        {
            // Already done, and will never be called, so don't even bother
            //  This space intentionally left blank.
        }
        else
        {
            // Nothing's happened yet, so wait
            [self.thenBlocks addObject:then];
        }
    }
    
    return resultPromise;
}

- (void) failed:(SDPromiseFailBlock)block
{
    @synchronized(self)
    {
        if ( self.state == SDPromiseStateFulfilled )
        {
            // Already done, and failed will never be called, so don't even
            //  add the block.
        }
        else if ( self.state == SDPromiseStateRejected )
        {
            // Already done, but don't call back immediately
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.error);
            });
        }
        else
        {
            // Nothing's happened yet, so wait
            [self.failedBlocks addObject:[block copy]];
        }
    }
}

// Producer interface
- (void) resolve:(id)dataObject
{
    NSArray *thenBlocks = [self markResolvedWithResult:dataObject];
    if ( thenBlocks != nil )
    {
        for (SDPromiseThen *then in thenBlocks)
            [then resolve:dataObject];
    }
}

- (NSArray *) markResolvedWithResult:(id)dataObject
{
    NSArray *thens = nil;
    
    @synchronized(self)
    {
        if ( self.state == SDPromiseStatePending )
        {
            self.state = SDPromiseStateFulfilled;
            self.result = dataObject;
            thens = [self.thenBlocks copy];
            [self.thenBlocks removeAllObjects];
            [self.failedBlocks removeAllObjects];
        }
    }

    return thens;
}

- (void) reject:(NSError *)error
{
    NSArray *failedBlocks = [self markRejectedWithError:error];
    if ( failedBlocks != nil )
    {
        for (SDPromiseFailBlock failBlock in failedBlocks)
            failBlock(error);
    }
}

- (NSArray *) markRejectedWithError:(NSError *)error
{
    NSArray *failedBlocks = nil;
    
    @synchronized(self)
    {
        if ( self.state == SDPromiseStatePending )
        {
            self.state = SDPromiseStateRejected;
            self.error = error;
            failedBlocks = [self.failedBlocks copy];
            [self.thenBlocks removeAllObjects];
            [self.failedBlocks removeAllObjects];
        }
    }
    
    return failedBlocks;
}

@end

#pragma mark -

@implementation SDPromiseThen {
    SDPromiseThenBlock _block;
    SDPromise *_resultPromise;
}

- (instancetype) initWithBlock:(SDPromiseThenBlock)block resultPromise:(SDPromise *)promise
{
    self = [super init];
    if ( self != nil )
    {
        _block = [block copy];
        _resultPromise = promise;
    }
    return self;
}

- (void) resolve:(id)result
{
    id resultOfBlock = _block(result);
    if ( resultOfBlock != nil && [resultOfBlock isKindOfClass:[NSError class]] )
    {
        NSError *error = resultOfBlock;
        [_resultPromise reject:error];
    }
    else if ( resultOfBlock != nil && [resultOfBlock isKindOfClass:[SDPromise class]] )
    {
        // Chain the promise we returned to the client, to the one the then block
        //  just returned.
        SDPromise *promiseOfBlock = resultOfBlock;
        [promiseOfBlock then:^id(id dataObject) {
            [_resultPromise resolve:dataObject];
            return nil;
        }];
        [promiseOfBlock failed:^(NSError *error) {
            [_resultPromise reject:error];
        }];
    }
    else
    {
        [_resultPromise resolve:resultOfBlock];
    }
}

@end
