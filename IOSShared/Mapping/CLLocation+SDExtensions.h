//
//  CLLocation+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation(SDExtensions)

+ (CLLocation *)locationWithCoordinates:(CLLocationCoordinate2D)coordinates;
+ (CLLocationDistance)getDistanceFromLocation:(CLLocation *)location1 toLocation:(CLLocation *)location2;

@end
