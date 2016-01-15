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

// Low level bits
#import "SDMacros.h"
#import "ObjectiveCGenerics.h"

// Only include ios-shared SDLog is needed and defined
#ifdef SDLOG
#import "SDLog.h"
#endif

#import "SDAssert.h"
#import "SDAccessible.h"

// Foundation Extensions
#import "NSError+SDExtensions.h"
#import "NSObject+SDExtensions.h"
#import "NSString+SDExtensions.h"
#import "NSDate+SDExtensions.h"
#import "NSRunLoop+SDExtensions.h"
#import "NSArray+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "NSData+SDExtensions.h"

// UIKit Extensions
#import "UIAlertView+SDExtensions.h"
#import "UIApplication+SDExtensions.h"
#import "UIColor+SDExtensions.h"
#import "UIDevice+machine.h"
#import "UIResponder+SDExtensions.h"
#import "UIScreen+SDExtensions.h"
#import "UIView+SDExtensions.h"
#import "UIViewController+SDExtensions.h"
#import "SDAlertView.h"

// Application Additions
#import "SDApplication.h"

// Services
#import "SDURLConnection.h"
#import "SDWebService.h"
#import "SDWebService+SDProcessingBlocks.h"

#endif
