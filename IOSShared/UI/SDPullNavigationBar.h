//
//  SDPullNavigationBar.h
//  ios-shared
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDContainerViewController.h"

@class SDPullNavigationBar;

typedef NS_ENUM(NSUInteger, SDPullNavigationBarSide) {
    SDPullNavigationBarSideLeft,
    SDPullNavigationBarSideRight
};

@protocol SDPullNavigationSetupProtocol <NSObject, UITabBarControllerDelegate>
@required
/** Method for supplying global navigation button items whenever a new view controller
 * is pushed onto the stack.
 *
 * @param SDPullNavigationBarSide side is just a simple param for which side you are supplying buttons for
 * @param UIViewController viewController provides the view controller being displayed in case that 
 * affects your selection of buttons
 * @return NSArray of UIBarButtonItems in the appropriate order for whichever side you are supplying.
 * @warning Note that if your global buttons are always staying in the same position, you can reuse the same button. But
 * if your buttons move around position wise at all, you will want to provide a new copy each time (e.g. leftItemsSupplementBackButton)
 * @warning Note that global navigation is only set on push, which means buttons on previous view controllers should stay functional
 **/
- (NSArray*)globalNavigationBarItemsForSide:(SDPullNavigationBarSide)side withViewController:(UIViewController*)viewController;
- (SDContainerViewController*)setupGlobalContainerViewController;
@end

@protocol SDPullNavigationBarDelegate <NSObject>
@required
@property (nonatomic, weak) SDPullNavigationBar* pullNavigationBarDelegate;
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuHeight;

@optional
@property (nonatomic, strong, readonly) UIColor *pullNavigationMenuTopExtensionBackgroundColor; // Defaults to whiteColor
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidth;                // Defaults to 320.0f

// If you implement the two following calls, pullnav will allow different widths per orientation and overrides the single width one.
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidthForPortrait;     // Defaults to 320.0f
@property (nonatomic, assign, readonly) CGFloat pullNavigationMenuWidthForLandscape;    // Defaults to 320.0f

@property (nonatomic, assign, readonly) Class pullNavigationMenuBackgroundViewClass; // for when you want to extend under the footer adornment

@property (nonatomic, assign, readonly) UIColor *pullNavigationLightboxEffectColor;

- (void)pullNavMenuWillAppear;
- (void)pullNavMenuDidAppear;

- (void)pullNavMenuWillDisappear;
- (void)pullNavMenuDidDisappear;

@end

@interface SDPullNavigationBar : UINavigationBar

@property (nonatomic, strong) IBOutlet UIViewController <SDPullNavigationBarDelegate>* menuController;

+ (void)setupDefaults;
+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController;

- (IBAction)tapAction:(id)sender;
- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion;
- (void)bouncePullMenuWithCompletion:(void (^)(void))completion;
@end
