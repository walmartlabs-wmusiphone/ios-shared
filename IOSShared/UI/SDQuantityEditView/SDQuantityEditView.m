//
//  SDQuantityEditView.m
//
//  Created by ricky cancro on 1/7/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDQuantityEditView.h"
#import "SDQuantityView.h"
#import "SDMacros.h"

@interface SDQuantityEditView()
@property (nonatomic, strong) NSLayoutConstraint *editTotalSpaceToTopContraint;
@property (nonatomic, strong) SDQuantityEditViewBehavior *quantityBehavior;
@property (nonatomic, assign) BOOL createdConstraints;

@property (nonatomic, strong, readwrite) UIImageView *dropShadowImageView;
@property (nonatomic, strong, readwrite) UIImageView *backgroundImageView;
@property (nonatomic, strong, readwrite) UILabel *totalPriceLabel;
@property (nonatomic, strong, readwrite) UILabel *weightLabel;
@property (nonatomic, strong, readwrite) SDQuantityView *quantityView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activitingIndicator;
@end

@implementation SDQuantityEditView

+ (instancetype)quantityEditView
{
    SDQuantityEditView *editView = [[[self class] alloc] initWithFrame:CGRectZero];
    return editView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // If a user is loading from a nib ignore the stock constraints and use what they provided
    self.createdConstraints = YES;
    
    _activitingIndicator.hidesWhenStopped = YES;
    [_activitingIndicator stopAnimating];
    
    // quantityView is readonly, so create one here so the user has access to it in awakeFromNib
    _quantityView = [SDQuantityView quantityView];
    _quantityView.translatesAutoresizingMaskIntoConstraints = NO;
    _quantityView.fillColor = [UIColor lightGrayColor];
    _quantityView.quantityLabel.textColor = [UIColor darkTextColor];

    [_doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_removeButton addTarget:self action:@selector(removeTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createDoneAndRemoveButtons
{
    _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
}

- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self createDoneAndRemoveButtons];
    _activitingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    _dropShadowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _dropShadowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _dropShadowImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_dropShadowImageView];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backgroundImageView];
    
    // if the user hasn't provided a title for the buttons, add a default one now
    if ([_removeButton titleForState:UIControlStateNormal] == nil)
    {
        [_removeButton setTitle:NSLocalizedString(@"Remove", @"Remove Button Title") forState:UIControlStateNormal];
    }
    _removeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_removeButton];
    
    if ([_doneButton titleForState:UIControlStateNormal] == nil)
    {
        [_doneButton setTitle:NSLocalizedString(@"Done", @"Done Button Title") forState:UIControlStateNormal];
    }
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_doneButton];
    
    _activitingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_activitingIndicator];
    
    _totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _totalPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_totalPriceLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    _totalPriceLabel.minimumScaleFactor = .65;
    _totalPriceLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_totalPriceLabel];
    
    _weightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _weightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_weightLabel setFont:[UIFont systemFontOfSize:12.0f]];
    _weightLabel.minimumScaleFactor = .65;
    _weightLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_weightLabel];
    
    _quantityView = [SDQuantityView quantityView];
    _quantityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_quantityView];
    _quantityView.fillColor = [UIColor lightGrayColor];
    _quantityView.quantityLabel.textColor = [UIColor darkTextColor];
    
    _removeButton.alpha = 0.0f;
    _activitingIndicator.hidesWhenStopped = YES;
    [_activitingIndicator stopAnimating];
    
    [_doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_removeButton addTarget:self action:@selector(removeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)updateConstraints
{
    if (!self.createdConstraints)
    {
        self.createdConstraints = YES;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView":self.dropShadowImageView}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:@{@"backgroundView":self.backgroundImageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(22)][backgroundView(68)]|" options:0 metrics:nil views:@{@"imageView":self.dropShadowImageView, @"backgroundView":self.backgroundImageView}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(43)-[quantityView]" options:0 metrics:nil views:@{@"quantityView":self.quantityView}]];
        
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(6)-[totalLabel]-(10)-[quantityView(>=90)]-(8)-[removeButton]-(6)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"totalLabel":self.totalPriceLabel, @"quantityView":self.quantityView, @"removeButton":self.removeButton}]];
        // This is required for iOS 7 & 7.1 when building for iOS 8.
        [[self totalPriceLabel] setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[quantityView]-(20)-[doneButton]-(21)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"quantityView":self.quantityView, @"doneButton":self.doneButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[spinner]-(38)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"spinner":self.activitingIndicator}]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[weightLabel]-(10)-[quantityView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"weightLabel":self.weightLabel, @"quantityView":self.quantityView}]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[removeButton]-(17)-|" options:0 metrics:nil views:@{@"removeButton":self.removeButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[doneButton]-(17)-|" options:0 metrics:nil views:@{@"doneButton":self.doneButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[spinner]-(22)-|" options:0 metrics:nil views:@{@"spinner":self.activitingIndicator}]];
        
        NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(48)-[totalLabel]" options:0 metrics:nil views:@{@"totalLabel":self.totalPriceLabel}];
        self.editTotalSpaceToTopContraint = [topConstraints objectAtIndex:0];
        [self addConstraint:self.editTotalSpaceToTopContraint];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[totalPrice]-(-3)-[weight]" options:0 metrics:nil views:@{@"totalPrice":self.totalPriceLabel, @"weight":self.weightLabel}]];
    }
    [super updateConstraints];
}

- (void)updateDoneRemoveButtons:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
    }
    
    if (self.quantityBehavior.updatedQuantity)
    {
        if ([self.quantityBehavior.updatedQuantity doubleValue] > 0)
        {
            self.doneButton.alpha = 1.0f;
            self.removeButton.alpha = 0.0f;
        }
        else if ([self.quantityBehavior.updatedQuantity doubleValue] == 0)
        {
            self.doneButton.alpha = 0.0f;
            self.removeButton.alpha = 1.0f;
        }
    }
    else
    {
        self.doneButton.alpha = 1.0f;
        self.removeButton.alpha = 0.0f;
    }
    
    if (animated)
    {
        [UIView commitAnimations];
    }
}

- (SDQuantityEditViewBehavior *)defaultQuantityBehavior
{
    return [[SDQuantityEditViewBehavior alloc] initWithAdjustableItem:self.adjustableItem delegate:self];
}


- (void)setAdjustableItem:(id<SDAdjustableItem>)adjustableItem
{
    _adjustableItem = adjustableItem;
    [self adjustableItemChanged];
}

- (void)adjustableItemChanged
{
    self.quantityBehavior = [self defaultQuantityBehavior];
    
    @weakify(self);
    self.quantityBehavior.didChangeQuantity = ^(BOOL increment) {
        @strongify(self);
        [self updateDoneRemoveButtons:YES];
    };
    
    [self updateDoneRemoveButtons:NO];
    
    switch ([_adjustableItem adjustQuantityMethod])
    {
        case kAdjustableItemQuantityMethod_Counted:
        case kAdjustableItemQuantityMethod_Weighted:
            self.editTotalSpaceToTopContraint.constant = 48.0f;
            break;
            
        case kAdjustableItemQuantityMethod_Both:
            self.editTotalSpaceToTopContraint.constant = 42.0f;
            break;
            
    }
}

- (void)setCommitting:(BOOL)committing
{
    if (committing != _committing)
    {
        _committing = committing;
        [self updateUIForCommittingState];
    }
}

- (void)updateUIForCommittingState
{
    if (self.committing)
    {
        self.doneButton.alpha = 0.0f;
        self.removeButton.alpha = 0.0f;
        [self.activitingIndicator startAnimating];
        self.quantityView.alpha = 0.4f;
        
        self.quantityView.userInteractionEnabled = NO;
        self.totalPriceLabel.alpha = 0.4f;
        self.weightLabel.alpha = 0.4;
    }
    else
    {
        [self.activitingIndicator stopAnimating];
        
        self.quantityView.alpha = 1.0f;
        self.quantityView.userInteractionEnabled = YES;
        self.totalPriceLabel.alpha = 1.0f;
        self.weightLabel.alpha = 1.0;
        [self updateDoneRemoveButtons:YES];
    }
}

- (void)removeTapped:(id)sender
{
    [self setCommitting:YES];
    if (self.removeTappedBlock)
    {
        self.removeTappedBlock(self.quantityBehavior.originalQuantity);
    }
}

- (void)doneTapped:(id)sender
{
    [self setCommitting:YES];
    if (self.doneTappedBlock)
    {
        self.doneTappedBlock(self.quantityBehavior.originalQuantity, self.quantityBehavior.updatedQuantity);
    }
}

#pragma mark - SDQuantityEditViewProtocol

- (UIButton *)plusButton
{
    return self.quantityView.incrementButton;
}

- (UIButton *)minusButton
{
    return self.quantityView.decrementButton;
}

- (UILabel *)quantityLabel
{
    return self.quantityView.quantityLabel;
}

- (UILabel *)totalWeightLabel
{
    UILabel *weightLabel = nil;
    switch (self.adjustableItem.adjustQuantityMethod)
    {
        case kAdjustableItemQuantityMethod_Weighted:
            weightLabel = self.quantityView.quantityLabel;
            break;
            
        case kAdjustableItemQuantityMethod_Both:
            weightLabel = self.weightLabel;
            break;
            
        case kAdjustableItemQuantityMethod_Counted:
            NSAssert(0, @"Counted method should not have a weight label.");
            break;
    }
    return weightLabel;
}


@end
