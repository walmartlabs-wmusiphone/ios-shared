//
//  RxRefillsModel.m
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxRefillsModel.h"

@implementation RxRefillsModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"patientName": @"(RxPatientModel)patient",
             @"primaryAddress": @"<RxAddressModel>address",
             @"RxFill": @"(NSArray<RxOrderModel>)orders"};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"patient": @"(NSDictionary)patientName",
             @"address": @"(NSDictionary)primaryAddress",
             @"orders": @"(NSArray<NSDictionary>)RxFill"};
}

@end
