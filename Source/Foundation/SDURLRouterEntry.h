//
//  SDURLRouterEntry.h
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDURLRouteHandler;

@interface SDURLRouterEntry : NSObject

- (instancetype) initWithRoute:(NSString *)routeTemplate handler:(id<SDURLRouteHandler>)handler;

- (instancetype) initWithRouteRegex:(NSRegularExpression *)routeRegex handler:(id<SDURLRouteHandler>)handler;

- (NSDictionary *) matchesURL:(NSURL *)url matches:(NSArray **)pMatches;

- (void) handleURL:(NSURL *)url withParameters:(NSDictionary *)parameters matches:(NSArray *)matches;

@end
