//
// Created by Steve Riggins on 4/9/14.
// Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDPaddedLabel.h"

@interface SDPaddedLabel ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation SDPaddedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self p_addLabel];
    }

    return self;
}

- (void)p_addLabel
{
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.backgroundColor = [UIColor clearColor]; // Thanks, iOS 6!
    [self addSubview:self.label];

    [self p_applyContraints];
}

- (void)p_applyContraints
{
    [self removeConstraints:self.constraints];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:self.edgeInsets.top]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-self.edgeInsets.bottom]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:self.edgeInsets.left]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:-self.edgeInsets.right]];

    [self setNeedsUpdateConstraints];
}

- (CGSize)intrinsicContentSize
{
    CGSize ics = self.label.intrinsicContentSize;
    ics.height += self.edgeInsets.top + self.edgeInsets.bottom;
    ics.width += self.edgeInsets.left + self.edgeInsets.right;
    return ics;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    [self p_applyContraints];
}

@end