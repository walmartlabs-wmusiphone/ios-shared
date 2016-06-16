//
//  RxPatientModel.m
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxPatientModel.h"

@implementation RxPatientModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"firstName": @"firstName",
             @"lastName": @"lastName",
             @"middleName": @"middleName"};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"lastName": @"lastName"};
}

@end
