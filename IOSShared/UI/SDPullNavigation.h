//
//  SDPullNavigation.h
//  ios-shared
//
//  Purpose:
//      - One navigation look functionality for all platforms with ability to customize branding.
//      - ViewController switching without hamburger menu. Like a tabBar without the lost space.
//      - API for adding UI elements to the bar.
//      - Mode that focuses & removes custom elements at will (think during edit mode)
//      - iOS6 & iOS7 support.
//      - Handles center-branding vs controller display name.
//      - Handles a nav override for the back button that limits the button to <
//
//  Created by Steven Woolgar on 11/26/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

// Import all of the classes necessary for the SDPullNavigation

#import "SDContainerViewController.h"
#import "SDPullNavigationAutomation.h"
#import "SDPullNavigationBarAdornmentView.h"
#import "SDPullNavigationBarControlsView.h"
#import "SDPullNavigationManager.h"
