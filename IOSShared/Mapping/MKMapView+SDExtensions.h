//
//  MKMapView+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/16/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define CLCOORDINATE_EPSILON 0.00000001f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

typedef NSObject<MKAnnotation> SDAnnotation;

@interface MKMapView(SDExtensions)

- (void)setRegionThatFits:(MKCoordinateRegion)region animated:(BOOL)animated;

- (SDAnnotation *)getClosestAnnotationToLocation:(CLLocation *)location andSelect:(BOOL)inSelect;
- (SDAnnotation *)getNextClosestAnnotation:(SDAnnotation *)referenceAnnotation andSelect:(BOOL)inSelect;

- (NSArray *) annotationsByDistanceToLocation:(CLLocation *)location;

- (CLLocationCoordinate2D)centerCoordinateForAnnotations:(NSArray *)annotationArray;
- (void) recenterMapForAnnotations:(NSArray *)annotationArray withLocation:(CLLocation *)location padding:(CLLocationDegrees)padding;
- (void) recenterAroundLocation:(CLLocation *)location showAnnotations:(NSArray *)annotationArray;

- (NSSet *)visibleAnnotations;
- (NSArray *)userAnnotations;

@end

// helper functions
double radiusToMeters(double radius);
double degreesToRadians(double degrees);
double radiansToDegrees(double radians);

