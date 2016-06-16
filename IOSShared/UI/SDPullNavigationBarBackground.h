//
//  SDPullNavigationBarBackground.h
//  ios-shared

//
//  Created by Brandon Sneed on 11/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDPullNavigationBarOverlayProtocol <NSObject>
- (void)drawOverlayRect:(CGRect)rect;
- (void)tapAction:(id)sender;
@end

@interface SDPullNavigationBarBackground : UIView
@property (nonatomic, weak) id<SDPullNavigationBarOverlayProtocol> delegate;
@end
