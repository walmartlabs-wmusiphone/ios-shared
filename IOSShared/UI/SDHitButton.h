//
//  SDHitButton.h
//  ios-shared

//
//  Created by Steve Riggins on 1/22/14.
//  Copyright 2014 SetDirection. All rights reserved.
//
//  Poorly named class on purpose until we come to agreement on what "SDButton" should do by default
//
//  Supports optional hitInsets that allow for hit testing different than the frame

#import <UIKit/UIKit.h>

@interface SDHitButton : UIButton
/**
 *  Setting the hitInsets to anything other than UIEdgeInsetsZero overrides minimumHitSize
 *  Specify negative values to increase the hit area
 */
@property (nonatomic, assign) UIEdgeInsets hitInsets;

/**
 *  If hitInsets is not set, then calculate a hit area that is at least this large
 */
@property (nonatomic, assign) CGSize minimumHitSize;
@end
