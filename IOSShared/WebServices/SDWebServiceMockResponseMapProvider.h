//
//  SDWebServiceMockResponseMapProvider.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebServiceMockResponseProvider.h"

@class SDWebServiceMockResponseRequestMapping;

/**
 SDWebServiceMockResponseMapProvider maps particular requestMappings to individual
 mock responses.  It can match one to many requests. 
 
 The same requestMapping value can be used multiple times to return different results for
 similar requests. Once the maximumResponses have been matched, the matching algorithm
 will move to the next mapped response in the list.  
 
 For instance, something like this:
 
 [p addMockResponseFile:@"fileA.json" bundle:... forRequestMapping:requestMapping maximumResponses:2];
 [p addMockResponseFile:@"fileB.json" bundle:... forRequestMapping:requestMapping maximumResponses:1];
 [p addMockResponseFile:@"fileC.json" bundle:... forRequestMapping:requestMapping maximumResponses:NSIntegerMax];

 will return the contents of fileA the first two times requestMapping's matchesRequest returns YES
 and then return the contents of fileB the next time requestMapping's matchesRequest returns YES
 and then return the contents of fileC every other time requestMapping's matchesRequest returns YES

 (see SDWebServiceMockResponseMapProviderTests#testCompoundMockResponse for more examples)
 */
@interface SDWebServiceMockResponseMapProvider : NSObject<SDWebServiceMockResponseProvider>

/**
 Adds single mapping for request -> response

 @param filename the resource filename to load responseData from
 @param bundle the bundle to use for the resource
 @param requestMapping the mapping to use to determine when this responseData should be used
 @param maximumResponses the maximum number of times this responseData will be returned for any matching requestMappings
 */
- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping maximumResponses:(NSUInteger) maximumResponses;

/**
 Convenience method to only check the request URL's path value, sets maximumResponses to NSIntegerMax
 */
- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forPath:(NSString *) path;

/**
 Remove all responses for requestMapping

 @param requestMapping the requestMapping to match
 */
- (void)removeMockResponseFileForRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping;

/**
 Remove all request mappings to reset everything for subsequent tests
 */
- (void)removeAllRequestMappings;

@end
