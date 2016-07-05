//
//  SDWebService+SDProcessingBlocks.h
//  RxClient
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDWebService.h"

@interface SDWebService (SDProcessingBlocks)

/**
 Returns a data processing block for converting JSON data into a dictionary or array.
 */
+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable dictionary or array.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into an array.
 */
+ (SDWebServiceDataCompletionBlock)defaultArrayJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable array.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableArrayJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a dictionary.
 */
+ (SDWebServiceDataCompletionBlock)defaultDictionaryJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable dictionary.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableDictionaryJSONProcessingBlock;

/**
 *  A default JSON processing block based on a particular RxObject subclass.
 *
 *  @param classType An SDModelObject subclass.  The result object will have it's properties mapped into it from
 *  the service response JSON.
 *
 *  @param errorClassType An
 *
 *  @return A block of code that can be used with the various service calls.
 *  This block will create a "classType" object mapped with the server response
 *  JSON, if the  server presents a standard error, an RxResponseError class is created
 *  rather than the classType. The UI completion block should check for both.
 *
 */
+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlockForClass:(Class)classType errorClassType:(Class)errorClassType;

/**
 Returns an error class to be used inside of defaultJSONProcessingBlockForClass:
 */
+ (Class)errorClass;

/**
 Returns a data processing block for converting JSON data into a specific model class, or the class type returned from -errorClass.
 */
+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlockForClass:(Class)classType;

@end
