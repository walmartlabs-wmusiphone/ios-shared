//
//  SDSwitch.h
//
//  Created by Brandon Sneed on 11/7/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
//  Based on MBSwitch by Mathieu Bolard.
//  https://github.com/mattlawer/MBSwitch
//  Copyright (c) 2013, Mathieu Bolard All rights reserved.

#import <UIKit/UIKit.h>

@interface SDSwitch : UIControl

/**
 *  The border outline/tint color
 */
@property(nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;

/**
 *  The border outline/tint color when the switch is in the ON state.
 */
@property(nonatomic, strong) UIColor *onTintColor UI_APPEARANCE_SELECTOR;

/**
 *  The fill color for the OFF state.
 */
@property(nonatomic, weak) UIColor *offTintColor UI_APPEARANCE_SELECTOR;

/**
 *  The color to use for the thumb slider.
 */
@property(nonatomic, weak) UIColor *thumbTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Retrieves the state of the switch.
 */
@property(nonatomic,getter=isOn) BOOL on;

/**
 *  Sets the state of the switch.
 *
 *  @param on       state value
 *  @param animated determines whether the state change should be animated
 */
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
