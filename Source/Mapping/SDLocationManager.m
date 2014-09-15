//
//  SDLocationManager.m
//
//  Created by brandon on 2/11/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;

#import "SDLocationManager.h"
#import "NSArray+SDExtensions.h"

#import <objc/message.h>

#define LocLog(frmt,...) SDLog(@"SDLocationManager: %@",[NSString stringWithFormat:frmt, ##__VA_ARGS__])

#define kSDLocationManagerTrace DEBUG && 1
#if kSDLocationManagerTrace
    #define LocTrace(frmt,...) LocLog(frmt, ##__VA_ARGS__)
#else
    #define LocTrace(frmt,...)
#endif


NSString *kSDLocationManagerHasReceivedLocationUpdateDefaultsKey = @"SDLocationManagerHasReceivedLocationUpdate";


/** An internal class for tracking delegate registrations. */
@interface SDLocationManagerDelegateRegistration : NSObject
@property (nonatomic, strong) id<SDLocationManagerDelegate> delegate;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@end
@implementation SDLocationManagerDelegateRegistration
- (NSUInteger) hash {
    return [self.delegate hash];
}
- (BOOL) isEqual:(id)object {
    if (NO == [object isKindOfClass:[self class]]) {
        return NO;
    }
    return self.delegate == [(SDLocationManagerDelegateRegistration *)object delegate];
}
- (NSString *) description {
    return [NSString stringWithFormat:@"%@ delegate = %@; desiredAccuracy = %@; distanceFilter = %@",[super description],self.delegate,@(self.desiredAccuracy),@(self.distanceFilter)];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _distanceFilter = kCLDistanceFilterNone;
        _desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}
@end



@interface SDLocationManager ()

@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

@property (nonatomic, readwrite) BOOL isUpdatingLocation;
@property (nonatomic, readwrite) BOOL isUpdatingHeading;


@property (nonatomic, strong) NSMutableSet *delegateRegistrations;
@property (nonatomic, strong) dispatch_queue_t delegatesAccessQueue;
@property (nonatomic, readonly) NSArray *delegates;

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic,weak) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic) BOOL gotFirstLocationUpdate;

@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, strong) NSDate *previousLocationUpdatedAt;

@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;

@end


@implementation SDLocationManager

// ========================================================================== //

#pragma mark - Properties


@dynamic isLocationAllowed;
- (BOOL)isLocationAllowed {
    if (self.authorizationStatus == kCLAuthorizationStatusAuthorized || self.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

@dynamic hasReceivedLocationUpdate;
-(BOOL)hasReceivedLocationUpdate {
	return [[NSUserDefaults standardUserDefaults] boolForKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
}

@dynamic delegates;
- (NSArray *) delegates {
    __block NSSet *delegates = nil;
    dispatch_sync(_delegatesAccessQueue, ^{
        delegates = [_delegateRegistrations valueForKey:@"delegate"];
    });
    return [delegates allObjects];
}

@dynamic authorizationStatus;
- (CLAuthorizationStatus)authorizationStatus {
    return [CLLocationManager authorizationStatus];
}



// ========================================================================== //

#pragma mark - Object



+ (SDLocationManager *) sharedInstance {
    static SDLocationManager *sdLocationManagerInstance = nil;
    static dispatch_once_t locationManagerInitToken;
    dispatch_once(&locationManagerInitToken, ^{
        if (nil == sdLocationManagerInstance) {
            sdLocationManagerInstance = [self new];
        }
    });
	return sdLocationManagerInstance;
}

- (id)init {
	self = [super init];
	if (self) {
        _timeout = 60;
        _delegateRegistrations = [[NSMutableSet alloc] init];
        _delegatesAccessQueue = dispatch_queue_create("com.sd.SDLocationManager.delegatesAccessQueue", DISPATCH_QUEUE_CONCURRENT);
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }

	return self;
}

- (void)dealloc {
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;
}



// ========================================================================== //

#pragma mark - Public Interface




- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy {
    return [self startUpdatingLocationWithDelegate:delegate desiredAccuracy:accuracy distanceFilter:kCLDistanceFilterNone];
}

- (BOOL)startUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate desiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter {
    LocLog(@"startUpdatingLocationWithDelegate:%@ desiredAccuracy:%@ distanceFilter:%@",delegate,@(accuracy),@(distanceFilter));
    if (NO == [self _delegate:delegate isRegisteredForDesiredAccuracy:accuracy distanceFilter:distanceFilter]) {
        [self _deregisterDelegate:delegate]; // In case it's registered for another accuracy or distance filter
        [self _registerDelegate:delegate forDesiredAccuracy:accuracy distanceFilter:distanceFilter];

        if (NO == [self _internalStart]) {
            [self stopUpdatingLocationWithDelegate:delegate];
            return NO;
        }
    }

    return YES;
}

- (void)stopUpdatingLocationWithDelegate:(id<SDLocationManagerDelegate>)delegate {
    LocLog(@"%@%@",NSStringFromSelector(_cmd),delegate);
    [self _deregisterDelegate:delegate];
    if ([self.delegates count] < 1) {
        [self _internalStop];
    }
}

- (void)stopUpdatingLocationForAllDelegates {
    NSArray *delegates = self.delegates;
    for (id delegate in delegates) {
        [self stopUpdatingLocationWithDelegate:delegate];
    }
}

//- (BOOL)startUpdatingHeadingWithDelegate:(id<SDLocationManagerDelegate>)delegate {
//    //FIXME: These don't actually work with the delegates mechanism
//    [self unsupported:_cmd];
//    return NO;
//}
//
//- (void)stopUpdatingHeadingWithDelegate:(id<SDLocationManagerDelegate>)delegate {
//    //FIXME: These don't actually work with the delegates mechanism
//    [self unsupported:_cmd];
//}
//
//- (BOOL) startMonitoringForSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate {
//	//TODO: implement this in such a way that if any delegate is interested in more active updates this stays off, but comes on when other delegates have resigned their interest
//	[self unsupported:_cmd];
//	return NO;
//}
//
//- (void) stopMonitoringSignificantLocationChangesWithDelegate:(id<SDLocationManagerDelegate>)delegate {
//	//TODO: implement this so that it turns off location updates unless other delegates are also interested in this service
//	[self unsupported:_cmd];
//}
//
//- (void) stopMonitoringSignificantLocationChangesForAllDelegates {
//	//TODO: implement this so that any delegate that is soley interested in this service is removed, but those interested in active updates are left observing
//	[self unsupported:_cmd];
//}


- (void)requestAlwaysAuthorization
{
#ifdef __IPHONE_8_0
    // Must request permission here
    if ([UIDevice systemMajorVersion] >= 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
#endif

}

- (BOOL)isPreviousLocationWithin:(NSInteger)seconds {
    NSInteger diff = [self.previousLocationUpdatedAt timeIntervalSinceNow] * -1;
    
    //return ([self.previousLocationUpdatedAt timeIntervalSinceNow] < seconds);
    return (diff < seconds);
}

- (CLLocation *)getPreviousLocation {
    return self.previousLocation;
}


// ========================================================================== //

#pragma mark - Internal

/** !!! Anything in here that accesses _delegateRegistrations directly must either be dispatched on _delegatesAccessQueue or be called from a block on that queue. */



- (BOOL) _internalStart {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
    if (NO == [self isLocationAllowed]) {
        LocLog(@"[WARN] - Location services not allowed!");
        [self _internalStop];
        [self locationManager:self.locationManager didFailWithError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:nil]];
        return NO;
    }

    /** When you are dealing with mutliple delegates, all of whom may register for updates at any point in the process of resolution, you need to first stop the service then start it again to ensure the new delegate receives delviery of at least one update event. This includes resetting the timeout so each new delegate doesn't get caught in the "waiting forever" edge case. */
    if (_isUpdatingLocation) {
        [self _internalStop];
    }

    _timestamp = [NSDate date];
    
    [self requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];

    _isUpdatingLocation = YES;

    LocLog(@"Location updates ** STARTED **");
    return YES;
}

- (void) _internalStop {
    LocLog(@"%@",NSStringFromSelector(_cmd));
	[_timeoutTimer invalidate];
	_timeoutTimer = nil;

	_timestamp = nil;

    [self.locationManager stopUpdatingLocation];

    _isUpdatingLocation = NO;
    _gotFirstLocationUpdate = NO;

    LocLog(@"Location updates ** STOPPED **");
}

- (void) _registerDelegate:(id<SDLocationManagerDelegate>)delegate forDesiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
    dispatch_barrier_async(_delegatesAccessQueue, ^{
        SDLocationManagerDelegateRegistration *delegateRegistration = [SDLocationManagerDelegateRegistration new];
        delegateRegistration.delegate = delegate;

        CLLocationAccuracy desiredAccuracy = accuracy;

        //???: This is a carry-over from past implmentations where there was only one accuracy setting, do we want to do this for every delegate? Seems weird to set accuracy so much lower than what was requested ..
//    // actually set it somewhat below what we want.  this insures we get something under what we asked for.
//    desiredAccuracy -= 600;
//    if (desiredAccuracy < 10) {
//        desiredAccuracy = kCLLocationAccuracyBest;
//    }

        delegateRegistration.desiredAccuracy = desiredAccuracy;
        delegateRegistration.distanceFilter = distanceFilter;
        [_delegateRegistrations addObject:delegateRegistration];

        [self _updateDesiredAccuracyAndDistanceFilter];

        LocTrace(@"*ADDED* delegate:%@",delegate);
    });
}

- (void) _deregisterDelegate:(id<SDLocationManagerDelegate>)delegate {
    dispatch_barrier_async(_delegatesAccessQueue, ^{
        SDLocationManagerDelegateRegistration *existingRegistration = [[_delegateRegistrations objectsPassingTest:^BOOL(SDLocationManagerDelegateRegistration *obj, BOOL *stop) {
            return obj.delegate == delegate;
        }] anyObject];
        if (existingRegistration) {
            [_delegateRegistrations removeObject:existingRegistration];

            LocTrace(@"*REMOVED* delegate:%@",delegate);
            
            [self _updateDesiredAccuracyAndDistanceFilter];
        }
    });
}

- (BOOL) _delegate:(id<SDLocationManagerDelegate>)delegate isRegisteredForDesiredAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distanceFilter {
    __block BOOL isRegistered = NO;
    dispatch_barrier_sync(_delegatesAccessQueue, ^{
        SDLocationManagerDelegateRegistration *existingRegistration = [[_delegateRegistrations objectsPassingTest:^BOOL(SDLocationManagerDelegateRegistration *obj, BOOL *stop) {
            return obj.delegate == delegate && obj.desiredAccuracy == accuracy && obj.distanceFilter == distanceFilter;
        }] anyObject];
        isRegistered = (nil != existingRegistration);
    });
    return isRegistered;
}

- (void) _updateDesiredAccuracyAndDistanceFilter
{
    // Only call these things outside of a barrier block in order to avoid
    //  deadlocks.
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL wasUpdating = _isUpdatingLocation;
        [self _internalStop];
        [self.locationManager setDesiredAccuracy:[self _greatestDesiredAccuracy]];
        [self.locationManager setDistanceFilter:[self _finestDistanceFilter]];
        if (wasUpdating)
        {
            [self _internalStart];
        }

        LocTrace(@"self.desiredAccuracy:%@",@(self.locationManager.desiredAccuracy));
        LocTrace(@"self.distanceFilter:%@",@(self.locationManager.distanceFilter));
    });
}

- (CLLocationAccuracy) _greatestDesiredAccuracy {
    CLLocationAccuracy greatestDesiredAccuracy = kCLLocationAccuracyThreeKilometers;
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        if (registration.desiredAccuracy < greatestDesiredAccuracy) {
            greatestDesiredAccuracy = registration.desiredAccuracy;
            if (greatestDesiredAccuracy <= kCLLocationAccuracyBest) {
                break;
            }
        }
    }
    return greatestDesiredAccuracy;
}

- (CLLocationDistance) _finestDistanceFilter {
    LocTrace(@"=> %@",NSStringFromSelector(_cmd));
    LocTrace(@"registrations: %@",_delegateRegistrations);
    CLLocationDistance finestDistanceFilter = DBL_MAX;
    for (SDLocationManagerDelegateRegistration *registration in _delegateRegistrations) {
        CLLocationDistance distanceFilter = registration.distanceFilter;
        if (distanceFilter < finestDistanceFilter) {
            finestDistanceFilter = registration.distanceFilter;
            if (finestDistanceFilter == kCLDistanceFilterNone) {
                break;
            }
        }
    }
    LocTrace(@"<= finestDistanceFilter:%@",@(finestDistanceFilter));
    return finestDistanceFilter;
}

- (void) _timeoutHandler {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
	_timeoutTimer = nil;

	// if we have a location, pass it along...
	if (self.locationManager.location) {
        CLLocation *location = self.locationManager.location;
        NSArray *locations = @[location];
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateLocations:) argumentAddresses:(void *)&self, &locations];
        //REMOVE: when all usages of the now deprecated locationManager:didUpdateToLocation:fromLocation: are cleared.
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) argumentAddresses:(void *)&self, &location, &location];
	}
	else {
		// otherwise, lets simulate a failure...
        NSError *error = [NSError errorWithDomain:kCLErrorDomain code:0 userInfo:nil];
        [self.delegates makeObjectsPerformSelector:@selector(locationManager:didFailWithError:) argumentAddresses:(void *)&self, &error];
	}
}



// ========================================================================== //

#pragma mark CLLocationManagerDelegate


/** Calls to our delegates' methods are dispatched async because if they call back into us and get blocked waiting on the delegates lock we end up with the main thread blocked, which is, um bad. */

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    LocTrace(@"%@%@",NSStringFromSelector(_cmd),locations);
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation = nil;
    if ([locations count] > 1) {
        oldLocation = locations[[locations count]-2];
    }
    else {
        oldLocation = _previousLocation;
    }

    if ( ! _gotFirstLocationUpdate ) {
        LocLog(@"Got first location update");
        // dont start the timeout until we got the first location change, which should only happen after the user said YES to
        // Apple's built-in prompt to use current location, or if use of location was pre-approved in a previous run. And once
        // approved, this should always get called at least once, so we should never have a case of waiting forever to get here
        _gotFirstLocationUpdate = YES;
		
		//Ensure this is set as well. This BOOL differs slightly from 'gotFirstLocationUpdate' and is handled separately as such:
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey: kSDLocationManagerHasReceivedLocationUpdateDefaultsKey];
		
        // timeout in 60 (or whatever they set it to) seconds.
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(_timeoutHandler) userInfo:nil repeats:NO];
    }
    
	LocTrace(@"newLocation = %@", newLocation);
    LocTrace(@"newLocation horizontalAccuracy: %f", newLocation.horizontalAccuracy);
	LocTrace(@"desiredAccuracy = %@", @(self.locationManager.desiredAccuracy));
	LocTrace(@"distanceFilter = %@", @(self.locationManager.distanceFilter));
	if ([newLocation.timestamp timeIntervalSinceDate:_timestamp] < 0) {
		LocLog(@"This location was cached.");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegates makeObjectsPerformSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:) argumentAddresses:(void *)&self, &newLocation, &oldLocation];
        });
        _previousLocation = newLocation;
        _previousLocationUpdatedAt = [NSDate date];
        return; // this one is cached, lets wait for a good one.
	}
	
    // Because each delegate now sets its own accuracy requirements we need to test each one against the new location's accuracy and distance delta; some may be interested in less accurate / finer distance updates than others.

    // Get a safe copy that isn't being mutated while we iterate over it and let's not lock up the delegates queue too long
    __block NSSet *delegateRegistrations = nil;
    dispatch_sync(_delegatesAccessQueue, ^{
        delegateRegistrations = [_delegateRegistrations copy];
    });

    LocLog(@"Dispatching updates to delegates..");
    for (SDLocationManagerDelegateRegistration *registration in delegateRegistrations) {
        id<SDLocationManagerDelegate> delegate = registration.delegate;

        BOOL passesDelegateRequirements = YES;

        CLLocationAccuracy desiredAccuracy = registration.desiredAccuracy;
        if ((newLocation.horizontalAccuracy < 0) || (newLocation.horizontalAccuracy > desiredAccuracy)) {
            passesDelegateRequirements = NO;
            LocLog(@"This location didn't meet the accuracy requirements (%f) for delegate %@.", newLocation.horizontalAccuracy, delegate);
        }

        CLLocationDistance distanceFilter = registration.distanceFilter;
        if (_previousLocation) {
            CLLocationDistance distance = [_previousLocation distanceFromLocation:newLocation];
            LocLog(@"previousLocation.distanceFromLocation(newLocation) : %@",@(distance));
            if (distance < distanceFilter) {
                passesDelegateRequirements = NO;
                LocLog(@"This location did not satisfy the distance filter (%@) for this delegate %@",@(distanceFilter),delegate);
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (NO == passesDelegateRequirements) {
                if ([delegate respondsToSelector:@selector(locationManager:didUpdateToInaccurateLocation:fromLocation:)]) {
                    [delegate locationManager:self.locationManager didUpdateToInaccurateLocation:newLocation fromLocation:oldLocation];
                }
            }
            else {
                LocLog(@"Location obtained for delegate %@",registration.delegate);
                if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
                    [delegate locationManager:self.locationManager didUpdateLocations:locations];
                }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                //REMOVE: when all usages of the now deprecated locationManager:didUpdateToLocation:fromLocation: are cleared.
                if ([delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
                    [delegate locationManager:self.locationManager didUpdateToLocation:newLocation fromLocation:oldLocation];
                }
#pragma clang diagnostic pop
            }
        });
    }

    _previousLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
	if ([newHeading.timestamp timeIntervalSinceDate:_timestamp] < 0)
		return; // this one is cached, lets wait for a good one.

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &newHeading];
    });
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    LocLog(@"[ERROR] - %@%@",NSStringFromSelector(_cmd),error);
	// we're masking out didFail unless they've said NO to the "allow" dialog.
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &error];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
    });
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region];
    });
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    LocTrace(@"%@",NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &region, &error];
    });
}

//- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
//    LocTrace(@"%@",NSStringFromSelector(_cmd));
//    [self unsupported:_cmd];
//    return FALSE;
//}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    LocLog(@"%@",NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegates makeObjectsPerformSelector:_cmd argumentAddresses:(void *)&self, &status];
    });
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self stopUpdatingLocationForAllDelegates];
    }
}

@end
