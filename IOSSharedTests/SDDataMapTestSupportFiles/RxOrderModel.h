//
//  RxOrdersModel.h
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/26/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "ObjectiveCGenerics.h"
#import "RxModelObject.h"

GENERICSABLE(RxOrderModel)

@interface RxOrderModel : RxModelObject

@property (nonatomic, strong, readonly) NSString *drug;
@end
