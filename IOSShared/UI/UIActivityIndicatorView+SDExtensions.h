//
//  UIActivityIndicatorView+SDExtensions.h
//  SetDirection
//
//  Created by Brandon Sneed on 8/18/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (SDExtensions)

/**
 Display an animating activity indicator view that fades into view. The fade-in animation lasts `0.1` seconds.
 */
- (void)show;

/**
 Hide an animating activity indicator view that fades out of view. The fade-out animation lasts `0.1` seconds.
 */
- (void)hide;

@end
