//
//  SDQuantityEditViewBehavior.h
//
//  Created by Robb Albright on 17.4.12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SDAdjustableItem.h"

typedef void (^SDQuantityEditViewBehaviorWillChangeQuantityBlock)(BOOL increment);
typedef void (^SDQuantityEditViewBehaviorDidChangeQuantityBlock)(BOOL increment);
/**
 A protocol that a view that wants to use a SDQuantityEditViewBehavior must conform to.
 */
@protocol SDQuantityEditViewProtocol

/**
 Returns the EditView's plus button
 */
- (UIButton *)plusButton;

/**
 Returns the EditView's minus button
 */
- (UIButton *)minusButton;

/**
 Returns the EditView's label that displays current quantity
 */
- (UILabel *)quantityLabel;

/**
 Returns the EditView's label that displays current cost
 */
- (UILabel *)totalPriceLabel;

/**
 Returns the EditView's label that displays current weight
 */
- (UILabel *)totalWeightLabel;

/**
 Returns the EditView's value for limitMinimumQuantityOnNewItemsToStepAmount
 */
@property (nonatomic, assign) BOOL limitMinimumQuantityOnNewItemsToStepAmount;

@optional
/**
 Returns the EditView's UIImageView that displays the background image
 */
- (UIImageView *)backgroundImageView;

@end

/**
 A class that handles the logic behind incrementing and decrementing an AdjustableItem depending on the type of SDProductQuantityMethod 
 the adjustableItem supports.
 
 If none of the SDProductQuantityMethod provide what you need, you can subclass this behavior and customize how the item's quantity is changed.
 You should also subclass SDEditQuantityView so that defaultQuantityBehavior returns the proper behavior.
 */
@interface SDQuantityEditViewBehavior : NSObject

/**
 The quantity of the adjustableItem when this behavior was created.  This can be reset by a client if needed.
 */
@property (nonatomic, strong) NSDecimalNumber *originalQuantity;

/**
 The new quantity of the adjustableItem.  Note this is nil if there is no change in quantity.
 */
@property (nonatomic, strong, readonly) NSDecimalNumber *updatedQuantity;


/**
 The weight suffix on the quantity.  This is only used for kAdjustableItemQuantityMethod_Weighted and defaults to "kg".
 */
@property (nonatomic, copy) NSString *weightSuffix;

/**
 Arbitrary suffix on the quantity.  This suffix is always added (after weightSuffix).  Can be used for "in cart" or "in list"
 */
@property (nonatomic, copy) NSString *quantitySuffix;

/**
 The formatter used to display the total price of the adjustableItem.  This defaults to using £ as the currency symbol.
 */
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;

/**
 A block called when the adjustableItem is about to change quantity.
 @param incremented YES if the value will be incremented.  NO if it will be decremented
 */
@property (nonatomic, copy) SDQuantityEditViewBehaviorWillChangeQuantityBlock willChangeQuantity;

/**
 A block called when the adjustableItem changed quantity
 @param incremented YES if the value incremented.  NO if decremented
 */
@property (nonatomic, copy) SDQuantityEditViewBehaviorDidChangeQuantityBlock didChangeQuantity;

/**
 Creates a new SDQuantityEditViewBehavior with the given adjustableItem and SDQuantityEditViewProtocol
 */
- (id)initWithAdjustableItem:(id<SDAdjustableItem>)adjustableItem delegate:(UIView<SDQuantityEditViewProtocol> *)delegate;

/**
 Takes the current state as the new baseline.  In other words, sets originalQuantity to currentQuantity and updatedQuantity back to nil.
 Useful after the underlying item has been updated and you want the SDQuantityEditViewProtocol updated to reflect that change.
 */
- (void)setCurrentAsBaseline;

/**
 *  resets the original qty to 0.  Does a little bit of bookkeeping as well, reseting the currentQty to 1 (so 0 never shows in the
 *  SDQuantityEditViewProtocol and updating the buttons.
 *
 *  TODO: it may make sense to put this logic in the setOriginalQuantity method.  I need to see how it is being used first.
 */
- (void)resetOriginalQuantity;
- (void)resetCurrentQuantity;

@end
