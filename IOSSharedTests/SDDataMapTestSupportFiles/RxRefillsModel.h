//
//  RxRefillsModel.h
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxModelObject.h"
#import "RxPatientModel.h"
#import "RxAddressModel.h"
#import "RxOrderModel.h"

@interface RxRefillsModel : RxModelObject

@property (nonatomic, strong, readonly) RxPatientModel *patient;
@property (nonatomic, strong, readonly) RxAddressModel *address;
@property (nonatomic, strong, readonly) NSArray<RxOrderModel> *orders;

@end
