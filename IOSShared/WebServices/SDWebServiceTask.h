//
//  SDWebServiceTask.h
//  ios-shared
//
//  Created by Angelo Di Paolo on 2/5/16.
//  Copyright © 2016 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Defines an interface for managing the lifetime of a HTTP request.
@protocol SDWebServiceTask <NSObject>

/// Cancel the request.
- (void)cancel;

@end

// MARK: - SDWebServiceTask Handler Block

typedef void (^SDWebServiceTaskCompletionBlock)(NSURLResponse *response, NSData *data, NSError *error);

// MARK: - SDWebServiceTaskFactory

/// Defines an interface for sending asynchronous requests and handling the response.
@protocol SDWebServiceTaskFactory <NSObject>

- (id<SDWebServiceTask>)serviceTaskWithRequest:(NSURLRequest *)request
                                       handler:(SDWebServiceTaskCompletionBlock)handler;
@end
