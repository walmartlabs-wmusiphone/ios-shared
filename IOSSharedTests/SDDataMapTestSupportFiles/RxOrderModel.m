//
//  RxOrdersModel.m
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxOrderModel.h"

GENERICSABLE_IMPLEMENTATION(RxOrderModel)

@implementation RxOrderModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"drug": @"drug"};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"drug": @"drug"};
}

@end
