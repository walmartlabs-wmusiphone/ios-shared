//
//  SDQuantityEditView.h
//
//  Created by ricky cancro on 1/7/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDQuantityEditViewBehavior.h"

@class SDQuantityView;

typedef void (^SDQuantityEditViewRemoveBlock)(NSDecimalNumber *originalQuantity);
typedef void (^SDQuantityEditViewDoneEditingBlock)(NSDecimalNumber *originalQuantity, NSDecimalNumber *updatedQuantity);

/**
 A UIView that uses a SDQuantityView to adjust the quantity of a SDAdjustableItem.  The class uses a SDQuantityEditViewBehavior
 to determine how the item is adjusted.  That is, if the item is sold by weight it will increment/decrement by .1kg when changed.
 For more information on the SDQuantityEditViewBehavior, see SDQuantityEditViewBehavior.h.
 
 This view displays not only the SDQuantityView but also the total price (and possibly weight) for the current number of the SDAdjustableItem.
 It also has a "done" and "remove" button to commit the changes made to the adjustable item.
 */
@interface SDQuantityEditView : UIView<SDQuantityEditViewProtocol>

/**
 The item that will have its quantity changed.
 */
@property (nonatomic, strong) id<SDAdjustableItem> adjustableItem;

/**
 A BOOL to put the EditView into an editable/uneditable state.  If a service call is required to change the item's quantity
 set this to YES while the call is in progress.  When the call has finished set it back to NO.
 */
@property (nonatomic, assign, getter = isCommitting) BOOL committing;

/**
 The user of this view should define this block to define what happens when a user taps the done button.
 @param originalQuantity The original quantity of the adjustable item before any quantity adjustments were made
 @param updatedQuantity The new quantity of the adjustable item.  If nil then the quantity was not changed.
 */
@property (nonatomic, copy) SDQuantityEditViewDoneEditingBlock doneTappedBlock;

/**
 The user of this view should define this block to define what happens when a user taps the remove button.
 @param originalQuantity The original quantity of the adjustable item before any quantity adjustments were made.
 
 Note: There is no updatedQuantity since it is assumed to be 0.
 */
@property (nonatomic, copy) SDQuantityEditViewRemoveBlock removeTappedBlock;


/**
 The following UIViews are available so that the user of this class can style them to suite their needs
 */

/**
 An UIImageView to add a dropshadow if desired.
 */
@property (nonatomic, strong, readonly) IBOutlet UIImageView *dropShadowImageView;

/**
 An UIImageView to add the background image for the quantity edit view.  (Rememeber you can just
 set the background color if that's all you need).
 */
@property (nonatomic, strong, readonly) IBOutlet UIImageView *backgroundImageView;

/**
 The label that displays the total cost of adjustable item
 */
@property (nonatomic, strong, readonly) IBOutlet UILabel *totalPriceLabel;

/**
 The label that displays the total weight of adjustable item
 */
@property (nonatomic, strong, readonly) IBOutlet UILabel *weightLabel;

/**
 The SDQuantityView used in this view. You can set its fillColor.
 */
@property (nonatomic, strong, readonly) SDQuantityView *quantityView;


/**
 The Activity Indicator that appears when committing is set to YES
 */
@property (nonatomic, strong, readonly) IBOutlet UIActivityIndicatorView *activitingIndicator;

/**
 The remove button.  DO NOT set this button directly.  It isn't readonly so subclasses can
 override createDoneAndRemoveButtons to set a custom button class.  (I know, lame but that
 was the fastest way to get this into shared code.)  You are free to set properties on
 the button, just not the button itself.
 */
@property (nonatomic, strong) IBOutlet UIButton *removeButton;

/**
 The done button.  DO NOT set this button directly.  It isn't readonly so subclasses can
 override createDoneAndRemoveButtons to set a custom button class.  (I know, lame but that
 was the fastest way to get this into shared code.)  You are free to set properties on
 the button, just not the button itself.
 */
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

/**
 This function is provided so that a subclass can customize what happens when the editView goes into a commit state.
 This method is called automatically by the commit property.  DO NOT CALL this method by itself.
 */
- (void)updateUIForCommittingState;

- (void)adjustableItemChanged;

/**
 Provide access to the behavior so subclasses can check its values
 */
@property (nonatomic, readonly) SDQuantityEditViewBehavior *quantityBehavior;

/**
 Subclass SDQuantityEditView and override this method to provide a custom Quantity Behavior.
 @return the quantity behavior for this edit quantity view.
 */
- (SDQuantityEditViewBehavior *)defaultQuantityBehavior;

/**
 Subclass SDQuantityEditView and override this method to provide custom buttons for doneButton and removeButton.
 */
- (void)createDoneAndRemoveButtons;

/**
 There are uses of the quantity editor where it makes sense to limit the minimum quantity
 to the step amount (e.g. 1 for units, 0.1 for kg) instead of 0. For instance, the product
 details view controller will show the editor for items not in the cart with an 'Add'
 button, but it does not make sense to add zero items to the cart, so we need to limit the
 minimum value to the step amount.

 Most uses of the editor will be fine with a zero minimum so that is the default value.
 */
@property (nonatomic, assign) BOOL limitMinimumQuantityOnNewItemsToStepAmount;

/**
 Creates a SDQuantityEditView
 @return a new SDQuantityEditView
 */
+ (instancetype)quantityEditView;

@end
