//
//  MKMapView+SDExtensions.m
//  SetDirection
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

@import CoreLocation;
@import MapKit;

#import "MKMapView+SDExtensions.h"
#import "CLLocation+SDExtensions.h"

@implementation MKMapView(SDExtensions)

- (void)setRegionThatFits:(MKCoordinateRegion)region animated:(BOOL)animated
{
	MKCoordinateRegion newRegion = [self regionThatFits:region];
	[self setRegion:newRegion animated:animated];
}

- (SDAnnotation *)getClosestAnnotationToLocation:(CLLocation *)location andSelect:(BOOL)inSelect
{
	NSArray *annotations = [self userAnnotations];
	if ([annotations count] < 1)
		return nil;
	
	SDAnnotation *result = nil;
	CLLocationDistance shortestDistance = CLLocationDistanceMax;
	
	for (SDAnnotation* annotation in annotations)
	{
		CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
		CLLocationDistance thisDistance = [location distanceFromLocation:endPoint];
		if ((thisDistance < shortestDistance) && !CLCOORDINATES_EQUAL2(location.coordinate, annotation.coordinate)) // changed to not compare doubles with !=
		{
			shortestDistance = thisDistance;
			result = annotation;
		}
	}
	
	if (inSelect && result)
		self.selectedAnnotations = [NSArray arrayWithObject:result];	
	
	return result;
}

- (SDAnnotation *)getNextClosestAnnotation:(SDAnnotation *)referenceAnnotation andSelect:(BOOL)inSelect
{
	CLLocation *location = [[CLLocation alloc] initWithLatitude:referenceAnnotation.coordinate.latitude longitude:referenceAnnotation.coordinate.longitude];
	return [self getClosestAnnotationToLocation:location andSelect:inSelect];
}

- (NSArray *)annotationsByDistanceToLocation:(CLLocation *)location
{
	NSMutableArray *result = [NSMutableArray new];
	NSArray *annotationList = self.annotations;
	
	SDAnnotation *annotation = [self getClosestAnnotationToLocation:location andSelect:NO];
	if (annotation)
		[result addObject:annotation];
	
	while (annotation)
	{
		if ([result count] >= [annotationList count])
			break;

		annotation = [self getNextClosestAnnotation:annotation andSelect:NO];
		if (annotation)
			[result addObject:annotation];
	}
	
	return result;
}

- (CLLocationCoordinate2D) centerCoordinateForAnnotations:(NSArray *)annotationArray
{
	double totalD = 0;
	double x = 0, y = 0, z = 0;
	
	for (SDAnnotation *annotation in annotationArray)
	{
		CLLocationCoordinate2D coord = annotation.coordinate;
		double latitude = degreesToRadians(coord.latitude);
		double longitude = degreesToRadians(coord.longitude);
		
		double cx, cy, cz, cd;
		cx = cos(latitude) * cos(longitude);
		cy = cos(latitude) * sin(longitude);
		cz = sin(latitude);
		cd = 1.0; // days in a given location, unused.
		
		totalD += cd;
		
		x += (cx * cd);
		y += (cy * cd);
		z += (cz * cd);
	}
	
	x = x / totalD;
	y = y / totalD;
	z = z / totalD;
	
	CLLocationCoordinate2D newCenter = {0, 0};
	newCenter.longitude = radiansToDegrees(atan2(y, x));
	double hyp = sqrt(x * x + y * y);
	newCenter.latitude = radiansToDegrees(atan2(z, hyp));
	
	return newCenter;
}

- (void) recenterMapForAnnotations:(NSArray *)annotationArray withLocation:(CLLocation *)location padding:(CLLocationDegrees)padding
{
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	
	// i wouldn't have to do this crap if MKAnnotation were an actual object type.
	CLLocationCoordinate2D coord = location.coordinate;
	
	if(coord.latitude > maxCoord.latitude)
		maxCoord.latitude = coord.latitude;
	if(coord.longitude > maxCoord.longitude)
		maxCoord.longitude = coord.longitude;
	
	if(coord.latitude < minCoord.latitude)
		minCoord.latitude = coord.latitude;
	if(coord.longitude < minCoord.longitude)
		minCoord.longitude = coord.longitude;
	
	for(SDAnnotation *annotation in annotationArray)
	{
		coord = annotation.coordinate;
		
		if(coord.latitude > maxCoord.latitude)
			maxCoord.latitude = coord.latitude;
		if(coord.longitude > maxCoord.longitude)
			maxCoord.longitude = coord.longitude;
		
		if(coord.latitude < minCoord.latitude)
			minCoord.latitude = coord.latitude;
		if(coord.longitude < minCoord.longitude)
			minCoord.longitude = coord.longitude;
	}
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	
	region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
	region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
	region.span.longitudeDelta = (maxCoord.longitude - minCoord.longitude) + padding;
	region.span.latitudeDelta = (maxCoord.latitude - minCoord.latitude) + padding;
	
	[self setRegionThatFits:region animated:YES];
}

- (void) recenterAroundLocation:(CLLocation *)location showAnnotations:(NSArray *)annotationArray
{
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	
	// i wouldn't have to do this crap if MKAnnotation were an actual object type.
	CLLocationCoordinate2D coord = location.coordinate;
	
	if(coord.latitude > maxCoord.latitude)
		maxCoord.latitude = coord.latitude;
	if(coord.longitude > maxCoord.longitude)
		maxCoord.longitude = coord.longitude;
	
	if(coord.latitude < minCoord.latitude)
		minCoord.latitude = coord.latitude;
	if(coord.longitude < minCoord.longitude)
		minCoord.longitude = coord.longitude;
	
	for(SDAnnotation *annotation in annotationArray)
	{
		coord = annotation.coordinate;
		
		if(coord.latitude > maxCoord.latitude)
			maxCoord.latitude = coord.latitude;
		if(coord.longitude > maxCoord.longitude)
			maxCoord.longitude = coord.longitude;
		
		if(coord.latitude < minCoord.latitude)
			minCoord.latitude = coord.latitude;
		if(coord.longitude < minCoord.longitude)
			minCoord.longitude = coord.longitude;
	}
	
	CLLocation *minLocation = [CLLocation locationWithCoordinates:minCoord];
	CLLocation *maxLocation = [CLLocation locationWithCoordinates:maxCoord];
	CLLocationDistance distance = [minLocation distanceFromLocation:maxLocation] / 2;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, distance, distance);
	
	[self setRegionThatFits:region animated:YES];
}

- (NSSet *)visibleAnnotations;
{
	const MKCoordinateRegion theRegion = self.region;
	
	NSMutableSet *theVisibleAnnotations = [NSMutableSet set];
	
	for (id<MKAnnotation> theAnnotation in self.annotations)
	{
		CLLocationCoordinate2D theCoordinate = theAnnotation.coordinate;
		
		if (theCoordinate.latitude < theRegion.center.latitude - theRegion.span.latitudeDelta)
			continue;
		if (theCoordinate.latitude > theRegion.center.latitude + theRegion.span.latitudeDelta)
			continue;
		if (theCoordinate.longitude < theRegion.center.longitude - theRegion.span.longitudeDelta)
			continue;
		if (theCoordinate.longitude > theRegion.center.longitude + theRegion.span.longitudeDelta)
			continue;
		
		[theVisibleAnnotations addObject:theAnnotation];
	}
	
	return theVisibleAnnotations;
}

// returns a filtered version of self.annotations
- (NSArray *)userAnnotations
{
	NSArray *annotations = [self.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class != %@", [MKUserLocation class]]];
	return annotations;
}

@end

#pragma mark helper functions

double radiusToMeters(double radius)
{
	// are we measuring in miles or kilometers?
	NSNumber *unit = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
	if (![unit boolValue])
		return (radius * 1609.344);
	return (radius * 1000);
}

double degreesToRadians(double degrees)
{
	return (M_PI / 180) * degrees;
}

double radiansToDegrees(double radians)
{
	return (180 / M_PI) * radians;
}

