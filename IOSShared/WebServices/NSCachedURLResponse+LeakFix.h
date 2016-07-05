//
//  NSCachedURLResponse+LeakFix.h
//  SetDirection
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012-2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCachedURLResponse (LeakFix)

/**
 Workaround for a leak in iOS 5.0 and later when the data property is accessed.
 @bug iOS 5.0 and 5.1 have a leak when accessing NSCachedURLResponse.data.
 At this time we haven't verified if iOS 6 and later have the issue too so this code runs for iOS 5 and later.
 If the data backed in the NSCachedURLResponse meets certain criteria the method will always return the same NSData but with its retain count incremented.
 In other cases, we will get back a new NSData.
 This accessor attempts to release the overretained memory if the objects are the same and multiple accesses have seemingly increased the retain count.
 The Analyzer warning can be ignored because we are doing evil things in this code
 */

- (NSData *)responseData;

@end
