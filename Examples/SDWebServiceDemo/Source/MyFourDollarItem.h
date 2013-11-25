//
//  SDWebServiceDemo - MyFourDollarItem.h
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"


/**
 *  MyFourDollarItem is a response object mapped from the Walmart Pharmacy service.
 *
 */

GENERICSABLE( MyFourDollarItem )

@interface MyFourDollarItem : SDModelObject

@property (nonatomic, copy, readonly) NSString* name;
@property (nonatomic, copy, readonly) NSString* qty30Day;
@property (nonatomic, copy, readonly) NSString* qty90Day;

@end
