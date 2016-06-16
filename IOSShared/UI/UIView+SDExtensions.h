//
//  UIView+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (SDExtensions)

/**
 Set this to ensure that the center is positioned on full pixels. Read to see the closest integral center to the receiver's center.
 */
@property (nonatomic, assign) CGPoint integralCenter;

/**
 Set this to ensures that the frame is positioned on full pixels. Read to see the closest integral frame to the receiver's frame.
 */
@property (nonatomic, assign) CGRect integralFrame;

/** Convenience method to get/set this view's frame's x coordinate */
@property (nonatomic, assign) CGFloat x;

/** Convenience method to get/set this view's frame's y coordinate */
@property (nonatomic, assign) CGFloat y;

/** Convenience method to get/set this view's frame's width */
@property (nonatomic, assign) CGFloat width;

/** Convenience method to get/set this view's frame's height */
@property (nonatomic, assign) CGFloat height;

/** Convenience method to get/set this view's frame's origin */
@property (nonatomic, assign) CGPoint origin;

/** Convenience method to get/set this view's frame's size */
@property (nonatomic, assign) CGSize size;

/**
 Adjusts the receiver's frame to move it below `argOffset` pixels below the view passed in as `argView`. Other aspects of the frame are not changed.
 */
- (void)positionBelowView:(UIView *)argView offset:(CGFloat)argOffset;

/**
 Convenience method to set the receiver's `frame.origin.y`.
 */
- (void)setFrameOriginY:(CGFloat)newY;

/**
 Convenience method to set the receiver's `frame.origin.x`.
 */
- (void)setFrameOriginX:(CGFloat)newX;

/**
 Returns the first subview that is of the type of `aViewClass`. Returns `nil` if there's none found.
 */
- (id)firstSubviewOfClass:(Class)aViewClass;

/**
 Returns the subview of the recieving view that is an ancestor of distantSubview.
 */
- (UIView*)nearestAncestor:(UIView*)distantSubview;

/**
 Returns a visual stand-in for the current view that can be shown in it's place.
 On iOS7 it does snapshotViewAfterScreenUpdates: without waiting for updates.
 */
- (UIView *)snapshot;

/**
 Returns a visual stand-in for the current view that can be shown in it's place.
 On iOS7 you can control whether it applies updates first.
 */
- (UIView *)snapshotAfterScreenUpdates:(BOOL)applyUpdates;

/**
 Returns a UIImage representation of a view and it's subview heirarchy.
 */
- (UIImage *)screenshot;


@end
