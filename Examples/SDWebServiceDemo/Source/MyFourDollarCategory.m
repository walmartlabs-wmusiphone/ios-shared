//
//  SDWebServiceDemo - MyFourDollarCategory.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyFourDollarCategory.h"


@implementation MyFourDollarCategory

- (NSDictionary*) mappingDictionaryForData: (id) data
{
#pragma unused( data )
    // Use <ClassName>property to attempt to type the return data recursively to the provided class name
    // Use @selector( selectorName ) to pass the key's data to the specified selector for processing
    // Comma-separated values can be used for multiple treatments: @selector( selectorName ), <NSString>property
    
    // The map is formatted as follows - responseKey: classProperty

    return @{ @"category": @"categoryName",
              @"drugList": @"<MyFourDollarItem>drugList" };
}

- (BOOL) validModel
{
    // This object doesn't require validation; just return yes.

    return YES;
}

@end
