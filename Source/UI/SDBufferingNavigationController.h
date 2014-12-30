//
//  SDBufferingNavigationController.h
//  walmart
//
//  Created by David Pettigrew on 12/18/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SDBufferingNavigationController extends UINavigationController to automatically queue up transitions between view controllers.
 
 This prevents you receiving errors such as:
 "Finishing up a navigation transition in an unexpected state. Navigation Bar subview tree might get corrupted."
 
 This can happen if you try to pushViewController during an existing transition.
 
 To use, simply add the provided files to your project and change your UINavigationController class to inherit from SDBufferingNavigationController in Interface Builder.
 Based upon https://github.com/Plasma/BufferedNavigationController
 */
@interface SDBufferingNavigationController : UINavigationController <UINavigationControllerDelegate>

@end
