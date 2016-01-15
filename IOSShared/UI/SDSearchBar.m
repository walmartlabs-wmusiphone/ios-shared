//
//  SDSearchBar.m
//  SetDirection
//
//  Created by brandon on 2/23/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDSearchBar.h"


@implementation SDSearchBar

@synthesize controller;
@synthesize active = isActive;


- (UIView *)obscuringView
{
	if (!obscuringView && controller)
	{
		CGRect rect = controller.view.frame;
		
		obscuringView = [[UIView alloc] initWithFrame:rect];
		obscuringView.backgroundColor = [UIColor blackColor];
		obscuringView.opaque = NO;
		obscuringView.alpha = 0;
		obscuringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	
	return obscuringView;
}

- (void)setActive:(BOOL)active
{
	[self setActive:active animated:YES];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated;
{
	if (!isActive)
	{
		[controller.view addSubview:self.obscuringView];
		[controller.view bringSubviewToFront:self];
		[UIView animateWithDuration:0.2 animations:^{
			self.obscuringView.alpha = 0.75;
		}];
		[controller.navigationController setNavigationBarHidden:YES animated:animated];
		[self setShowsCancelButton:YES animated:animated];
		isActive = YES;
	}
	else
	{
		[controller.view addSubview:self.obscuringView];
		[UIView animateWithDuration:0.2 
						 animations:^{
							 self.obscuringView.alpha = 0;
						 }
						 completion:^(BOOL finished){
							 //if (finished)
							 //	 [self.obscuringView removeFromSuperview];
						 }];
		[controller.navigationController setNavigationBarHidden:NO animated:animated];
		[self setShowsCancelButton:NO animated:animated];
		[self resignFirstResponder];
		isActive = NO;
	}
}

@end
