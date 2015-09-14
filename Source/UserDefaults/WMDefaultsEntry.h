//
//  WMDefaultsEntry.h
//  walmart
//
//  Created by David Pettigrew on 1/22/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 Designed to be an abstract base class for application defaults classes. 
 Provides a wrapper for storing keyed data in NSUserDefaults.
 */
@interface WMDefaultsEntry : NSObject

/// The unique keyname of the class
@property (nonatomic, copy) NSString *keyName;

- (instancetype)initWithKey:(NSString *)keyName;

/// erases the value from storage
- (void)clear;

@end

/// A generic user defaults storage class of a core location coordinate
@interface WMDefaultsLocationEntry : WMDefaultsEntry

/**
 Set/Get the location coordinate.
 For the getter, clients should check the returned value is valid using CLLocationCoordinate2DIsValid.

 @return Either a valid coordinate or a coordinate with the value kCLLocationCoordinate2DInvalid
 **/
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

/// A generic user defaults storage class for a string object
@interface WMDefaultsStringEntry : WMDefaultsEntry

@property (nonatomic, copy) NSString *stringValue;

@end

/// A generic user defaults storage class for a BOOL value
@interface WMDefaultsBoolEntry : WMDefaultsEntry

@property (nonatomic) BOOL boolValue;

@end

// TODO: Add WMDefaults____Entry classes for other data types and primitives that get persisted (NSDictionary, NSArray, integers etc)
