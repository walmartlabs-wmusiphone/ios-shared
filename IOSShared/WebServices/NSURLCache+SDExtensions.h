//
//  NSURLCache+SDExtensions.h
//  SetDirection
//
//  Created by Steven Riggins on 4/27/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLCache (SDExtensions)

/**
 Returns the expiration data from a given set of headers and status code.  If it's determined that this should not be cached
 nil is returned.  If there's no way to determine if it should be cached or not, then a default of 1 hr is assumed.
 */
+ (NSDate *)expirationDateFromHeaders:(NSDictionary *)headers withStatusCode:(NSInteger)status;

/**
 Returns `YES` if the url is in the cache and valid (ie non-expired). `NO` otherwise.
 */
- (BOOL)isCachedAndValid:(NSURLRequest*)request;

/**
 Returns response if it is not expired. `nil` otherwise.
 */
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request;

/**
 Returns response if it is not expired and younger than `ttl`. `nil` otherwise.
 */
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request forTime:(NSTimeInterval)ttl removeIfInvalid:(BOOL)remove;

/**
 Returns the response but ignores the expiration date. Just compares the ttl against the date in the header.
 @warning **EXPERIMENTAL.** Use with care.
 */
- (NSCachedURLResponse*)suppopsedlyInvalidCachedResponseForRequest:(NSURLRequest *)request forTime:(NSTimeInterval)ttl;

@end
