//
//  NSError+SDExtensions
//  ios-shared
//
//  Created by Brandon Sneed on 7/25/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError(SDExtensions)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code;
+ (NSError *)wrapErrorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error;

@end
