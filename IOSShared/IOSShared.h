//
//  IOSShared.h
//  IOSShared
//
//  Created by Eric Sheppard on 1/14/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for IOSShared.
FOUNDATION_EXPORT double IOSSharedVersionNumber;

//! Project version string for IOSShared.
FOUNDATION_EXPORT const unsigned char IOSSharedVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <IOSShared/PublicHeader.h>

#ifdef __OBJC__

// Required frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Low level stuff
#include "ObjectiveCGenerics.h"
#include "SDAccessible.h"
#include "SDAssert.h"
#include "SDMacros.h"

// Only include ios-shared SDLog is needed and defined
//#ifdef SDLOG
#import "SDLog.h"
//#endif

// extensions
#include "NSArray+SDExtensions.h"
#include "NSData+SDExtensions.h"
#include "NSDate+SDExtensions.h"
#include "NSDictionary+SDExtensions.h"
#include "NSError+SDExtensions.h"
#include "NSLayoutConstraint+SDExtensions.h"
#include "NSMutableAttributedString+SDExtensions.h"
#include "NSNumber+SDExtensions.h"
#include "NSRunLoop+SDExtensions.h"
#include "NSString+SDExtensions.h"
#include "NSUserDefaults+SDExtensions.h"
#include "SDBase64.h"
#include "SDCompletionGroup.h"
#include "SDDataMap.h"
#include "SDModelObject+REST.h"
#include "SDModelObject.h"
#include "SDPoser.h"
#include "SDPromise.h"
#include "SDTimer.h"
#include "SDURLRouteHandler.h"
#include "SDURLRouter.h"
#include "SDURLRouterEntry.h"
#include "SDWeakArray.h"
#include "UIDevice+machine.h"
#include "UIResponder+SDExtensions.h"

// web service stuff
#include "NSCachedURLResponse+LeakFix.h"
#include "NSURL+SDExtensions.h"
#include "NSURLCache+SDExtensions.h"
#include "NSURLRequest+SDExtensions.h"
#include "Reachability.h"
#include "SDImageCache.h"
#include "SDURLConnection.h"
#include "SDWebService+SDProcessingBlocks.h"
#include "SDWebService.h"
#include "SDWebServiceMockResponseMapProvider.h"
#include "SDWebServiceMockResponseProvider.h"
#include "SDWebServiceMockResponseQueueProvider.h"
#include "SDWebServiceMockResponseRequestMapping.h"
#include "UIImageView+SDExtensions.h"

// defaults
#include "WMDefaultsEntry.h"

// UI stuff
#include "SDSearchBar.h"
#include "SDSearchSuggestionsDataSource.h"
#include "SDSearchSuggestionsViewController.h"
#include "SDSearchUsageDelegate.h"
#include "SDSpanParser.h"
#include "SDStackView.h"
#include "SDSwitch.h"
#include "SDTableViewCommand.h"
#include "SDTableViewSectionController.h"
#include "SDTableViewSectionControllerAutoAlwaysUpdateRow.h"
#include "SDTableViewSectionControllerAutoUpdateRow.h"
#include "SDTextField.h"
#include "SDTextFieldPicker.h"
#include "SDTouchCaptureView.h"
#include "SDWebViewCell.h"
#include "UIActivityIndicatorView+SDExtensions.h"
#include "UIAlertView+SDExtensions.h"
#include "UIApplication+SDExtensions.h"
#include "UIButton+SDExtensions.h"
#include "UIColor+SDExtensions.h"
#include "UIImage+SDExtensions.h"
#include "UINavigationController+SDExtensions.h"
#include "UIScreen+SDExtensions.h"
#include "UITableView+SDAutoUpdate.h"
#include "UITableViewCell+SDExtensions.h"
#include "UIView+SDExtensions.h"
#include "UIViewController+SDExtensions.h"
#include "SDAdjustableItem.h"
#include "SDPaintCodeButton.h"
#include "SDQuantityEditView.h"
#include "SDQuantityEditViewBehavior.h"
#include "SDQuantityView.h"
#include "UIView+PaintCode.h"
#include "SDDeckController.h"
#include "SDDragDropGestureRecognizer.h"
#include "SDDragDropManager.h"
#include "SDExpandingTableViewController.h"
#include "SDFormFieldContainer.h"
#include "SDHitButton.h"
#include "SDImageButton.h"
#include "SDLabel.h"
#include "SDMultilineLabel.h"
#include "SDNavigationBarSearchField.h"
#include "SDNumberTextField.h"
#include "SDPaddedLabel.h"
#include "SDPagingView.h"
#include "SDPhotoImageView.h"
#include "SDPickerModalViewController.h"
#include "SDPickerView.h"
#include "SDPullNavigation.h"
#include "SDPullNavigationAutomation.h"
#include "SDPullNavigationBar.h"
#include "SDPullNavigationBarAdornmentView.h"
#include "SDPullNavigationBarBackground.h"
#include "SDPullNavigationBarControlsView.h"
#include "SDPullNavigationBarTabButton.h"
#include "SDPullNavigationManager.h"
#include "SDCard.h"
#include "SDCardNumber.h"
#include "SDCardType.h"
#include "SDCCTextField.h"
#include "SDCreditCardField.h"
#include "NSObject+SDExtensions.h"
#include "NSShadow+SDExtensions.h"
#include "SDAlertView.h"
#include "SDApplication.h"
#include "SDAutolayoutStackView.h"
#include "SDButton.h"
#include "SDCheckbox.h"
#include "SDCollapsableContainerView.h"
#include "SDContainerViewController.h"
#include "SDContentAlertView.h"

// testing
#include "SDABTesting.h"

// security
#include "SDKeychain.h"
#include "SDTouchID.h"

// mapping
#include "CLLocation+SDExtensions.h"
#include "MKMapView+SDExtensions.h"
#include "SDLocationManager.h"


#endif
