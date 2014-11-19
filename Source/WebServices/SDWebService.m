//
//  SDWebService.m
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDWebService.h"
#import "NSString+SDExtensions.h"
#import "NSURLCache+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "NSCachedURLResponse+LeakFix.h"
#import "NSData+SDExtensions.h"
#import "NSURLRequest+SDExtensions.h"

NSString *const SDWebServiceError = @"SDWebServiceError";

#ifdef DEBUG
@interface NSURLRequest(SDExtensionsDebug)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end

@implementation NSURLRequest(SDExtensionsDebug)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
	return YES;
}
@end
#endif

@implementation SDRequestResult
+ (SDRequestResult *)objectForResult:(SDWebServiceResult)result identifier:(NSString *)identifier request:(NSURLRequest *)request
{
    SDRequestResult *object = [[SDRequestResult alloc] init];
    object.result = result;
    object.identifier = identifier;
    object.request = request;
    return object;
}
@end

@implementation SDWebService
{
    NSHTTPCookieStorage *_cookieStorage;

    // always access these mutable dicts inside of @synchronized(self)
    NSMutableDictionary *_normalRequests;
	NSMutableDictionary *_singleRequests;

	NSDictionary *_serviceSpecification;
    NSUInteger _requestCount;
    NSOperationQueue *_dataProcessingQueue;

    // always access the mutable array inside of @synchronized(self)
    NSMutableArray *_mockStack;
}

#pragma mark - Singleton bits

+ (instancetype)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

- (instancetype)initWithSpecification:(NSString *)specificationName
{
	self = [super init];

    _singleRequests = [[NSMutableDictionary alloc] init];
    _normalRequests = [[NSMutableDictionary alloc] init];
    
#ifdef DEBUG
    _autoPopMocks = YES;
#endif
    
    self.timeout = 60; // 1-minute default.
	
    NSString *specFile = [[NSBundle bundleForClass:[self class]] pathForResource:specificationName ofType:@"plist"];
	_serviceSpecification = [NSDictionary dictionaryWithContentsOfFile:specFile];
	if (!_serviceSpecification)
		[NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];

    _dataProcessingQueue = [[NSOperationQueue alloc] init];
    // let the system determine how many threads are best, dynamically.
    _dataProcessingQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    _dataProcessingQueue.name = @"com.setdirection.dataprocessingqueue";

    _cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    _mockStack = [NSMutableArray array];
    
#ifdef DEBUG
    _disableCaching = [[NSUserDefaults standardUserDefaults] boolForKey:@"kWMDisableCaching"];
#endif

	return self;
}

- (instancetype)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost path:(NSString *)defaultPath
{
	self = [self initWithSpecification:specificationName];

    NSMutableDictionary *altServiceSpecification = [_serviceSpecification mutableCopy];
    [altServiceSpecification setObject:defaultHost forKey:@"baseHost"];
    [altServiceSpecification setObject:defaultPath forKey:@"basePath"];
    _serviceSpecification = altServiceSpecification;

	return self;
}

- (instancetype)copy
{
    [[NSException exceptionWithName:@"SDException" reason:@"Do NOT copy the web service singleton" userInfo:nil] raise];
    return nil;
}

+ (instancetype)copyWithZone:(NSZone *)zone
{
    [[NSException exceptionWithName:@"SDException" reason:@"Do NOT copy the web service singleton" userInfo:nil] raise];
    return nil;
}

- (void)dealloc
{
    _dataProcessingQueue = nil;
	_serviceSpecification = nil;
    _singleRequests = nil;
    _normalRequests = nil;
}

#pragma mark - Reachability

- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError
{
    return [[SDReachability reachabilityWithHostname:hostName] isReachable];
}

- (BOOL)isReachable:(BOOL)showError
{
    return [[SDReachability reachabilityForInternetConnection] isReachable];
}

#pragma mark - Cache

- (void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Network activity

- (void)showNetworkActivityIfNeeded
{
    if (_requestCount > 0) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNetworkActivity) object:nil];
        [self showNetworkActivity];
    }
}

- (void)hideNetworkActivityIfNeeded
{
    if (_requestCount <= 0)
    {
        _requestCount = 0;
        [self performSelector:@selector(hideNetworkActivity) withObject:nil afterDelay:0.5];
    }
}

- (void)incrementRequests
{
    _requestCount++;
    [self showNetworkActivityIfNeeded];
}

- (void)decrementRequests
{
	if (_requestCount > 0) _requestCount--;
	[self hideNetworkActivityIfNeeded];
}

#pragma mark - URL building utilities

// Iterate through the string and look for {KEY}, replacing with the string value of that key from NSUserDefaults
- (NSString *)stringByReplacingPrefKeys:(NSString *)string
{
	// this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
	BOOL doneReplacing = NO;

	while (!doneReplacing)
	{
		if ([string rangeOfString:@"{"].location != NSNotFound)
		{
			NSString *prefKey = nil;
			NSUInteger startPos = [string rangeOfString:@"{"].location + 1;
			NSUInteger endPos = [string rangeOfString:@"}"].location;
			NSRange range = NSMakeRange(startPos, endPos - startPos);
			prefKey = [string substringWithRange:range];
			NSString *prefValue = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
			string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:prefValue];
		} else
			doneReplacing = YES;
	}
	return string;
}

- (NSString *)baseSchemeInServiceSpecification
{
	NSString *baseScheme = [_serviceSpecification objectForKey:@"baseScheme"];
	return baseScheme;
}

- (NSString *)baseHostInServiceSpecification
{
	NSString *baseHost = [_serviceSpecification objectForKey:@"baseHost"];
	return baseHost;
}

- (NSString *)basePathInServiceSpecification
{
	NSString *basePath = [_serviceSpecification objectForKey:@"basePath"];

	if (!basePath)
		basePath = @"/";

	return basePath;
}

// Backwards compatible method
// DEPRECATED
- (NSString *)baseURLInServiceSpecification
{
	NSString *baseScheme = [self baseSchemeInServiceSpecification];
	NSString *baseHost = [self baseHostInServiceSpecification];
	NSString *basePath = [self basePathInServiceSpecification];

	// Support http or http://
	if (baseScheme && ([baseScheme rangeOfString:@"://"].location == NSNotFound))
	{
		baseScheme = [baseScheme stringByAppendingString:@"://"];
	}

	NSString *baseURL = [NSString stringWithFormat:@"%@%@%@",baseScheme,baseHost,basePath];

	// Support QA servers
	baseURL = [self stringByReplacingPrefKeys:baseURL];

	return baseURL;
}

- (NSString *)parameterizeDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *result = [[NSMutableString alloc] init];

    if (!dictionary || keys.count == 0)
        return @"";

    for (NSString *key in keys)
    {
		id object = [dictionary objectForKey:key];
		NSString *value = nil;

        if ([object isKindOfClass:[NSDictionary class]])
            value = [self parameterizeDictionary:object];
		else
        if ([object isKindOfClass:[NSString class]])
            value = [object escapedString];
        else
        {
            // if its not, run some tests to see what we can do...
            if ([object isKindOfClass:[NSNumber class]])
                value = [[object stringValue] escapedString];
            else
            if ([object respondsToSelector:@selector(stringValue)])
                value = [[object stringValue] escapedString];
        }
		if (value)
            [result appendFormat:@"&%@=%@", key, value];
    }

    return result;
}

- (NSString *)performReplacements:(NSDictionary *)replacements andUserReplacements:(NSDictionary *)userReplacements withFormat:(NSString *)routeFormat
{
    // combine the contents of routeReplacements and the passed in replacements to form
	// a complete name and value list.
	NSArray *keyList = [userReplacements allKeys];
	NSMutableDictionary *actualReplacements = [replacements mutableCopy];
    if (!actualReplacements)
        actualReplacements = [NSMutableDictionary dictionary];
	for (NSString *key in keyList)
	{
		// this takes all the data provided in replacements and overwrites any default
		// values specified in the plist.
		NSObject *value = [userReplacements objectForKey:key];
		[actualReplacements setObject:value forKey:key];
	}

    BOOL escape = ![actualReplacements boolForKey:@"alreadyEscaped"];
    
	// now lets take that final list and apply it to the route format.
	keyList = [actualReplacements allKeys];
	NSString *result = routeFormat;
	for (NSString *key in keyList)
	{
		id object = [actualReplacements objectForKey:key];
		NSString *value = nil;

        if ([object isKindOfClass:[NSDictionary class]])
            value = [self parameterizeDictionary:object];
		else
		if ([object isKindOfClass:[NSString class]])
			value = escape ? [object escapedString] : object;
        else
		{
			// if its not, run some tests to see what we can do...
			if ([object isKindOfClass:[NSNumber class]])
				value = escape ? [[object stringValue] escapedString] : [object stringValue];
			else
            if ([object respondsToSelector:@selector(stringValue)])
                value = escape ? [[object stringValue] escapedString] : [object stringValue];
		}
		if (value)
			result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:value];
	}

    actualReplacements = nil;

    return result;
}

- (NSString *)buildBaseURLForScheme:(NSString *)baseScheme host:(NSString *)baseHost path:(NSString *)basePath details:(NSDictionary *)requestDetails replacements:(NSDictionary *)replacements
{
	NSString *baseURL;

	// **************************************************************
	// Scheme
    NSString *altBaseScheme = [replacements objectForKey:@"baseScheme"];
    if (altBaseScheme)
        baseScheme = altBaseScheme;
    else
    {
        // if this method has its own baseScheme use it instead.
        altBaseScheme = [requestDetails objectForKey:@"baseScheme"];
        if (altBaseScheme)
            baseScheme = altBaseScheme;
    }

	if (baseScheme && ([baseScheme rangeOfString:@"://"].location == NSNotFound))
		baseScheme = [baseScheme stringByAppendingString:@"://"];

	// **************************************************************
	// Host
	NSString *altBaseHost = [replacements objectForKey:@"baseHost"];
    if (altBaseHost)
        baseHost = altBaseHost;
    else
    {
        // if this method has its own baseHost use it instead.
        altBaseHost = [requestDetails objectForKey:@"baseHost"];
        if (altBaseHost)
            baseHost = altBaseHost;
    }

	// **************************************************************
	// Path
	NSString *altBasePath = [replacements objectForKey:@"basePath"];
    if (altBasePath)
        basePath = altBasePath;
    else
    {
        // if this method has its own basePath use it instead.
        altBasePath = [requestDetails objectForKey:@"basePath"];
        if (altBasePath)
            basePath = altBasePath;
    }

	if (!baseScheme)
		[NSException raise:@"SDException" format:@"Unable to create request.  Missing scheme."];

	if (!baseHost)
		[NSException raise:@"SDException" format:@"Unable to create request.  Missing host."];

	baseURL = [NSString stringWithFormat:@"%@%@%@",baseScheme,baseHost,basePath];

	return baseURL;
}

- (NSMutableURLRequest *)buildRequestForScheme:(NSString *)baseScheme headers:(NSDictionary *)headers host:(NSString *)baseHost path:(NSString *)basePath details:(NSDictionary *)requestDetails replacements:(NSDictionary *)replacements
{
    NSMutableURLRequest *request = nil;
	NSString *baseURL = nil;

    NSString *routeFormat = [requestDetails objectForKey:@"routeFormat"];
	NSString *method = [requestDetails objectForKey:@"method"];
	BOOL postMethod = ([[method uppercaseString] isEqualToString:@"POST"] || [[method uppercaseString] isEqualToString:@"PUT"] || ([[method uppercaseString] isEqualToString:@"DELETE"]));

    // Allowing for the dynamic specification of baseURL at runtime
    // (initially to accomodate the suggestions search)
    NSString *altBaseURL = [replacements objectForKey:@"baseURL"];
    if (altBaseURL)
        baseURL = altBaseURL;
    else
    {
        // if this method has its own baseURL use it instead.
        altBaseURL = [requestDetails objectForKey:@"baseURL"];
        if (altBaseURL)
            baseURL = altBaseURL;
    }

	// If there was no altBaseURL, then we need to build the baseURL
	if (!altBaseURL)
		baseURL = [self buildBaseURLForScheme:baseScheme host:baseHost path:basePath details:requestDetails replacements:replacements];

	// Look for {KEY} key ands replace them
	baseURL = [self stringByReplacingPrefKeys:baseURL];

    NSDictionary *routeReplacements = [requestDetails objectForKey:@"routeReplacement"];
    if (!routeReplacements)
        routeReplacements = [NSDictionary dictionary];
    NSString *route = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:routeFormat];

	// there are some unparsed parameters which means either the plist is wrong, or the caller
	// gave us a list of replacements that weren't sufficient to continue on.
	if ([route rangeOfString:@"{"].location != NSNotFound)
	{
		[NSException raise:@"SDException" format:@"Unable to create request.  The URL still contains replacement markers: %@", route];
	}

    // setup post data if we need to.
    NSString *postFormat = [requestDetails stringForKey:@"postFormat"];
    NSString *postParams = nil;
	id postObject = nil;
    if (postMethod)
    {
        if (postFormat)
        {
			if ([postFormat isEqualToString:@"JSON"])
			{
				// post data is raw JSON but can be NSString or NSData depending on implementation of calling method
				postObject = [replacements objectForKey:@"JSON"];
			}
            else
            if ([postFormat isEqualToString:@"SOAP"])
            {
                postObject = [replacements objectForKey:@"SOAP"];
            }
			else
			{
				// post data is in 'foo1={bar1}&foo2={bar2}...' form
				postParams = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:postFormat];
				// there are some unparsed parameters which means either the plist is wrong, or the caller
				// gave us a list of replacements that weren't sufficient to continue on.
				if ([postParams rangeOfString:@"{"].location != NSNotFound)
				{
					[NSException raise:@"SDException" format:@"Unable to create request.  The post params still contains replacement markers: %@", postParams];
				}
			}
        }
    }

	// build the url and put it here...
    NSString* escapedUrlString = [NSString stringWithFormat:@"%@%@", baseURL, route];
	NSURL *url = [NSURL URLWithString:escapedUrlString];

	SDLog(@"outgoing request = %@", url);

	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPShouldUsePipelining:NO];	// THIS WILL FUCK YOUR SHIT UP BRAH! 7 WAYS FROM SUNDAY!  In other words, this cannot be YES or our servers will return incorrect data
    // Service A's data will be returned for Service B, and vice-versa
#ifdef HUGE_SERVICES_TIMEOUT
	[request setTimeoutInterval:120];
#else
    NSNumber *customTimeout = [requestDetails objectForKey:@"timeout"];
    if (customTimeout) {
        [request setTimeoutInterval:[customTimeout integerValue]];
    } else {
        [request setTimeoutInterval:_timeout];
    }
#endif

    // find any applicable cookies and queue them up.
    NSArray *cookieNames = [requestDetails arrayForKey:@"cookieNames"];
    NSMutableArray *cookieArray = [[NSMutableArray alloc] initWithCapacity:cookieNames.count];
    for (NSString *cookieName in cookieNames)
    {
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name == %@ && domain == %@", cookieName, url.host];
        NSArray *foundCookies = [[_cookieStorage cookies] filteredArrayUsingPredicate:namePredicate];

        if (foundCookies && foundCookies.count > 0)
            [cookieArray addObjectsFromArray:foundCookies];
    }

    // add those cookies to the request headers.
    if (cookieArray.count > 0)
    {
        NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        [request setAllHTTPHeaderFields:cookieHeaders];
    }

    // setup post method information.
    //
    if (postMethod)
    {
		id post = nil;
		if (postParams)
		{
			NSMutableString *mutablePost = [[NSMutableString alloc] init];
			//SDLog(@"request post: %@", postParams);
			NSArray *parameters = [postParams componentsSeparatedByString:@"&"];
			for (NSString *aParameter in parameters) {
				NSArray *keyVal = [aParameter componentsSeparatedByString:@"="];
				if ([keyVal count] == 2) {
					NSString *decodedKey = [keyVal objectAtIndex:0];			// Pass encoded values to NSURLConnection
					NSString *decodedValue = [keyVal objectAtIndex:1];
					[mutablePost appendFormat:@"%@=%@&", decodedKey, decodedValue];
				} else {
					[NSException raise:@"SDException" format:@"Unable to create request. Post param does not have proper key value pair: %@", keyVal];
				}
			}
			// Remove dangling '&' after simple sanity check
			if ([mutablePost length]) {
				mutablePost = [NSMutableString stringWithString:[mutablePost substringToIndex:[mutablePost length] - 1]];
			}
			post = mutablePost;
			[request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
		}
		else
        if ([postFormat isEqualToString:@"JSON"])
		{
			post = postObject;
			[request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
			[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
		}
        else
        if ([postFormat isEqualToString:@"SOAP"])
        {
            post = postObject;
            [request setValue:@"application/soap+xml" forHTTPHeaderField:@"Content-Type"];
        }
		if (post)
		{
            NSData *postData = nil;
            if ([post isKindOfClass:[NSData class]])
                // It's a kind of NSData
                postData = post;
            else
                // It's a kind of NSString
                postData = [post dataUsingEncoding:NSUTF8StringEncoding];

			[request setValue:[NSString stringWithFormat:@"%ld", (long)[postData length]] forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:postData];
		}
    }

    if (headers)
        [request setAllHTTPHeaderFields:headers];

    return request;
}

#pragma mark - Service execution

- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
{
    return [self performRequestWithMethod:requestName headers:nil routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:YES];
}

- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName headers:(NSDictionary *)headers routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
{
    return [self performRequestWithMethod:requestName headers:headers routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:YES];
}

- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
{
    return [self performRequestWithMethod:requestName headers:nil routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:shouldRetry];
}

- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName headers:(NSDictionary *)headers routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
{
    NSString *identifier = [NSString stringWithNewUUID];

	// construct the URL based on the specification.
	NSString *baseScheme = [self baseSchemeInServiceSpecification];
	NSString *baseHost = [self baseHostInServiceSpecification];
	NSString *basePath = [self basePathInServiceSpecification];
	NSDictionary *requestList = [_serviceSpecification objectForKey:@"requests"];
	NSDictionary *requestDetails = [requestList objectForKey:requestName];

    NSMutableURLRequest *request = [self buildRequestForScheme:baseScheme headers:headers host:baseHost path:basePath details:requestDetails replacements:replacements];

    // get cache details
    NSNumber *cache = [requestDetails objectForKey:@"cache"];
    NSNumber *cacheTTL = [requestDetails objectForKey:@"cacheTTL"];
    
#ifdef DEBUG
    if (self.disableCaching)
        cache = [NSNumber numberWithBool:NO];
#endif

    // setup caching, default is to let the server decide.
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    /*NSMutableDictionary *newHeaders = [request.allHTTPHeaderFields mutableCopy];
    [newHeaders setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forKey:@"Content-Type"];
    [request setAllHTTPHeaderFields:newHeaders];*/
    // it has to be explicitly disabled to go through here...
	if (cache && ![cache boolValue])
		[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

	// setup the completion blocks.  we call the same block because failure means
	// different things with different APIs.  pass along the info we've gathered
	// to the handler, and let it decide.  if its an HTTP failure, that'll get
	// passed along as well.

#ifdef DEBUG
    NSDate *startDate = [NSDate date];
#endif

	SDURLConnectionResponseBlock urlCompletionBlock = ^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error) {
#ifdef DEBUG
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
        if (interval)           // This is a DEBUG mode workaround for SDLog() being defined but empty in Unit Test builds.
            ;
        SDLog(@"Service call took %lf seconds. URL was: %@", interval, request.URL);
#endif
        // if the connection was cancelled, skip the retry bit.  this lets your block get called with nil data, etc.
        if ([error code] != NSURLErrorCancelled)
        {
            if ([error code] == NSURLErrorTimedOut)
            {
                [self serviceCallDidTimeoutForUrl:response.URL];

                if (shouldRetry)
                {
                    // remove it from the cache if its there.
                    NSURLCache *blockCache = [NSURLCache sharedURLCache];
                    if ([request isValid])
                        [blockCache removeCachedResponseForRequest:request];

                    SDRequestResult *newObject = [self performRequestWithMethod:requestName headers:headers routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:NO];

                    @synchronized(self) { // NSMutableDictionary isn't thread-safe
                        // do some sync/cleanup stuff here.
                        SDURLConnection *newConnection = [_normalRequests objectForKey:newObject.identifier];
                        
                        // If for some unknown reason the second performRequestWithMethod hits the cache, then we'll get a nil identifier, which means a nil newConnection
                        if (newConnection)
                        {
                            [_normalRequests setObject:newConnection forKey:identifier];
                            [_normalRequests removeObjectForKey:newObject.identifier];
                        }
                        else
                        {
                            [_normalRequests removeObjectForKey:identifier];
                        }
                    }

                    [self decrementRequests];
                    return;
                }
            }
        }

        // remove from the requests lists
        @synchronized(self) {
            [_singleRequests removeObjectForKey:requestName];
            [_normalRequests removeObjectForKey:identifier];
        }

        // Saw at least one case where response was NSURLResponse, not NSHTTPURLResponse; Test case went away
        // So be defensive and return SDWTFResponseCode if we did not get a NSHTTPURLResponse
        NSInteger code = SDWTFResponseCode;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            code = [httpResponse statusCode];
        }

        // handle redirects in a crappy way.. need to rework this to be done inside of SDURLConnection.
        if (code == 302)
        {
            [self will302RedirectToUrl:httpResponse.URL];
        }

        [_dataProcessingQueue addOperationWithBlock:^{
            id dataObject = nil;
            if (code != NSURLErrorCancelled)
            {
                if (dataProcessingBlock)
                    dataObject = dataProcessingBlock(response, code, responseData, error);
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (uiUpdateBlock)
                    uiUpdateBlock(dataObject, error);
            }];
        }];

        [self decrementRequests];
	};
    
    // attempt to find any mock data if available, we need it going forward.
    NSData *mockData = nil;
#ifdef DEBUG
    mockData = [self getNextMockResponse];
#endif

    // check the cache if we're not working with a mock.
    if (!mockData)
    {
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        NSCachedURLResponse *cachedResponse = [urlCache validCachedResponseForRequest:request forTime:[cacheTTL unsignedLongValue] removeIfInvalid:YES];
        if ([cache boolValue] && cachedResponse && cachedResponse.response)
        {
            NSString *cachedString = [cachedResponse.responseData stringRepresentation];
            if (cachedString)
            {
                SDLog(@"***USING CACHED RESPONSE***");

                [self incrementRequests];

                urlCompletionBlock(nil, cachedResponse.response, cachedResponse.responseData, nil);

                return [SDRequestResult objectForResult:SDWebServiceResultCached identifier:nil request:request];
            }
        }
    }
    
	[self incrementRequests];

	// see if this is a singleton request.
    BOOL singleRequest = NO;
	NSNumber *singleRequestNumber = [requestDetails objectForKey:@"singleRequest"];
    if (singleRequestNumber)
    {
        singleRequest = [singleRequestNumber boolValue];

        // if it is, lets cancel any with matching names.
        if (singleRequest)
        {
            @synchronized(self) {
                SDURLConnection *existingConnection = [_singleRequests objectForKey:requestName];
                if (existingConnection)
                {
                    SDLog(@"Cancelling call.");
                    [existingConnection cancel];
                    [_singleRequests removeObjectForKey:requestName];
                }
            }
        }
    }
    
    if (!mockData)
    {
        // no mock data was found, or we don't want to use mocks.  send out the request.

        SDURLConnection *connection = [SDURLConnection sendAsynchronousRequest:request withResponseHandler:urlCompletionBlock];

        @synchronized(self) {
            if (singleRequest)
                [_singleRequests setObject:connection forKey:requestName];
            else
                [_normalRequests setObject:connection forKey:identifier];
        }
    }
    else
    {
        // we have mock data for this service call.
        // attempt to recreate the path as best we can.

        [_dataProcessingQueue addOperationWithBlock:^{
            id dataObject = nil;
            if (dataProcessingBlock)
                dataObject = dataProcessingBlock(nil, 200, mockData, nil);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (uiUpdateBlock)
                    uiUpdateBlock(dataObject, nil);
            }];
        }];
    }

	return [SDRequestResult objectForResult:SDWebServiceResultSuccess identifier:identifier request:request];
}

- (void)cancelRequestForIdentifier:(NSString *)identifier
{
    @synchronized(self) {
        SDURLConnection *connection = [_normalRequests objectForKey:identifier];
        [connection cancel];
    }
}

#pragma mark - Subclass should override these

- (void)serviceCallDidTimeoutForUrl:(NSURL*)url
{
	// override in subclass
}

- (void)showNetworkActivity
{
    // override in subclass.
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivity
{
    // override in subclass.
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)will302RedirectToUrl:(NSURL *)argUrl
{
	// Implement in service subclass for specific behavior
}

- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject
{
    // do nothing.  override in subclass like so...

    /*
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

    return FALSE;
}

#pragma mark - Unit Testing

#ifdef DEBUG
- (NSData *)getNextMockResponse
{
    @synchronized(self)
    {
        if (_mockStack.count == 0)
            return nil;
        
        NSData *result = [_mockStack objectAtIndex:0];
        if (self.autoPopMocks)
            [self popMockResponseFile];
        
        return result;
    }
}

- (void)pushMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle
{
    @synchronized(self)
    {
        // remove a any prepended paths in case they can't read the documentation.
        NSString *safeFilename = [filename lastPathComponent];
        NSString *finalPath = [bundle pathForResource:safeFilename ofType:nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *mockData = nil;
        
        if (finalPath && [fileManager fileExistsAtPath:finalPath])
        {
            SDLog(@"*** Using mock data file '%@'", safeFilename);
            mockData = [NSData dataWithContentsOfFile:finalPath];
        }
        else
            SDLog(@"*** Unable to find mock file '%@'", safeFilename);

        if (mockData)
            [_mockStack addObject:mockData];
    }
}

- (void)pushMockResponseFiles:(NSArray *)filenames bundle:(NSBundle *)bundle
{
    @synchronized(self)
    {
        for (NSUInteger index = 0; index < filenames.count; index++)
        {
            id object = [filenames objectAtIndex:index];
            if (object && [object isKindOfClass:[NSString class]])
            {
                NSString *filename = object;
                
                // remove a any prepended paths in case they can't read the documentation.
                NSString *safeFilename = [filename lastPathComponent];
                NSString *finalPath = [bundle pathForResource:safeFilename ofType:nil];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSData *mockData = nil;
        
                if (finalPath && [fileManager fileExistsAtPath:finalPath])
                {
                    SDLog(@"*** Using mock data file '%@'", safeFilename);
                    mockData = [NSData dataWithContentsOfFile:finalPath];
                }
                else
                    SDLog(@"*** Unable to find mock file '%@'", safeFilename);
                
                if (mockData)
                    [_mockStack addObject:mockData];
            }
        }
    }
}

- (void)popMockResponseFile
{
    @synchronized(self)
    {
        if (_mockStack.count > 0)
            [_mockStack removeObjectAtIndex:0];
    }
}
#endif


@end
