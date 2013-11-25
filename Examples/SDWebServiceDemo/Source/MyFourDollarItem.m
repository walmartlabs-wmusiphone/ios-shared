//
//  SDWebServiceDemo - MyFourDollarItem.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyFourDollarItem.h"


GENERICSABLE_IMPLEMENTATION( MyFourDollarItem )

@implementation MyFourDollarItem

- (NSDictionary*) mappingDictionaryForData: (id) data
{
#pragma unused( data )
    // Use <ClassName>property to attempt to type the return data recursively to the provided class name
    // Use @selector( selectorName ) to pass the key's data to the specified selector for processing
    // Comma-separated values can be used for multiple treatments: @selector( selectorName ), <NSString>property
    
    // The map is formatted as follows - responseKey: classProperty

    return @{ @"name": @"name",
              @"qty30Day": @"qty30Day",
              @"qty90Day": @"qty90Day" };
}

- (BOOL) validModel
{
    BOOL returnValue = NO;
    
    // For our model to be valid, our name string needs to be present and longer than 1 character.
    // Also, one of the 30- or 90-day strings needs to be present and longer than 1 character.
    
    if( ( self.name && self.name.length > 1 ) &&
        ( ( self.qty30Day && self.qty30Day.length > 0 ) || ( self.qty90Day && self.qty90Day.length > 0 ) ) )
    {
        returnValue = YES;
    }
    
    return returnValue;
}

#pragma mark - Property Sanitizers

- (void) setName: (NSString*) name
{
    _name = [[name removeExcessWhitespace] copy];
}

- (void) setQty30Day: (NSString*) qty30Day
{
    _qty30Day = [[qty30Day stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]] copy];
}

- (void) setQty90Day: (NSString*) qty90Day
{
    _qty90Day = [[qty90Day stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]] copy];
}

@end
