//
//  SDWebServiceDemo - MyServices.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyServices.h"

#import "MyResponseError.h"
#import "SDModelObject.h"


@implementation MyServices

+ (instancetype) sharedInstance
{
	static dispatch_once_t sDispatch;
	static id sSharedInstance = nil;
    
	dispatch_once( &sDispatch, ^
    {
        sSharedInstance = [[[self class] alloc] init];
    } );
    
	return sSharedInstance;
}

- (id) init
{
    // The specification string should match the name of the .plist file that provides this class' service specs.
    
    self = [super initWithSpecification: @"MyServices"];

	if( self )
	{
		// Nothing to do here just now.
	}
    return self;
}

#pragma mark - Default JSON processing blocks

// The errorClass method is overridden here to provide a SDDataMap protocol-compliant model to the API's error map.
// It's recommended that the errorClass be derived from SDModelObject, which is SDDataMap protocol-compliant.

+ (Class) errorClass
{
    return [MyResponseError class];
}

#pragma mark - Service call example

// Our example service call.

- (SDRequestResult*) fourDollarPrescriptionsWithDataProcessingBlock: (SDWebServiceDataCompletionBlock) dataProcessingBlock
                                                      uiUpdateBlock: (SDWebServiceUICompletionBlock) uiUpdateBlock
{
    // This service request has three route replacements, specified in the method's key for 'routeFormat' in the service's plist.
    // Two of these route replacements are set below.
    // The third route replacement (errorFormat) is set in the plist for illustrative purposes.
    
    NSDictionary* replacements = @{ @"service": @"RxContent",
                                    @"method": @"getFourDollarContent" };
    
    // Perform the service request and return the result.

    SDRequestResult* result  = [self performRequestWithMethod: @"fourDollarPrescriptions"
                                            routeReplacements: replacements
                                          dataProcessingBlock: dataProcessingBlock
                                                uiUpdateBlock: uiUpdateBlock];
    
    return result;
}

@end
