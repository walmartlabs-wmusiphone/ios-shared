//
//  SDCheckbox.h
//  ios-shared

//
//  Created by Brandon Sneed on 1/15/14.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDCheckbox : UIControl

@property (nonatomic, strong) UIColor *checkboxColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat checkboxWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, assign) BOOL checked;

@end
