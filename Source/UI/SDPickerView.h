//
//  SDPickerView.h
//
//  Created by Douglas Pedley on 12/13/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+SDExtensions.h"

@class SDPickerView;

typedef void(^SDPickerViewDateCompletionBlock)(BOOL canceled, NSDate *selectedDate);
typedef void(^SDPickerViewItemSelectionCompletionBlock)(BOOL canceled, NSInteger selectedItemIndex, NSString *selectedItem);
/**
 * @param canceled      true if Cancel button is tapped  
 * @param pickerView    pickerView on which Cancel or Done actions happened
 */
typedef void(^SDPickerViewItemSelectionDefaultCompletionBlock)(BOOL canceled, SDPickerView *pickerView);

@protocol SDPickerViewDelegate <NSObject>
@optional
- (void)pickerViewDidShow:(SDPickerView *)pickerView;
- (void)pickerViewWillShow:(SDPickerView *)pickerView;
@end


@interface SDPickerView : UIButton

-(void)configureAsDatePickerWithCompletion:(SDPickerViewDateCompletionBlock)completion;
-(void)configureAsDatePicker:(NSDate *)initialDate completion:(SDPickerViewDateCompletionBlock)completion;
-(void)configureAsDatePicker:(NSDate *)initialDate datePickerMode:(UIDatePickerMode)datePickerMode completion:(SDPickerViewDateCompletionBlock)completion;

-(void)configureAsItemPicker:(NSArray<NSString>*)items completion:(SDPickerViewItemSelectionCompletionBlock)completion;
-(void)configureAsItemPicker:(NSArray<NSString>*)items initialItem:(NSInteger)selectedItem completion:(SDPickerViewItemSelectionCompletionBlock)completion;

/**
 * Configures SDPickerView to work with regular UIPickerView data source and delegates. 
 * @param dataSource    Object to be used as underlying UIPickerView's dataSource
 * @param delegate      Object to be used as underlying UIPickerView's delegate
 * @param completion    Callback to be invoked when Done or Cancel button is tapped
 */
-(void)configureAsDefaultPicker:(id<UIPickerViewDataSource>)dataSource delegate:(id<UIPickerViewDelegate>)delegate completion:(SDPickerViewItemSelectionDefaultCompletionBlock)completion;

-(IBAction)cancelAction:(id)sender;

@property (nonatomic, weak) id<SDPickerViewDelegate> delegate;

@end
