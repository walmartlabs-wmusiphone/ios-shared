//
//  SDWebServiceDemo - MyServices.h
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

/**
 *  MyServices is the main entry class for interacting with the Pharmacy REST Services, documented here:
 *  https://confluence.walmart.com/display/GECMOB/Pharmacy+REST+API
 *
 *  The class should be used as a singleton, invoked as folows:
 *  [MyServices sharedInstance]
 *
 *  Most of the instance methods are a one to one relationship to the REST services. A few
 *  are broken into multiple methods for the sake of simplifying the method parameters.
 *
 *  Class methods help with common tasks, see their individual descriptions below.
 *  
 *  A sample usage of a service call, along with class method defaultJSONProcessingBlockForClass.
 *
 *  [[MyServices sharedInstance] fourDollarPrescriptionsWithDataProcessingBlock: [MyServices defaultJSONProcessingBlockForClass: [MyFourDollarDrugList class]]
 *                                                               uiUpdateBlock: ^( id dataObject, NSError* error )
 *  {
 *      if( [dataObject isKindOfClass: [MyResponseError class]] )
 *      {
 *          // We received a response error from the API. Process accordingly.
 *
 *          MyResponseError* responseError = dataObject;
 *
 *          SDLog( @"There was a response error: %@ %@", responseError.error, responseError.message );
 *      }
 *      else if ( error )
 *      {
 *          // We received a service error. Process accordingly.
 *
 *          SDLog( @"There was a response error: %@", error.localizedFailureReason );
 *      }
 *      else if( [dataObject isKindOfClass: [MyFourDollarDrugList class]] )
 *      {
 *          // The response data object came back in the format we specified. Process accordingly.
 *
 *          MyFourDollarDrugList* fourDollarDrugList = dataObject;
 *
 *          // Update our UI here.
 *      }
 *      else
 *      {
 *          // We received no response at all.
 *
 *          NSAssert( NO, @"The service call didn't return a data response in an expected format; if one was expected, fix this either in your class or error model or fix the service." );
 *      }
 *  }];
 *
 *  Many of the services do not require input if the user has been authorized.
 */

@interface MyServices : SDWebService

/**
 *  The shared instance.
 *
 *  @return The shared instance
 */
+ (instancetype) sharedInstance;

/**
 *  The error class to be used inside of defaultJSONProcessingBlockForClass:
 *  Defaults to the superclass if the subclass doesn't override to provide 
 *  API-specific error codes. 
 *
 *  Must support the SDDataMap protocol.
 *  Should be derived from SDModelObject, which supports the SDDataMap protocol. 
 *
 *  @return The class used for processing API-specific error codes
 *
 */
+ (Class) errorClass;

/**
 *  Pharmacy Services
 *  See the Pharmacy REST API Specification Format document for the REST implementation specifications.
 */

/**
 *  The service call to get the complete set of four dollar prescriptions.
 *
 *  @param dataProcessingBlock defaultJSONProcessingBlockForClass : MyFourDollarDrugList
 *  @param uiUpdateBlock       The code to update the UI. dataObject will be a MyFourDollarDrugList object
 *
 *  @return A SDRequestResult - check the result for cached, success or failure
 */
- (SDRequestResult*) fourDollarPrescriptionsWithDataProcessingBlock: (SDWebServiceDataCompletionBlock) dataProcessingBlock
                                                      uiUpdateBlock: (SDWebServiceUICompletionBlock) uiUpdateBlock;

@end
