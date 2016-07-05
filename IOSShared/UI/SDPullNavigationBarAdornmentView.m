//
//  SDPullNavigationBarAdornmentView.m
//  ios-shared
//
//  Created by Steven Woolgar on 03/01/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBarAdornmentView.h"

static const CGFloat kMinimumHeightForTapArea = 44.0f;

@interface SDPullNavigationBarAdornmentView()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView* adornmentView;
@property (nonatomic, assign) CGFloat adornmentViewHeight;  // This accounts for both imageSize and gap to make it more grabbable.
@end

@implementation SDPullNavigationBarAdornmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        _baseFrame = frame;

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.opaque = YES;

        _containerView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, frame.size }];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _containerView.tag = 1;
        [self addSubview:_containerView];
    }

    return self;
}

- (void)setAdornmentImage:(UIImage*)adornmentImage
{
    if(_adornmentImage != adornmentImage)
    {
        _adornmentImage = adornmentImage;

        [self.adornmentView removeFromSuperview];
        self.adornmentView = nil;

        self.adornmentViewHeight = 0.0f;

        if(adornmentImage)
        {
            CGSize imageSize = self.adornmentImage.size;
            self.adornmentViewHeight = MAX(imageSize.height, kMinimumHeightForTapArea);

            self.adornmentView = [[UIImageView alloc] initWithFrame:[self adornmentViewFrame]];
            self.adornmentView.backgroundColor = [UIColor clearColor];
            self.adornmentView.opaque = YES;
            self.adornmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            self.adornmentView.image = self.adornmentImage;
            self.adornmentView.tag = 2;
            [self addSubview:self.adornmentView];
        }

        [self setFrame:(CGRect){ self.baseFrame.origin, { self.baseFrame.size.width, self.baseFrame.size.height + self.adornmentViewHeight } }];

        // Adding or removing an adornment image means laying our the view again.

        [self setNeedsLayout];
    }
}

- (void)setBaseFrame:(CGRect)baseFrame
{
    if(!CGRectEqualToRect(baseFrame, _baseFrame))
    {
        _baseFrame = baseFrame;
        [self setFrame:(CGRect){ _baseFrame.origin, { _baseFrame.size.width, _baseFrame.size.height + self.adornmentViewHeight } }];
        [self setNeedsLayout];
    }
}

- (void)setBackgroundViewClass:(Class)backgroundViewClass
{
    if(backgroundViewClass != _backgroundViewClass)
    {
        _backgroundViewClass = backgroundViewClass;
        
        UIView *oldView = self.backgroundView;
        [oldView removeFromSuperview];
        self.backgroundView = nil;
        
        if(backgroundViewClass != nil)
        {
            self.backgroundView = [[_backgroundViewClass alloc] initWithFrame:[self backgroundViewFrame]];
            self.backgroundView.backgroundColor = [UIColor clearColor];
            self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            self.backgroundView.tag = 3;
            [self insertSubview:self.backgroundView atIndex:0];
        }
    }
}

- (void)layoutSubviews
{
    // Adjust the views that we have. If we have an image, it means we created the image view that contains it.

    if(self.adornmentImage)
    {
        self.adornmentView.frame = [self adornmentViewFrame];
    }
    if(self.backgroundView)
    {
        self.backgroundView.frame = [self backgroundViewFrame];
    }
    self.containerView.frame = (CGRect){ CGPointZero, self.baseFrame.size };
}

- (CGRect)backgroundViewFrame
{
    CGRect containerFrame = (CGRect){ CGPointZero, self.baseFrame.size };
    containerFrame.size.height += self.adornmentImage.size.height;
    return containerFrame;
}

- (CGRect)adornmentViewFrame
{
    CGSize imageSize = self.adornmentImage.size;
    CGRect imageViewRect = self.baseFrame;
    imageViewRect.origin.x = floor(CGRectGetWidth(imageViewRect) * 0.5f - imageSize.width * 0.5f);
    imageViewRect.origin.y = self.baseFrame.size.height;
    imageViewRect.size = imageSize;
    return imageViewRect;
}

- (void) pullNavigationMenuWillAppear
{
    id<SDPullNavigationBackgroundView> backgroundView = [self backgroundViewProtocol];
    if([backgroundView respondsToSelector:@selector(pullNavigationMenuWillAppear)])
    {
        [backgroundView pullNavigationMenuWillAppear];
    }
}

- (void) pullNavigationMenuDidDisappear
{
    id<SDPullNavigationBackgroundView> backgroundView = [self backgroundViewProtocol];
    if([backgroundView respondsToSelector:@selector(pullNavigationMenuDidDisappear)])
    {
        [backgroundView pullNavigationMenuDidDisappear];
    }
}

- (id<SDPullNavigationBackgroundView>) backgroundViewProtocol
{
    id<SDPullNavigationBackgroundView> backgroundView = nil;
    
    if (self.backgroundView && _backgroundViewClass && [_backgroundViewClass conformsToProtocol:@protocol(SDPullNavigationBackgroundView)])
    {
        backgroundView = (id<SDPullNavigationBackgroundView>)self.backgroundView;
    }
    
    return backgroundView;
}

@end
