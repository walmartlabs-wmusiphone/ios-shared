//
//  RxAddressModel.m
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxAddressModel.h"

@implementation RxAddressModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"street1": @"street"};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"street": @"street1"};
}

@end
