//
//  SDCompletionGroup.m
//  SetDirection
//
//  Created by Joel Bernstein on 02/08/2011.
//  Copyright 2011-2014 Joel Bernstein. All rights reserved.
//

#import "SDCompletionGroup.h"


@interface SDCompletionGroup ()

@property (nonatomic, retain) NSMutableSet* tokens;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) NSInteger lastToken;

@end



@implementation SDCompletionGroup

- (void)setCompletion:(void (^)())completion
{
    _completion = [completion copy];
    
    [self checkTokens];
}

- (instancetype)init
{
    self = [super init];

    if(self != nil)
    {
        _tokens = [NSMutableSet set];
        _queue = dispatch_queue_create("SDCompletionGroup", NULL);
    }
    
    return self;
}

- (id)acquireToken
{
    __block id token;
    
    dispatch_sync(self.queue, ^
    {
        token = @(++self.lastToken);
        [self.tokens addObject:token];
    });
        
    return token;
}

- (void)acquireTokenWithCompletion:(void(^)(id token))completion
{
    dispatch_async(self.queue, ^
    {
        id token = @(++self.lastToken);
        [self.tokens addObject:token];
    
        if(completion) { completion(token); }
    });
}

- (void(^)(void))acquireCompletion
{
    id token = self.acquireToken;
    
    void(^completion)(void) = ^{ [self redeemToken:token]; };
    
    return completion;
}

- (void)redeemToken:(id)token
{
    dispatch_async(self.queue, ^
    { 
        [self.tokens removeObject:token];
        [self checkTokens];
    });
}

- (void)checkTokens
{
    dispatch_async(self.queue, ^
    {         
        if(self.tokens.count == 0 && self.completion)
        {            
            dispatch_sync(dispatch_get_main_queue(), self.completion);
            
            self.completion = nil;
        }
    });
}

@end