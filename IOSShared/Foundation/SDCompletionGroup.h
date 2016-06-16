//
//  SDCompletionGroup.h
//  SetDirection
//
//  Created by Joel Bernstein on 02/08/2011.
//  Copyright 2011-2014 Joel Bernstein. All rights reserved.
//

/**
 SDCompletionGroup provides a mechanism to perform a completion block when 'n' completion block based
 operations finish. For example, waiting on some SDWebServices calls to complete before calling another
 operation.
 */

#import <Foundation/Foundation.h>

@interface SDCompletionGroup : NSObject

@property (nonatomic, copy) void(^completion)();

- (id)acquireToken;
- (void)acquireTokenWithCompletion:(void(^)(id token))completion;
- (void(^)(void))acquireCompletion;
- (void)redeemToken:(id)token;

@end
