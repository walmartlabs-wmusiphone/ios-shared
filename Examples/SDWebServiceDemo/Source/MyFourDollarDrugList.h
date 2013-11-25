//
//  SDWebServiceDemo - MyFourDollarDrugList.h
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"


/**
 *  MyFourDollarDrugList is a response object mapped from the Walmart Pharmacy service.
 *
 */

@protocol MyFourDollarCategory;


@interface MyFourDollarDrugList : SDModelObject

@property (nonatomic, strong, readonly) NSArray<MyFourDollarCategory>* drugCategoryList;

@end
