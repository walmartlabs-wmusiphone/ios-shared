//
//  UIImage+SDExtensions.m
//  SetDirection
//
//  Using this now involves adding in the Accelerate.framework.
//
//  Created by Brandon Sneed on 10/5/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//  Some parts Copyright (C) 2013 Apple Inc. All Rights Reserved.  WWDC 2013 License
//

#import "UIImage+SDExtensions.h"
#import <QuartzCore/QuartzCore.h>

#import <Accelerate/Accelerate.h>
#import <float.h>
#include <tgmath.h>

#import "SDLog.h"
#import "NSString+SDExtensions.h"

@implementation UIImage (SDExtensions)

+ (UIImage *)imageFromView:(UIView *)view
{
    UIImage *result = nil;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    for (CALayer *layer in view.layer.sublayers)
    {
        [layer renderInContext:ctx];
    }
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)nonJaggyImage
{
    // mostly copied from Joel Bernstein's NonJaggyWebImageView...
    CGFloat contentScaleFactor = [[UIScreen mainScreen] scale];
    CGSize newSize = CGSizeMake(self.size.width * self.scale + contentScaleFactor * 2, self.size.height * self.scale + contentScaleFactor * 2);

    UIGraphicsBeginImageContext(newSize);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, newSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(contentScaleFactor, contentScaleFactor, self.size.width * self.scale, self.size.height * self.scale), self.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);

    UIGraphicsEndImageContext();

    UIImage *retImage = [UIImage imageWithCGImage:newImageRef scale:contentScaleFactor orientation:self.imageOrientation];
	CGImageRelease(newImageRef);

    return retImage;
}

- (UIColor *)averageColor
{
    CGSize size = CGSizeMake( 1.0f, 1.0f );
    
    UIGraphicsBeginImageContext( size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality( context, kCGInterpolationMedium );
    
    [self drawInRect: CGRectMake( 0.0f, 0.0f, size.width, size.height )
           blendMode: kCGBlendModeCopy
               alpha: 1.0f];
    
    uint8_t* data = CGBitmapContextGetData( context );
    UIColor* color = [UIColor colorWithRed: data[2] / 255.0f
                                     green: data[1] / 255.0f
                                      blue: data[0] / 255.0f
                                     alpha: 1.0f];
    UIGraphicsEndImageContext();
    
    return color;
}

+ (UIImage *)filledImageWithFrame:(CGSize)size andColor:(UIColor *)color
{
    UIImage *compositedImage = nil;

    UIGraphicsBeginImageContextWithOptions( size, NO, [[UIScreen mainScreen] scale] );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRetain( context );
    {
        [color set];
        UIRectFill((CGRect){ CGPointZero, size });

        compositedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    CGContextRelease( context );
    UIGraphicsEndImageContext();

    return compositedImage;
}

- (UIImage *)compositeWith:(UIImage *)overlayImage toPoint:(CGPoint)overlayPoint
{
    UIImage *compositedImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRetain( context );
    {
        [self drawAtPoint:CGPointZero];
        [overlayImage drawAtPoint:overlayPoint];

        compositedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    CGContextRelease( context );
    UIGraphicsEndImageContext();

    return compositedImage;
}

- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        SDLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        SDLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        SDLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)round(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

/**
 Given an image and the size to stretch it to and an image to overlay on top of it, composite them together to form a third image.
 The resulting image will be as big as the biggest dimension of either of the images.
 Given the options, you can choose to make the source's Y position be at the top or bottom of resulting image,
 and the overlay at the top, bottom, right, left, or centerX, or centerY.
 */

+ (UIImage *)stretchImage:(UIImage *)image toSize:(CGSize)size andOverlayImage:(UIImage *)overlayImage withOptions:(SDImageCompositionOptions)options
{
    NSAssert(image, @"Provide a base image");
    NSAssert(overlayImage, @"Provide an overlay image");

    NSAssert(!(options & SDImageCompositeOptionsPinSourceToTop   && options & SDImageCompositeOptionsPinSourceToBottom), @"Either pin to top or bottom, not both");
    NSAssert(!(options & SDImageCompositeOptionsPinOverlayToTop  && options & SDImageCompositeOptionsPinOverlayToBottom), @"Either pin to top or bottom, not both");
    NSAssert(!(options & SDImageCompositeOptionsPinOverlayToLeft && options & SDImageCompositeOptionsPinOverlayToRight), @"Either pin to left or right, not both");
    NSAssert(!(options & SDImageCompositeOptionsCenterXOverlay   && options & SDImageCompositeOptionsPinOverlayToLeft), @"Either pin to left or centerX, not both");
    NSAssert(!(options & SDImageCompositeOptionsCenterXOverlay   && options & SDImageCompositeOptionsPinOverlayToRight), @"Either pin to right or centerX, not both");
    NSAssert(!(options & SDImageCompositeOptionsCenterYOverlay   && options & SDImageCompositeOptionsPinOverlayToTop), @"Either pin to top or centerY, not both");
    NSAssert(!(options & SDImageCompositeOptionsCenterYOverlay   && options & SDImageCompositeOptionsPinOverlayToBottom), @"Either pin to bottom or centerY, not both");

    CGSize destinationSize = (CGSize){ floor(MAX(size.width, overlayImage.size.width)),
                                       floor(MAX(size.height, overlayImage.size.height)) };

    // Given the options, calculate where we position the source.

    CGPoint sourcePoint = CGPointZero;
    if(options & SDImageCompositeOptionsPinSourceToBottom)
        sourcePoint = (CGPoint){ sourcePoint.x, destinationSize.height - image.size.height };

    // Given the options, calculate where we position the overlay.

    CGPoint overlayPoint = CGPointZero;
    if(options & SDImageCompositeOptionsPinOverlayToBottom)
        overlayPoint = (CGPoint){ overlayPoint.x, floor(destinationSize.height - overlayImage.size.height) };
    if(options & SDImageCompositeOptionsPinOverlayToLeft)
        overlayPoint = (CGPoint){ 0.0f, overlayPoint.y };
    if(options & SDImageCompositeOptionsCenterYOverlay)
        overlayPoint = (CGPoint){ overlayPoint.x, floor((destinationSize.height * 0.5f) - (overlayImage.size.height * 0.5f)) };
    if(options & SDImageCompositeOptionsPinOverlayToRight)
        overlayPoint = (CGPoint){ destinationSize.width - overlayImage.size.width, overlayPoint.y };
    if(options & SDImageCompositeOptionsCenterXOverlay)
        overlayPoint = (CGPoint){ floor((destinationSize.width * 0.5f) - (overlayImage.size.width * 0.5f)), overlayPoint.y };

    // Now composite them together.

    UIImage *compositedImage = nil;

    UIGraphicsBeginImageContextWithOptions(destinationSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRetain( context );
    {
        [image drawInRect:(CGRect){ sourcePoint, size }];
        [overlayImage drawAtPoint:overlayPoint];

        compositedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    CGContextRelease( context );
    UIGraphicsEndImageContext();

    return compositedImage;
}

- (UIImage *)maskedImageWithColor:(UIColor *)color
{
    UIImage *image = self;
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (NSString *)saveImageToDisk
{
    NSString *guid = [NSString stringWithNewUUID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = UIImageJPEGRepresentation(self, 1.0);
        if (data)
        {
            NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
            [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
        }
    });
    
    return guid;
}

+ (UIImage *)loadImageFromGUID:(NSString *)guid
{
    UIImage *imageReturned = nil;
    if (guid)
    {
        NSString *imagePath = [NSTemporaryDirectory() stringByAppendingString:guid];
        imageReturned = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    
    return imageReturned;
}

@end
