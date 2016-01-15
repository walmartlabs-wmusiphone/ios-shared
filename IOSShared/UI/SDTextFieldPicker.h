//
//  SDTextFieldPicker.h
//  walmart
//
//  Created by Brandon Sneed on 1/9/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTextField.h"
#import "NSString+SDExtensions.h"

@interface SDTextFieldPicker : SDTextField

@property (nonatomic, copy) NSArray<NSString> *pickerItems;
@property (nonatomic, strong) UIColor *pickerButtonColor UI_APPEARANCE_SELECTOR;

@end
