//
//  NSUserDefaults+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/12/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSUserDefaults(SDExtensions)

/**
 Returns `YES` if the key exists. `NO` otherwise.
 
 You normally won't need this, but its handy when looking up coordinates since. They aren't of an object type.
 */
- (BOOL)keyExists:(NSString *)key;

/**
 Returns the `CLLocationCoordinate2D` for the given key, assuming that it was previously stored using the setCoordinate:forKey: method. If the object for the given key is not of the expected type, the behavior is undefined.
 */
- (CLLocationCoordinate2D)coordinateForKey:(NSString *)key;

/**
 Sets a `CLLocationCoordinate2D` in the user defaults for the given key.
 */
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate forKey:(NSString *)key;

@end
