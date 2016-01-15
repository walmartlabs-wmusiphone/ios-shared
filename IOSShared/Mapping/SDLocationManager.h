//
//  SDLocationManager.h
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SDMacros.h"

typedef NS_ENUM(NSUInteger,SDLocationManagerAuthorizationScheme) {
    SDLocationManagerAuthorizationAlways,
    SDLocationManagerAuthorizationWhenInUse
};

extern NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey; /** Allows the SDLocationManager to persistently record whether it has received at least 1 valid location update during the life of the app. This is useful when other classes need to know whether user has tapped 'OK' on the iOS location permission alert. */

@protocol SDLocationManagerDelegate <NSObject>
@optional
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation __deprecated__("Use locationManager:didUpdateLocations: instead");;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didUpdateToInaccurateLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_2);

@end

@interface SDLocationManager: NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) BOOL hasReceivedLocationUpdate;
@property (nonatomic, readonly) BOOL isUpdatingLocation;
@property (nonatomic, readonly) BOOL isUpdatingHeading;
@property (nonatomic, readonly) BOOL isLocationAllowed;
@property (nonatomic, readonly) BOOL isLocationRejected;
@property (nonatomic, readonly) CLLocation *currentLocation;

+ (SDLocationManager *)sharedInstance;

/// Forwards requestAlwaysAuthorization to internal CLLocationManager instance
- (void)requestAlwaysAuthorization;
/// Forwards requestWhenInUseAuthorization to internal CLLocationManager instance
- (void)requestWhenInUseAuthorization;

- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy;
- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy authorization:(SDLocationManagerAuthorizationScheme)authorization;
- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter authorization:(SDLocationManagerAuthorizationScheme)authorization;
- (void)stopUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate;
- (void)stopUpdatingLocationForAllDelegates;

//- (BOOL) startMonitoringForSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate;
//- (void) stopMonitoringSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate;
//- (void) stopMonitoringSignificantLocationChangesForAllDelegates;

@end
