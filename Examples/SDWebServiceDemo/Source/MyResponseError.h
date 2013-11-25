//
//  SDWebServiceDemo - MyResponseError.h
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"


@class MyErrorType;

/**
 *  MyResponseError is the general error reporting object for Pharmacy Services
 *
 *  It is created in two main scenarios:
 *
 *  1. A proper web service response, (HTTP code 200 for example), but the endpoint
 *     being called needs to report a problem to the app. A user's login attempt
 *     failed, for example. These messages will be created from JSON in the format:
 *             {
 *                  "error": 102,
 *                  "message": "Login failed"
 *             }
 *     NB: The integer "error" is mapped using the enumeration MyErrorType
 *         (PharmacyErrorType_LoginFailed in this case)
 *
 *  2. When a server error response happens (A non 200-299 based HTTP code) a
 *     MyResponseError object is created with "error" being set to the HTTP code, and
 *     the "message" coming from a string based attribute named "error". Here's the
 *     format:
 *             {
 *                   code: 404,
 *                   error: "Not Found"
 *             }
 *     becomes:
 *             {
 *                  "error": 404,
 *                  "message": "Not Found"
 *             }
 */

@interface MyResponseError : SDModelObject

@property (nonatomic, assign, readonly) MyErrorType* error;
@property (nonatomic, copy, readonly) NSString* message;

@end
