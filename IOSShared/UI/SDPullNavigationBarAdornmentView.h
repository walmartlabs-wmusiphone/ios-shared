//
//  SDPullNavigationBarAdornmentView.h
//  ios-shared
//
//  Created by Steven Woolgar on 03/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Adornment view (derived for ease of debugging and gesture handling)

@protocol SDPullNavigationBackgroundView <NSObject>

@optional

- (void) pullNavigationMenuWillAppear;
- (void) pullNavigationMenuDidDisappear;

@end

@interface SDPullNavigationBarAdornmentView : UIView
@property (nonatomic, strong) UIView* containerView;    // This is where the menu lives
@property (nonatomic, strong) UIImage* adornmentImage;  // This is where the optional adornment lives
@property (nonatomic, assign) CGRect baseFrame;         // If you set this I will account for the adornment view myself.
@property (nonatomic, assign) Class backgroundViewClass; // defaults to nil, if set extends below adornment

- (void) pullNavigationMenuWillAppear;
- (void) pullNavigationMenuDidDisappear;

@end
