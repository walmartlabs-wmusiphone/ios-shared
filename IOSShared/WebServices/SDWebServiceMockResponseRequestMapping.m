//
//  SDWebServiceMockResponseRequestMapping.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWebServiceMockResponseRequestMapping.h"
#import "NSString+SDExtensions.h"

@interface SDWebServiceMockResponseRequestMapping()
@property (nonatomic,copy,readwrite) NSString *pathPattern;
@property (nonatomic,copy,readwrite) NSDictionary *queryParameterPatterns;
@end

@implementation SDWebServiceMockResponseRequestMapping

- (instancetype)initWithPath:(NSString *) pathPattern
             queryParameters:(NSDictionary *) queryParameterPatterns
{
    if ((self = [super init]))
    {
        _pathPattern = [pathPattern copy];
        _queryParameterPatterns = [queryParameterPatterns copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:self.pathPattern queryParameters:self.queryParameterPatterns];
}

- (NSString *) description
{
    NSMutableString *result = [NSMutableString stringWithString:NSStringFromClass([self class])];
    if ([self.pathPattern length] > 0)
    {
        [result appendFormat:@"\npathPattern: %@", self.pathPattern];
    }
    if ([self.queryParameterPatterns count] > 0)
    {
        [result appendString:@"\nqueryParameterPatterns"];
        [self.queryParameterPatterns enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [result appendFormat:@"\n  %@=%@", key, obj];
        }];
    }
    return result;
}

- (BOOL) pattern:(NSString *) pattern matchesValue:(NSString *) value
{
    BOOL result = NO;
    if ([pattern length] == 0)
    {
        // specifying exact match for empty pattern means the value should be nil/empty
        result = YES;
    }
    else
    {
        if ([value length] == 0)
        {
            result = NO;
        }
        else
        {
            result = [value isValidWithRegex:pattern];
        }
    }
    return result;
}

- (BOOL) matchesRequest:(NSURLRequest *) request
{
    BOOL result = [self pattern:self.pathPattern matchesValue:request.URL.path];

    if (result && ([self.queryParameterPatterns count] > 0))
    {
        NSMutableDictionary *unmatchedQueryParameterPatterns = [self.queryParameterPatterns mutableCopy];
        NSArray *queryItems = [request.URL.query componentsSeparatedByString:@"&"];
        // all queryParameterPatterns must match something unique for mapping to match
        for (NSString *queryItem in queryItems)
        {
            NSArray *querySubitems = [queryItem componentsSeparatedByString:@"="];
            NSString *queryParameter = querySubitems[0];
            NSString *queryValue = ([querySubitems count] > 1) ? querySubitems[1] : nil;

            NSString *checkValue = unmatchedQueryParameterPatterns[queryParameter];
            if (checkValue != nil)
            {
                if ([self pattern:checkValue matchesValue:queryValue])
                {
                    // found parameter whose value does match the pattern
                    [unmatchedQueryParameterPatterns removeObjectForKey:queryParameter];
                }
            }
        }
        if ([unmatchedQueryParameterPatterns count] > 0)
        {
            result = NO;
        }

    }
    return result;
}

@end
