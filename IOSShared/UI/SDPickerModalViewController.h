//
//  SDPickerModalViewController.h
//  SetDirection
//
//  Created by brandon on 4/29/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller that provides a ready-made modal picker for convenience. The presenting view controller provides the picker view data source and delegate.
 */

typedef void (^SDPickerBlock)(void);

@interface SDPickerModalViewController : UIViewController
{
    UIPickerView *pickerView;
    UIView *backgroundView;
    
    SDPickerBlock doneBlock;
    SDPickerBlock cancelBlock;
}

/**
 The picker view. The presenting controller must provide the data source and delegate for this picker.
 */
@property (nonatomic, strong, readonly) IBOutlet UIPickerView *pickerView;

/**
 The preferred method to init this controller.
 */
- (id)init;

/**
 Presents the modal picker controller.
 @param controller The presenting view controller.
 @param done The block to execute when the Done button is pressed.
 @param cancel The block to execute when the Cancel button is pressed.
 */
- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel;

/**
 Presents the modal picker controller with a pre-selected row and component.
 @param controller The presenting view controller.
 @param done The block to execute when the Done button is pressed.
 @param cancel The block to execute when the Cancel button is pressed.
 @param row The row to pre-select on display.
 @param component The component to pre-select on display.
 */
- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel withSelectedRow:(NSInteger)row inComponent:(NSInteger)component;

@end
