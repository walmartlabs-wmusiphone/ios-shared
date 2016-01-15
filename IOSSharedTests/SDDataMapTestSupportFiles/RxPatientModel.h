//
//  RxPatientModel.h
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "RxModelObject.h"

@interface RxPatientModel : RxModelObject

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *middleName;

@end
