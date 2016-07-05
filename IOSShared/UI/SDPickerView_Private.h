//
//  SDPickerView_Private.h
//  walmart
//
//  Created by Cihan Cimen on 2/22/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

@interface SDPickerView()
@property (nonatomic, readonly) UIToolbar *pickerBar;
@property (nonatomic, readonly) UIPickerView *itemPicker;
@property (nonatomic, readonly) UIPickerView *defaultPicker;

- (IBAction)startAction:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
