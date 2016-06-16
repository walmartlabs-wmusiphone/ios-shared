//
//  SDWebServiceMockResponseProvider.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SDWebService uses implementations of SDWebServiceMockResponseQueueProvider to
 handle any mock responses.  
 
 All details except the get data method are handled by implementations.
 */
@protocol SDWebServiceMockResponseProvider <NSObject>

/**
 Returns value for responseData to use in SDWebService performRequest methods

 @param request providers may use the request values to determine what mock response they should return, but providers can also ignore it and do whatever they want
 @return mock data to use in response, it may be nil if the provider decides it does not have any mock data for the particular request
 */
- (NSData *) getMockResponseForRequest:(NSURLRequest *) request;
@end
