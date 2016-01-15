//
//  SDURLRouterEntry.m
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import "SDURLRouterEntry.h"
#import "SDURLRouteHandler.h"

@implementation SDURLMatchResult

@end

@interface SDURLRouterEntry ()

@property (nonatomic, strong) id<SDURLRouteHandler> handler;
@property (nonatomic, strong) NSMutableArray *parameterNames;
@property (nonatomic, strong) NSRegularExpression *matchRegularExpression;

@end

@implementation SDURLRouterEntry

- (instancetype) initWithRoute:(NSString *)routeTemplate handler:(id<SDURLRouteHandler>)handler
{
    self = [super init];
    if (self != nil)
    {
        _handler = handler;
        _parameterNames = [NSMutableArray array];
        [self initMatchRegularExpressionWithTemplate:routeTemplate];
    }
    return self;
}

- (instancetype) initWithRouteRegex:(NSRegularExpression *)routeRegex handler:(id<SDURLRouteHandler>)handler
{
    self = [super init];
    if (self != nil)
    {
        _handler = handler;
        _parameterNames = [NSMutableArray array];
        _matchRegularExpression = routeRegex;
    }
    return self;
}

- (void) initMatchRegularExpressionWithTemplate:(NSString *)route
{
    static NSString *SDURLSegmentMatchingPattern = @"([^\\/\\?\n\r]+)";
    
    NSMutableString *matchingString = [NSMutableString string];
    [matchingString appendString:@"^"];
    
    NSCharacterSet *escapeCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"*?+[()^$|\\./"];
    __block BOOL parsingName = NO;
    __block NSMutableString *parameterName = nil;
    
    [route enumerateSubstringsInRange:NSMakeRange(0, [route length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        if ( [substring isEqualToString:@"{"] )
        {
            parsingName = YES;
            parameterName = [NSMutableString string];
            [matchingString appendString:SDURLSegmentMatchingPattern];
        }
        else if ( [substring isEqualToString:@"}"] )
        {
            [_parameterNames addObject:parameterName];
            parameterName = nil;
            parsingName = NO;
        }
        else if ( parsingName )
        {
            [parameterName appendString:substring];
        }
        else if ( [substring rangeOfCharacterFromSet:escapeCharacterSet].location != NSNotFound )
        {
            [matchingString appendString:@"\\"];
            [matchingString appendString:substring];
        }
        else
        {
            [matchingString appendString:substring];
        }
    }];
    
    [matchingString appendString:@"$"];
    _matchRegularExpression = [NSRegularExpression regularExpressionWithPattern:matchingString options:0 error:nil];
}

- (SDURLMatchResult *) matchesURL:(NSURL *)url
{
    SDURLMatchResult *matchResult = [SDURLMatchResult new];
    NSMutableDictionary *parameters = nil;
    
    NSString *urlString = [url absoluteString];
    NSString *query = [url query];
    if ( [query length] > 0 )
    {
        urlString = [urlString substringToIndex:[urlString length] - [query length] - 1];
    }
    
    NSArray *matches = [self.matchRegularExpression matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    
    if ( [matches count] >= 1 )
    {
        matchResult.isMatch = YES;
    }
    if ( [matches count] == 1 )
    {
        NSTextCheckingResult *result = matches[0];
        parameters = [NSMutableDictionary dictionary];
        [self.parameterNames enumerateObjectsUsingBlock:^(NSString *parameterName, NSUInteger idx, BOOL *stop)
        {
            NSRange valueRange = [result rangeAtIndex:idx + 1];
            parameters[parameterName] = [urlString substringWithRange:valueRange];
        }];
        [parameters addEntriesFromDictionary:[self parametersFromQuery:query]];
    }
    
    matchResult.matches = matches;
    matchResult.parameters = parameters;
    return matchResult;
}

- (NSDictionary *) parametersFromQuery:(NSString *)query
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSArray *keyValuePairs = [[query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in keyValuePairs)
    {
        NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
        if ( [pair count] != 2 )
            continue;
        
        parameters[pair[0]] = pair[1];
    }
    
    return parameters;
}

- (void) handleURL:(NSURL *)url withMatchResult:(SDURLMatchResult *)matchResult userInfo:(NSDictionary *)userInfo
{
    [self.handler handleURL:url withMatchResult:matchResult userInfo:userInfo];
}

@end
