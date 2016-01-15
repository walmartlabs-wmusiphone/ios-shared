//
//  SDWebServiceMockResponseRequestMapping.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SDWebServiceMockResponseRequestMapping is used by SDWebServiceMockResponseRequestMapping
 to match requests against the path and query values of the request's URL property.
 */
@interface SDWebServiceMockResponseRequestMapping : NSObject<NSCopying>

/**
 Regex pattern to use for matching against NSURLRequest's URL.path value.

 If it is nil, then any request.URL will match.
 */
@property (nonatomic,copy,readonly) NSString *pathPattern;

/**
 Dictionary of query parameter names -> query parameter value regex patterns to
 use for matching against NSURLRequest's URL.query value.

 All query parameter value patterns specified must matched the corresponding value
 in the URL.query value in order for the request mapping to match the request. 
 
 The matching algorithm ignores any values specified in URL.query that do not have
 an entry in queryParameterPatterns
 */
@property (nonatomic,copy,readonly) NSDictionary *queryParameterPatterns;

- (instancetype)initWithPath:(NSString *) pathPattern
             queryParameters:(NSDictionary *) queryParameterPatterns;

/**
 Return YES if the request matches any required path or parameter values in the mapping
 */
- (BOOL) matchesRequest:(NSURLRequest *) request;

@end
