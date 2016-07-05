//
//  NSError+SDExtensions
//  ios-shared
//
//  Created by Brandon Sneed on 7/25/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "NSError+SDExtensions.h"

@implementation NSError(SDExtensions)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error
{
    NSDictionary *userInfo = nil;
    if (error)
        userInfo = @{NSUnderlyingErrorKey : error};
    NSError *result = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return result;
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code
{
    return [NSError errorWithDomain:domain code:code underlyingError:nil];
}

+ (NSError *)wrapErrorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error;
{
    if (!error)
        return nil;

    return [NSError errorWithDomain:domain code:code underlyingError:error];
}

@end
