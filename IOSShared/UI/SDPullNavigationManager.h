//
//  SDPullNavigationManager.h
//  ios-shared

//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDPullNavigationBar.h"
#import "UIImage+SDExtensions.h"

@class SDPullNavigationBarControlsView;

@interface SDPullNavigationManager : NSObject<UINavigationControllerDelegate>

/**
 Override to draw the tab button. Defaults to SDPullNavigationBarTabButton.
 @optional
 */

@property (nonatomic, strong) Class pullNavigationBarTabButtonClass;

/**
 Flag to determine whether the menu gets drawn with a shadow or not.
 */

@property (nonatomic, assign) BOOL disableShadowOnMenuContainer;

/**
 Image that goes on the bottom of the menu to indicate that it is closable.
 @optional
 */

@property (nonatomic, strong) UIImage* menuAdornmentImage;

/**
 Image that goes on the bottom of the menu to indicate that it is closable.
 This is a replacement for the one right above. In case where we need to stretch an image
 over variable widths (for example when portrait and landscape have different menu widths)
 this stretch plus center image can be used to draw the properly stretched images without stretching
 the center part.
 @optional
 */

- (void)menuAdornmentImageWithStretchImage:(UIImage*)leftImage andCenterImage:(UIImage*)centerImage compositionOptions:(SDImageCompositionOptions)imageCompositionOptions;

@property (nonatomic, strong) UIImage* menuAdornmentImageStretch;
@property (nonatomic, strong) UIImage* menuAdornmentImageCenter;
@property (nonatomic, assign) SDImageCompositionOptions menuAdornmentImageCompositionOptions;

/**
 This is the offset to make the bottom adornment tuck neatly under the navbar.
 This works if the bottom adornment looks like the top adornment but is slight taller.
 This measurement is the difference in height between the two.
 @optional
 */

@property (nonatomic, assign) CGFloat menuAdornmentImageOverlapHeight;


/**
 This is the offset to make the bottom adornment doesn't get too close to the bottom of the screen.
 Measured in pts from the bottom of the screen. The default is 44pts.
 @optional
 */

@property (nonatomic, assign) CGFloat menuAdornmentBottomGap;

/**
 The storyboard ID to use for the global menu.
 */

@property (nonatomic, copy) NSString* globalMenuStoryboardId;
@property (nonatomic, weak) id<SDPullNavigationSetupProtocol> delegate;
@property (nonatomic, strong) SDContainerViewController* globalPullNavController;

/**
 Accessibility Label to apply to Navigation Bar
 */

@property (nonatomic, copy) NSString *navigationBarAccessibilityLabel;

/**
 Set this on while pushing a new nav. If this is YES then I won't override your nav items with the global ones.
 */

@property (nonatomic, assign) BOOL showGlobalNavControls;   // Turn this off and I won't take away your navigationItems

+ (instancetype)sharedInstance;
- (void)navigateWithSteps:(NSArray*)steps;

/**
 Navigate to one of the top level view controllers defined in the 'globalPullNavController'.
 */
- (BOOL)navigateToTopLevelController:(Class)topLevelViewControllerClass;

/**
 Navigate to one of the top level view controllers defined in the 'globalPullNavController' and pop to the
 root.
 */
- (void)navigateToTopLevelController:(Class)topLevelViewControllerClass andPopToRootWithAnimation:(BOOL)animate;

@end
