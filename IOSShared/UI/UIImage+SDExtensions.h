//
//  UIImage+SDExtensions.h
//  SetDirection
//
//  Using this now involves adding in the Accelerate.framework.
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//  Some parts Copyright (C) 2013 Apple Inc. All Rights Reserved.  WWDC 2013 License
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SDImageCompositionOptions)
{
    SDImageCompositeOptionsPinOverlayToTop      = 1 << 0,
    SDImageCompositeOptionsPinOverlayToBottom   = 1 << 1,
    SDImageCompositeOptionsPinOverlayToLeft     = 1 << 2,
    SDImageCompositeOptionsPinOverlayToRight    = 1 << 3,
    SDImageCompositeOptionsCenterXOverlay       = 1 << 4,
    SDImageCompositeOptionsCenterYOverlay       = 1 << 5,

    SDImageCompositeOptionsPinSourceToTop       = 1 << 6,
    SDImageCompositeOptionsPinSourceToBottom    = 1 << 7
};

@interface UIImage (SDExtensions)

/**
 Returns a UIImage rendering of the passed in view.
 */
+ (UIImage *)imageFromView:(UIView *)view;
- (UIImage *)nonJaggyImage;

/**
 Returns a UIColor approximating the averaged color of an image.
 */
- (UIColor *)averageColor;

/**
 Returns a UIImage filled with the supplied color of the request size.
 */
+ (UIImage *)filledImageWithFrame:(CGSize)size andColor:(UIColor *)color;

/**
 Composite a supplied image on top of the image this is being called at.
 You also tell it where to draw inside of the rect of the image you are overlaying.
 */
- (UIImage *)compositeWith:(UIImage *)overlayImage toPoint:(CGPoint)overlayPoint;

/**
 Given an image, composite them together to form a third image.
 The resulting image will be as big as the biggest dimension of either of the images.
 Given the options, you can choose to make the source's Y position be at the top or bottom of resulting image,
 and the overlay at the top, bottom, right, left, or centerX, or centerY.
 */
+ (UIImage *)stretchImage:(UIImage *)image toSize:(CGSize)size andOverlayImage:(UIImage *)overlayImage withOptions:(SDImageCompositionOptions)options;

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

/**
 Given a black image with an alpha mask, produces a color version of the image
 @param UIColor color - The desired color of the image
 @return A colorized version of the image
 */
- (UIImage *)maskedImageWithColor:(UIColor *)color;

/**
 Saves the UIImage to disk and returns a GUID to refer to it later on.
 @return NSString* - The GUID string the image is saved under
 */
- (NSString *)saveImageToDisk;

/**
 Retrieves an image with a GUID. May return nil if the image is not found.
 @param NSString *guid - The GUID the image is saved under and can be retrieved from.
 @return UIImage* - The image found under the given GUID. nil is returned if not found.
 */
+ (UIImage *)loadImageFromGUID:(NSString *)guid;

@end
