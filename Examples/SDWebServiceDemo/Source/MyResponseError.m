//
//  SDWebServiceDemo - MyResponseError.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyResponseError.h"


@implementation MyResponseError

- (NSDictionary*) mappingDictionaryForData: (id) data
{
#pragma unused( data )
    // The map is formatted as follows - responseKey: classProperty
    
    return @{ @"code": @"error",
              @"error": @"message" };
}

- (BOOL) validModel
{
    BOOL returnValue = NO;
    
    // For this to be a valid error response it'll need both a message, and a non-zero error.
    
    if( self.message != nil && self.error != 0 )
    {
        returnValue = YES;
    }
    
    return returnValue;
}

@end
