//
//  SDURLRouter.h
//  ios-shared
//
//  Created by Andrew Finnell on 12/11/14.
//  Copyright (c) 2014 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLRouterEntry.h"

typedef void (^SDURLRouteHandlerBlock)(NSURL *url, SDURLMatchResult *matchResult, NSDictionary *userInfo);

@interface SDURLRouter : NSObject

- (void) addRoute:(NSString *)route withHandler:(id<SDURLRouteHandler>)handler;
- (void) addRoute:(NSString *)route withBlock:(SDURLRouteHandlerBlock)block;
- (void) addRegexRoute:(NSRegularExpression *)routeRegex withHandler:(id<SDURLRouteHandler>)handler;
- (void) addRegexRoute:(NSRegularExpression *)routeRegex withBlock:(SDURLRouteHandlerBlock)block;

- (BOOL) routeURL:(NSURL *)url;
- (BOOL) routeURL:(NSURL *)url userInfo:(NSDictionary *)userInfo;

@end
