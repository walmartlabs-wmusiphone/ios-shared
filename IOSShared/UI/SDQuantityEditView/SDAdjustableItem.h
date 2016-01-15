//
//  SDAdjustableItem.h
//
//  Created by ricky cancro on 1/7/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The currently supported types of Quantity Adjustment.
 */

typedef NS_ENUM(NSUInteger, SDProductQuantityMethod)
{
    /**
     Adjusts the item by weight in increments of .1
     */
    kAdjustableItemQuantityMethod_Weighted,
    /**
     Adjusts the item by whole numbers in increments of 1
     */
    kAdjustableItemQuantityMethod_Counted,
    /**
     The most confusing option.  For items that are bought by count, but also have
     a weight. Quantity will be incremented by 1, but the total weight will
     also be computed and shown on the SDEditQuantityView.  
     
     An example of this type of adjustment behavior would be buying produce.  You
     could purchase 3 bananas which will weight roughly .5lb each.  The Edit Quantity View
     will show the whole number 3, but also show that you will get "about 1.5lbs" of bananas.
     */
    kAdjustableItemQuantityMethod_Both
};

@protocol SDAdjustableItem<NSObject>

/**
 Returns the type of adjustment that this item should use.  See above for the supported types.
 */
- (SDProductQuantityMethod)adjustQuantityMethod;

/**
 Returns the price of this item for it's given unit of measure.
 */
- (NSString *)pricePerUnitOfMeasure;

/**
 Returns the maximum number of this type of item than can be purchased.
 */
- (NSString *)maxQuantity;

@optional
/**
 Returns the average weight of 1 of the item.  This is only required if the adjustable item's
 quantity adjustment type is kAdjustableItemQuantityMethod_Both.
 */
- (NSString *)averageWeight;

/**
 Returns the current quantity of this item.
 */
- (NSString *)quantity;

@end
