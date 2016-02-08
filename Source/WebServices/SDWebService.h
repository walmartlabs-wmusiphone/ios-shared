//
//  SDWebService.h
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLConnection.h"
#import "Reachability.h"
#import "SDWebServiceMockResponseProvider.h"

typedef id (^SDWebServiceDataCompletionBlock)(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error);
typedef void (^SDWebServiceUICompletionBlock)(id dataObject, NSError *error);

extern NSString *const SDWebServiceError;

enum
{
    SDWebServiceErrorNoConnection = 0xBEEF,
    SDWebServiceErrorBadParams = 0x0BADF00D,
    // all other errors come from NSURLConnection and its subsystems.
};

enum
{
	SDWTFResponseCode = -1
};

typedef enum
{
    SDWebServiceResultFailed = NO,
    SDWebServiceResultSuccess = YES,
    SDWebServiceResultCached = 2
} SDWebServiceResult;

@interface SDRequestResult : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) SDWebServiceResult result;
@property (nonatomic, strong) NSURLRequest *request;
@end

/**
 SDWebService is designed to be used to manage a set of web services that exists at a particular endpoint.
 It is meant to be subclassed to create methods that work with a particular service.
 This class supports only HTTP GET and POST methods.
 The web service endpoint and the type of requests and query formats are defined in a plist file which should be specified as documented below.
 A sample plist is available as a private gist at: https://gist.github.com/619b18f55c3ff61a908e

 ### SDWebService Property List Format Specification ###
 * `baseURL` (string): This required key describes the base URL endpoint which forms the prefix to all requests.
 * `requests` (dictionary): A dictionary comprising of a key for each type of method in the web service.
   The name of the key is used in the SDWebservice subclass to access its format from the plist.
   Each key itself points to a method dictionary.
   Each method dictionary comprises of the following keys:
     - `method` (string): The HTTP method of the request. SDWebService supports GET and POST.
     - `routeFormat` (string): The method specific string that follows the baseURL. It may contain replacement markers of the form `{replaceMe}`.
         Each of those can be replaced by the replacements defined in the routeReplacement sibling dictionary defined below.
         They can also be replaced by a routeReplacement dictionary passed into the request creation code via the performRequestWithMethod: calls.
         All replacement markers must be substituted with appropriate values using one or both or the above mechanisms when a request is being created.
     - `routeReplacement` (dictionary): This dictionaly comprises of keys that match the replacement markers in the `routeFormat` string.
         The value for each key is put in place of the replacement marker when the request is being created.
     - `postFormat` (string): The method specific string that is sent in the post body in case of a POST request. It may contain replacement markers of the form `{replaceMe}`.
         Each of those can be replaced by the replacements defined in the routeReplacement sibling dictionary defined below.
         They can also be replaced by a routeReplacement dictionary passed into the request creation code via the performRequestWithMethod: calls.
         All replacement markers must be substituted with appropriate values using one or both or the above mechanisms when a request is being created.

 ### Blocks in use are defined as:
    // Handles data processing for a given connection.  `response` will be an NSHTTPURLResponse 99% of the time.  
    // The return/result is the dataObject that will eventually be passed to SDWebServiceUICompletionBlock.
    // This block is run on a separate GCD thread.
    typedef id (^SDWebServiceDataCompletionBlock)(NSURLResponse *response, NSInteger statusCode, NSData *responseData, NSError *error);
 
    // The dataObject parameter is the result of SDWebServiceDataCompletionBlock.  UI updates of the contained data should
    // happen here.  This block is always run on the main thread.
    typedef void (^SDWebServiceUICompletionBlock)(id dataObject, NSError *error);
 */

@interface SDWebService : NSObject

#ifdef DEBUG
/**
 Disable service call caching.
 */
@property (nonatomic, assign) BOOL disableCaching;
#endif

/**
 The timeout, in seconds, for calls made to this service. Default is `60.0`.
 */
@property (nonatomic, assign) NSUInteger timeout;

/**
 Returns the singleton for the web service class.  This should be overridden if multiple subclasses are in use.
 */
+ (instancetype)sharedInstance;

/**
 Initializes the instance with a plist specification included in the bundle and named using the string in `specificationName` and of type .plist.
 */
- (instancetype)initWithSpecification:(NSString *)specificationName;

/**
 Initializes the instance with a plist specification included in the bundle and named using the string in `specificationName` and of type .plist.
 Overrides the `baseHost` and `basePath` with the parameters `defaultHost` and `defaultPath`.
 */
- (instancetype)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost path:(NSString *)defaultPath;

/**
 Returns the base scheme in the service specification.
 */
- (NSString *)baseSchemeInServiceSpecification;

/**
 Returns the base host in the service specification.
 */
- (NSString *)baseHostInServiceSpecification;

/**
 Returns the base path in the service specification.
 */
- (NSString *)basePathInServiceSpecification;

/**
 Returns the baseURL in the service specification.
 If the baseURL contains a replacement marker of the type `{replaceMe}`, then it is replaced with the value of the key `replaceMe` if it exists in the Settings bundle.
 There can only be one such replacement marker in the baseURL.
 */
- (NSString *)baseURLInServiceSpecification;

/**
 Returns `YES` if there is reachability to the Internet. `NO` otherwise.
 @warning `showError` is currently ignored.
 */
- (BOOL)isReachable:(BOOL)showError;

/**
 Returns `YES` if there is reachability to `hostName`. `NO` otherwise.
 @warning `showError` is currently ignored.
 */
- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError;

/**
 Removes all cached responses.
 */
- (void)clearCache;

/**
 Calls performRequestWithMethod:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `shouldRetry` set to `YES`.
 */
- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName
                            routeReplacements:(NSDictionary *)replacements
                          dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock;

/**
 Calls performRequestWithMethod:headers:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `shouldRetry` set to `YES`.
 */
- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName
                                      headers:(NSDictionary *)headers
                            routeReplacements:(NSDictionary *)replacements
                          dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock;

/**
 Calls performRequestWithMethod:headers:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `headers` set to `nil`.
 */
- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName
                            routeReplacements:(NSDictionary *)replacements
                          dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
                                  shouldRetry:(BOOL)shouldRetry;


/**
 Creates and initiates a request to the web service.
 @return An SDRequestResult object to indicate the success of the method (not the call) and to provide a unique identifier for cancelRequestForIdentifier:.
 @param requestName The name of the request as specified in the plist.
 @param replacements Route replacements if any for the routeFormat as well as the postFormat in the request spec.
 @param dataProcessingBlock The block to execute after the request completes to process the response in a background thread.
 @param uiUpdateBlock The block to execute after the dataProcessingBlock completes to update the UI on the main thread.
 @param shouldRetry Set to `YES` to retry the request once after a time out.
 */
- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName
                                      headers:(NSDictionary *)headers
                            routeReplacements:(NSDictionary *)replacements
                          dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
                                  shouldRetry:(BOOL)shouldRetry;

/**
 Cancels the request that matches the `identifier`.
 */
- (void)cancelRequestForIdentifier:(NSString *)identifier;

#pragma mark - Suggested overrides for subclasses

/**
 Override in subclass as so:
    SDWebServiceUICompletionBlock uiBlock = ^(id dataObject, NSError *error)
        {
            if ([self handledError:error dataObject:dataObject])
            {
                // do your *ERROR UI*
            }
            else
            {
                // do your *SUCCESS UI*
                // You may still need to do some error checking here.
                // Think of handledError: as kind of a global error handling for your app.
                // If this service call has possible error conditions that no other
                // service call would have, you'll want to look for those here as well.
            }
        }
 */
- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject;

/**
 Implement in subclass for specific behavior in case a request is undergoing a 302 redirect.
 */
- (void)will302RedirectToUrl:(NSURL *)argUrl;

/**
 Implement in subclass for specific behavior in case a request times out.
 */
- (void)serviceCallDidTimeoutForUrl:(NSURL*)url;

/**
 Implement in subclass to do what's needed when network activity starts.
 */
- (void)showNetworkActivity;

/**
 Implement in subclass to do what's needed when network activity ends.
 */
- (void)hideNetworkActivity;

#pragma mark - Unit Testing
#ifdef DEBUG

/**
 Returns the correct NSBundle for the current test case.
 */
#define NSBundleForTestCase [NSBundle bundleForClass:[self class]]

/**
 Allows for multiple mock response provider implementations
*/
@property (atomic,strong) id<SDWebServiceMockResponseProvider> mockResponseProvider;

/**
 Enables/Disables auto-popping of the mocks stack.  The default value is YES.
 
 @warning This method is deprecated, using it will trigger a check for mockResponseProvider, and if it is not an instance of SDWebServiceMockResponseQueueProvider, it will replace it with one.
 */
@property (atomic, assign) BOOL autoPopMocks;

/**
 Push mock data onto the stack.  These are accessed sequentially.  Each service call
 will use index 0.  If autoPopMocks is enabled, they'll be automatically pulled off
 of the stack as tey are accessed.  If autoPopMocks is disabled, one needs to manually
 call popMockResponseFile as appropriate.

 @warning This method is deprecated, using it will trigger a check for mockResponseProvider, and if it is not an instance of SDWebServiceMockResponseQueueProvider, it will replace it with one.
 */
- (void)pushMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle;

/**
 Adds several mock response files at once.

 @warning This method is deprecated, using it will trigger a check for mockResponseProvider, and if it is not an instance of SDWebServiceMockResponseQueueProvider, it will replace it with one.
 */
- (void)pushMockResponseFiles:(NSArray *)filenames bundle:(NSBundle *)bundle;

/**
 Pops the index 0 mock off of the stack.

 @warning This method is deprecated, using it will trigger a check for mockResponseProvider, and if it is not an instance of SDWebServiceMockResponseQueueProvider, it will replace it with one.
 */
- (void)popMockResponseFile;

/**
 Removes all mock response files
 */
- (void)removeAllMockResponseFiles;

/**
 Sets the maximumConcurrentOperations to enable predictability for testing
 */
@property (nonatomic,assign) NSInteger maxConcurrentOperationCount;

#endif

@end
