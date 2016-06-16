//
//  SDURLRouterEntry.h
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDURLMatchResult : NSObject

/// The URL parameters as key/value pairs
@property (nonatomic, strong) NSDictionary *parameters;

/// An array of NSTextCheckingResult objects (as returned by NSRegularExpression -matchesInString:options:range:)
@property (nonatomic, strong) NSArray *matches;

/// Whether a match was found against the regex
@property (nonatomic) BOOL isMatch;

@end

@protocol SDURLRouteHandler;

@interface SDURLRouterEntry : NSObject

- (instancetype) initWithRoute:(NSString *)routeTemplate handler:(id<SDURLRouteHandler>)handler;

- (instancetype) initWithRouteRegex:(NSRegularExpression *)routeRegex handler:(id<SDURLRouteHandler>)handler;

- (SDURLMatchResult *) matchesURL:(NSURL *)url;

- (void) handleURL:(NSURL *)url withMatchResult:(SDURLMatchResult *)matchResult userInfo:(NSDictionary *)userInfo;

@end
