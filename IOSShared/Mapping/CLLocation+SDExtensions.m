//
//  CLLocation+SDExtensions.m
//  SetDirection
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;

#import "CLLocation+SDExtensions.h"


@implementation CLLocation(SDExtensions)

+ (CLLocation *)locationWithCoordinates:(CLLocationCoordinate2D)coordinates
{
	CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
	return location;
}

+ (CLLocationDistance)getDistanceFromLocation:(CLLocation *)location1 toLocation:(CLLocation *)location2
{
	// are we measuring in miles or kilometers?
	NSNumber *unit = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
	CLLocationDistance distance = [location1 distanceFromLocation:location2];
	
	if (unit)
		distance *= 0.001; // kilometers
	else
		distance *= 0.000621371192; // miles
	return distance;
}

@end
