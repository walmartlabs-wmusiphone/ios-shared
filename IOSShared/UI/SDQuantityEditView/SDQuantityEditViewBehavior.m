//
//  SDQuantityEditViewBehavior.m
//
//  Created by Robb Albright on 17.4.12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDQuantityEditViewBehavior.h"
#import "SDMacros.h"
#import "SDLog.h"

@implementation NSDecimalNumber (CurrencyExtension)

+(NSDecimalNumber*)decimalNumberWithCurrencyString:(NSString *)currencyString
{
    NSString *numeralsOnlyString = [currencyString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$£ "]];
    numeralsOnlyString = [numeralsOnlyString stringByReplacingOccurrencesOfString: @"," withString:@""]; //Localize note: assumes full-stop for decimal separator
    NSDecimalNumber *outNumber = [NSDecimalNumber decimalNumberWithString:numeralsOnlyString];
    return outNumber;
}

@end

static char kObserveQuantityContext;

@interface SDQuantityEditViewBehavior ()

@property (nonatomic, strong, readwrite) NSDecimalNumber *updatedQuantity; // nil if not different
@property (nonatomic, strong, readwrite) NSDecimalNumber *currentQuantity;

@property (nonatomic, strong) NSDecimalNumber *stepAmount;
@property (nonatomic, strong) NSDecimalNumber *maxQuantity;
@property (nonatomic, strong) NSDecimalNumber *pricePerUnit;
@property (nonatomic, strong) NSDecimalNumberHandler* roundingBehavior;
@property (nonatomic, assign) SDProductQuantityMethod adjustQuantityMethod;
@property (nonatomic, weak) UIView<SDQuantityEditViewProtocol> *quantityViewDelegate;
@property (nonatomic, strong) NSDecimalNumber *avgWeight;

@end

@implementation SDQuantityEditViewBehavior

- (id)initWithAdjustableItem:(id<SDAdjustableItem>)adjustableItem delegate:(UIView<SDQuantityEditViewProtocol> *)delegate;
{
    self = [super init];
    if (self)
    {
        
        _quantityViewDelegate = delegate;
        @strongify(_quantityViewDelegate, viewDelegate);
        
        _adjustQuantityMethod = [adjustableItem adjustQuantityMethod];
        [viewDelegate.plusButton addTarget:self action:@selector(incrementAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewDelegate.minusButton addTarget:self action:@selector(decrementAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (_adjustQuantityMethod == kAdjustableItemQuantityMethod_Weighted) {
            _weightSuffix = @"kg";
            _stepAmount = [NSDecimalNumber decimalNumberWithString:@"0.1"];
        }
        else {
            _weightSuffix = @"";
            _stepAmount = [NSDecimalNumber decimalNumberWithString:@"1"];
        }
        
        // We always start with one step unit if the product is not already in the trolley
        if ([adjustableItem respondsToSelector:@selector(quantity)] && [adjustableItem quantity]) {
            _originalQuantity = _currentQuantity = [NSDecimalNumber decimalNumberWithString:[adjustableItem quantity]];
        }
        else {
            _originalQuantity = [NSDecimalNumber decimalNumberWithString:@"0"];
            _currentQuantity = [_originalQuantity decimalNumberByAdding:_stepAmount];
        }
        
        if ([adjustableItem maxQuantity]) {
            _maxQuantity = [NSDecimalNumber decimalNumberWithString:[adjustableItem maxQuantity]];
        }
        else {
            _maxQuantity = [NSDecimalNumber decimalNumberWithString:@"24"]; // 24 is the usual max quantity
        }
        
        if ([adjustableItem pricePerUnitOfMeasure]) {
            _pricePerUnit = [NSDecimalNumber decimalNumberWithCurrencyString:[adjustableItem pricePerUnitOfMeasure]];
        }
        else {
            SDLog(@"NO price per unit given!");
            viewDelegate.totalPriceLabel.hidden = YES;
        }
        
        if(_adjustQuantityMethod == kAdjustableItemQuantityMethod_Both && [adjustableItem respondsToSelector:@selector(averageWeight)])
        {
            // This is a workaround for bad data. This method would otherwise crash the app when averageWeight is not set.
            // Use an arbitrary value for avgWeight. I've chosen 1.
            NSDecimalNumber *avg = [NSDecimalNumber decimalNumberWithCurrencyString:[adjustableItem averageWeight]];
            _avgWeight = ![avg isEqualToNumber:[NSDecimalNumber notANumber]] ? avg : [NSDecimalNumber one];
            _maxQuantity = [_maxQuantity decimalNumberByDividingBy:_avgWeight];
            _pricePerUnit = [_pricePerUnit decimalNumberByMultiplyingBy:_avgWeight];
        }
        
        _roundingBehavior =  [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        // set up the default price formatter here.  If the user set this property then the total
        // we be recalculated using the new price formatter.
        NSNumberFormatter *defaultFormatter = [[NSNumberFormatter alloc] init];
        [defaultFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [defaultFormatter setCurrencySymbol:@"£"];
        [defaultFormatter setCurrencyGroupingSeparator:@","];
        [defaultFormatter setGroupingSize:3];
        [defaultFormatter setCurrencyDecimalSeparator:@"."];
        [defaultFormatter setGeneratesDecimalNumbers:YES];
        _priceFormatter = defaultFormatter;
        
        [self updateTotalWeightAndCost];
        [self updateQuantityLabel];
        [self updateButtonState];
        
        // observe our quantity to update the displayed quantity and expanded price
        [self addObserver:self forKeyPath:@"currentQuantity" options:NSKeyValueObservingOptionNew context:&kObserveQuantityContext];
        [self updateTotalWeightAndCost];
    }
    return self;
}

-(void)dealloc
{
    @strongify(_quantityViewDelegate, viewDelegate);
    [self removeObserver:self forKeyPath:@"currentQuantity"];
    self.roundingBehavior = nil;
    [viewDelegate.plusButton removeTarget:self action:@selector(incrementAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewDelegate.minusButton removeTarget:self action:@selector(decrementAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)displayWeightLabelTextWithValue:(NSDecimalNumber *)value
{
    NSMutableString *weightLabelText = [NSMutableString stringWithString:value.stringValue];
    if ([self.weightSuffix length])
    {
        [weightLabelText appendFormat:@"%@", self.weightSuffix];
    }
    if ([self.quantitySuffix length])
    {
        [weightLabelText appendFormat:@" %@", self.quantitySuffix];
    }
    return weightLabelText;
}

- (void)setQuantitySuffix:(NSString *)quantitySuffix
{
    if (![_quantitySuffix isEqualToString:quantitySuffix])
    {
        _quantitySuffix = [quantitySuffix copy];
        _quantityViewDelegate.quantityLabel.text = [self displayWeightLabelTextWithValue:self.currentQuantity];
    }
}

- (void)setWeightSuffix:(NSString *)weightSuffix
{
    if (![_weightSuffix isEqualToString:weightSuffix])
    {
        _weightSuffix = [weightSuffix copy];
        _quantityViewDelegate.quantityLabel.text = [self displayWeightLabelTextWithValue:self.currentQuantity];
    }
}

-(void)setOriginalQuantity:(NSDecimalNumber *)newOriginalQuantity
{
    @strongify(_quantityViewDelegate, viewDelegate);
    _originalQuantity = newOriginalQuantity;
    viewDelegate.quantityLabel.text = [self displayWeightLabelTextWithValue:_originalQuantity];
}

-(void)updateQuantityLabel
{
    @strongify(_quantityViewDelegate, viewDelegate);
    viewDelegate.quantityLabel.text = [self displayWeightLabelTextWithValue:self.currentQuantity];
}


- (void)updateButtonState
{
    @strongify(_quantityViewDelegate, viewDelegate);
    // plus only on if quantity is less than max
    NSComparisonResult maxResult;
    if (self.adjustQuantityMethod == kAdjustableItemQuantityMethod_Both) {
        maxResult = [self.maxQuantity compare:[self.currentQuantity decimalNumberByAdding:self.stepAmount]];
    } else {
        maxResult = [self.maxQuantity compare:self.currentQuantity];
    }
    viewDelegate.plusButton.enabled = ( maxResult == NSOrderedDescending);

    // if originalQuantity is zero, that means we are adding a new item
    // if so, it does not make sense to allow stepper to be lower than one
    // "Add zero items" is a useless concept
    NSDecimalNumber *minimumQuantity = [self.originalQuantity isEqual:[NSDecimalNumber zero]] && viewDelegate.limitMinimumQuantityOnNewItemsToStepAmount ? self.stepAmount : [NSDecimalNumber zero];
    // minus on only if quantity is more than the min
    NSComparisonResult minResult = [minimumQuantity compare:self.currentQuantity];
    viewDelegate.minusButton.enabled = ( minResult == NSOrderedAscending);
}

-(IBAction)incrementAction:(id)sender
{
    if (self.willChangeQuantity)
    {
        self.willChangeQuantity(YES);
    }
    
    self.currentQuantity = [self.currentQuantity decimalNumberByAdding:self.stepAmount];
    // When server adjusts quantity based on average, the step can be 2 decimal places, round it to 1
    self.currentQuantity = [self.currentQuantity decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
    [self updateButtonState];
    [self updateTotalWeightAndCost];
    [self updateQuantityLabel];
    
    if (self.didChangeQuantity)
    {
        self.didChangeQuantity(YES);
    }
}


-(IBAction)decrementAction:(id)sender
{
    if (self.willChangeQuantity)
    {
        self.willChangeQuantity(NO);
    }
    
    self.currentQuantity = [self.currentQuantity decimalNumberBySubtracting:self.stepAmount];
    // When server adjusts quantity based on average, the step can be 2 decimal places, round it to 1
    self.currentQuantity = [self.currentQuantity decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
    // and could go below zero
    if ([self.currentQuantity compare:[NSDecimalNumber zero]] == NSOrderedAscending ) {
        self.currentQuantity = [NSDecimalNumber zero];
    }
    [self updateButtonState];
    [self updateTotalWeightAndCost];
    [self updateQuantityLabel];
    
    if (self.didChangeQuantity)
    {
        self.didChangeQuantity(NO);
    }
}

- (void)setPriceFormatter:(NSNumberFormatter *)priceFormatter
{
    // if the user updates the priceformatter run updateTotalCost to get the newly formatted total cost
    if (priceFormatter != _priceFormatter)
    {
        _priceFormatter = priceFormatter;
        [self updateTotalWeightAndCost];
    }
}

- (NSString *) totalCostString
{
    NSString *totalCostString = nil;
    
    if (self.pricePerUnit && self.currentQuantity) {
        // We may have empty(NaN) ppu, so guard against an exception in decimalNumberBy…
        if ([self.pricePerUnit isEqualToNumber:[NSDecimalNumber notANumber]] || [self.pricePerUnit isEqualToNumber:[NSDecimalNumber maximumDecimalNumber]] || [self.currentQuantity isEqualToNumber:[NSDecimalNumber notANumber]] || [self.currentQuantity isEqualToNumber:[NSDecimalNumber maximumDecimalNumber]]) {
            SDLog(@"WARNING - bad input to price per unit or current quantity");
            SDLog(@"price per unit: %f", [self.pricePerUnit doubleValue]);
            SDLog(@"current quantity: %f", [self.currentQuantity doubleValue]);
        }
        else
        {
            NSDecimalNumber *total = [self.pricePerUnit decimalNumberByMultiplyingBy:self.currentQuantity];
            totalCostString = [self.priceFormatter stringFromNumber:total];
        }
        
    }
    return totalCostString;
}

-(void)updateTotalCost
{
    NSString *totalCostString = [self totalCostString];
    if (totalCostString != nil) {
        self.quantityViewDelegate.totalPriceLabel.text = totalCostString;
    }
}

-(NSString *)totalWeightString
{
    NSString *totalWeightString = nil;
    
    if (self.adjustQuantityMethod == kAdjustableItemQuantityMethod_Both) {
        NSDecimalNumber *totalWeight = [self.currentQuantity decimalNumberByMultiplyingBy:self.avgWeight];
        //push totalWeight to IQV's totalWeightLabel
        SDLog(@"total weight is now %@ kg", [totalWeight stringValue]);
        totalWeightString = [NSString stringWithFormat:@"~%@ kg", [totalWeight stringValue]];
    }
    
    return totalWeightString;
}

-(void)updateTotalWeight
{
    NSString *totalWeightString = [self totalWeightString];
    if (totalWeightString != nil) {
        @strongify(_quantityViewDelegate, viewDelegate);
        viewDelegate.totalWeightLabel.text = totalWeightString;
    }
}

-(void)updateTotalWeightAndCost
{
    if ([self areTotalCostAndTotalWeightTheSameLabel]) {
        NSString *totalCostString = [self totalCostString];
        NSString *totalWeightString = [self totalWeightString];
        NSString *combinedString = nil;
        
        if ( totalCostString != nil && totalWeightString != nil ) {
            combinedString = [NSString stringWithFormat:@"%@ / %@", totalCostString, totalWeightString];
        } else if ( totalCostString == nil && totalWeightString != nil ) {
            combinedString = totalWeightString;
        } else if ( totalCostString != nil && totalWeightString == nil ) {
            combinedString = totalCostString;
        }
        
        @strongify(_quantityViewDelegate, viewDelegate);
        viewDelegate.totalWeightLabel.text = combinedString;
    } else {
        [self updateTotalCost];
        [self updateTotalWeight];
    }
}

-(BOOL)areTotalCostAndTotalWeightTheSameLabel
{
    if (self.adjustQuantityMethod == kAdjustableItemQuantityMethod_Counted) {
        return NO;
    }
    
    @strongify(_quantityViewDelegate, viewDelegate);
    return viewDelegate.totalWeightLabel == self.quantityViewDelegate.totalPriceLabel;
}

/// Returns the new quantity if it has been updated, or nil if it hasn't
-(NSDecimalNumber *)updatedQuantity
{
    NSDecimalNumber *result = nil;
    if (! [self.currentQuantity isEqualToNumber:self.originalQuantity]) {
        result = self.currentQuantity;
    }
    return result;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &kObserveQuantityContext) {
        if ([[change valueForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting) {
            NSDecimalNumber *newValue = (NSDecimalNumber*)[change objectForKey:NSKeyValueChangeNewKey];
            SDLog(@"Quantity Changed to %f", [newValue floatValue]);
            self.quantityViewDelegate.quantityLabel.text = [self displayWeightLabelTextWithValue:newValue];
        }
    }
}

- (void)resetOriginalQuantity
{
    self.originalQuantity = [NSDecimalNumber zero];
    self.currentQuantity = [self.originalQuantity decimalNumberByAdding:self.stepAmount];
    [self updateTotalWeightAndCost];
    [self updateButtonState];
}

- (void)resetCurrentQuantity
{
    self.currentQuantity = self.originalQuantity;
    [self updateTotalWeightAndCost];
    [self updateButtonState];
}

- (void)setCurrentAsBaseline
{
    self.originalQuantity = self.currentQuantity;
    self.updatedQuantity = nil;
    
    if ([self.originalQuantity isEqual:[NSDecimalNumber zero]])
    {
        self.currentQuantity = [self.originalQuantity decimalNumberByAdding:self.stepAmount];
    }
    [self updateTotalWeightAndCost];
    [self updateButtonState];
}

@end


