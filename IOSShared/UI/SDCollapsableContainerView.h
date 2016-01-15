//
//  SDCollapsableContainerView.h
//  Autolayout Examples
//
//  Created by Steven W. Riggins on 4/28/14.
//  Copyright (c) 2014 Steve Riggins. All rights reserved.
//
//  Contains one view and one view only. Allows for quick collapsing

#import <UIKit/UIKit.h>

@interface SDCollapsableContainerView : UIView
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) BOOL collapsed;
@end
