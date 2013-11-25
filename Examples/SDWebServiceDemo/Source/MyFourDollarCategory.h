//
//  SDWebServiceDemo - MyFourDollarCategory.h
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"


/**
 *  MyFourDollarCategory is a response object mapped from the Walmart Pharmacy service.
 *
 */

@protocol MyFourDollarItem;

@interface MyFourDollarCategory : SDModelObject

@property (nonatomic, copy, readonly) NSString* categoryName;
@property (nonatomic, strong, readonly) NSArray<MyFourDollarItem>* drugList;

@end
