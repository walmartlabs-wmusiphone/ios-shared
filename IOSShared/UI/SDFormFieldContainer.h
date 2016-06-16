//
//  SDFormFieldContainer.h
//  ios-shared

//
//  Created by Brandon Sneed on 1/16/14.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDFormFieldContainer : UIView

@property (nonatomic, assign) CGFloat separatorInset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@end
