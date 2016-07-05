//
//  SDPhotoImageView.m
//  Photos
//
//  Created by Brandon Sneed on 5/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDPhotoImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "SDMacros.h"

@implementation SDPhotoImageView
{
    UIScrollView *_scrollView;
    
    UITapGestureRecognizer *_doubleTapGesture;
    UITapGestureRecognizer *_singleTapGesture;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
		
    self.backgroundColor = [UIColor blackColor];
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userInteractionEnabled = YES;
    self.opaque = YES;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.bouncesZoom = YES;
    _scrollView.clipsToBounds = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.maximumZoomScale = 3.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.zoomScale = 1.0;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.opaque = YES;
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scrollView addSubview:_imageView];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [_doubleTapGesture setNumberOfTapsRequired:2];
    
    // make sure we can touble tap w/o triggering the single tap action
    [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
    
    [_imageView addGestureRecognizer:_singleTapGesture];
    [_imageView addGestureRecognizer:_doubleTapGesture];

    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _scrollView.zoomScale = 1.0;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    @strongify(self.delegate, strongDelegate);
    if ([strongDelegate respondsToSelector:@selector(photoImageView:wasTappedAtPoint:)])
        [strongDelegate photoImageView:self wasTappedAtPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat newScale = 1.0;
    if (_scrollView.zoomScale == 1.0)
        newScale = _scrollView.maximumZoomScale;
    
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_scrollView frame].size.height / scale;
    zoomRect.size.width  = [_scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


@end
