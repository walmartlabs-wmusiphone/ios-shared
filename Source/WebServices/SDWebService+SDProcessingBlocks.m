//
//  SDWebService+SDDataProcessingBlocks.m
//  RxClient
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDWebService+SDProcessingBlocks.h"
#import "SDModelObject.h"
#import "NSData+SDExtensions.h"
#import "SDLog.h"

@implementation SDWebService (SDProcessingBlocks)

#pragma mark - Default processing blocks

+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONObject];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONObjectMutable:YES error:nil];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultArrayJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONArray];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableArrayJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONMutableArray];
        return dataObject;
    };
    return result;

}

+ (SDWebServiceDataCompletionBlock)defaultDictionaryJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONDictionary];
        return dataObject;
    };
    return result;
}

+ (SDWebServiceDataCompletionBlock)defaultMutableDictionaryJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS

    SDWebServiceDataCompletionBlock result = ^(NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        id dataObject = nil;
        if (responseData && responseData.length > 0)
            dataObject = [responseData JSONMutableDictionary];
        return dataObject;
    };
    return result;
}

+ (Class)errorClass
{
    return [SDErrorModelObject class];
}

+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlockForClass:(Class)classType;
{
    Class errorClass = [[self class] errorClass];
    return [[self class] defaultJSONProcessingBlockForClass:classType errorClassType:errorClass];
}

+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlockForClass:(Class)classType errorClassType:(Class)errorClassType
{
    NSAssert([classType isSubclassOfClass:[SDModelObject class]], @"defaultJSONProcessingBlockForClass: works on concrete subclasses of SDModelObject");

    SDWebServiceDataCompletionBlock completionBlock = ^id (NSURLResponse *response, NSInteger responseCode, NSData *responseData, NSError *error) {
        
        SDLog(@"%@: %zd:\n%@", response, responseCode, [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);

        id responseObject = [responseData JSONObject];

        // First check for error response codes
        id<SDDataMapProtocol> errorObject = [errorClassType mapFromObject:responseObject];
        if (errorObject)
            return errorObject;

        /* One of the standards for webservices wraps the accompanying data in a "data" dictionary
           one level in.  We'll handle that format too since it's not hard or intensive. */

        // First let's find the data subobject if it exists
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            // some service responses have an encapsulating data object.
            NSDictionary *dataDictionary = [responseObject dictionaryForKey:@"data"];
            // if it has one, lets set that as our response object instead.
            while (dataDictionary)
            {
                responseObject = dataDictionary;
                dataDictionary = [responseObject dictionaryForKey:@"data"];
            }
        }

        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            return [classType mapFromObject:responseObject];
        }
        else
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSArray *responseObjects = responseObject;
            NSMutableArray *modelObjects = [NSMutableArray array];

            for (NSUInteger i = 0; i<[responseObjects count]; i++)
            {
                NSDictionary *dataDictionary = [responseObjects objectAtIndex:i];
                NSDictionary *subDictionary = [dataDictionary objectForKey:@"data"];
                // if it has one, lets set that as our response object instead.
                if (subDictionary)
                    dataDictionary = subDictionary;

                SDModelObject *modelObject = [classType mapFromObject:dataDictionary];

                if (modelObject)
                    [modelObjects addObject:modelObject];
            }
            
            if ([modelObjects count] > 0)
                return [NSArray arrayWithArray:modelObjects];
        }

        return nil;
    };
    
    return completionBlock;
}

@end
