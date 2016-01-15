//
//  SDPhotoImageView.h
//  Photos
//
//  Created by Brandon Sneed on 5/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPhotoImageView;

@protocol SDPhotoImageViewDelegate <NSObject>
@optional
/**
 Called when the view is tapped.
 */
- (void)photoImageView:(SDPhotoImageView *)photoImageView wasTappedAtPoint:(CGPoint)point;
@end

/**
 SDPhotoImageView is a view that provides panning/zooming of a given image.  Image URLs can be
 supplied to it via its imageView property.  See UIImageView+SDExtensions.h for more information
 on supplying URLs.
 */
@interface SDPhotoImageView : UIView<UIScrollViewDelegate>

/**
 Delegate.  Must conform to SDPhotoImageViewDelegate protocol.
 */
@property (nonatomic, weak) id<SDPhotoImageViewDelegate> delegate;
/**
 The UIImageView contained within.  Useful for setting the image directly or via setImageURL: (see UIImageView+SDExtensions.h)
 */
@property (nonatomic, readonly) UIImageView *imageView;

@end
