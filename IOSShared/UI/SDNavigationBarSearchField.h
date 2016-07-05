//
//  SDNavigationBarSearchField.h
//  SetDirection
//
//  Created by Andrew Finnell on 4/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSearchUsageDelegate.h"
#import "SDSearchSuggestionsDataSource.h"

@class SDNavigationBarSearchField, SDSearchSuggestionsViewController;

@protocol SDNavigationBarSearchFieldDelegate <NSObject>

- (void) searchField:(SDNavigationBarSearchField *)field performSearch:(NSString *)term;

@end

@interface SDNavigationBarSearchField : UIView

@property (nonatomic, weak) id<SDNavigationBarSearchFieldDelegate> delegate;
@property (nonatomic, weak) id<SDSearchUsageDelegate> usageDelegate;
@property (nonatomic, weak) id<SDSearchSuggestionsDataSource> suggestionDataSource;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) SDSearchSuggestionsViewController *suggestionsViewController;
@property (nonatomic, strong) UIPopoverController *suggestionsPopover;

@property (nonatomic) BOOL collapseRegardlessIfEmpty;

- (void) clear; // manually clear the field + animations

// Override points for subclasses
- (CGRect) textFieldFrame;
- (CGRect) textFieldExpandedFrame;

- (void) configureTextField __attribute__((objc_requires_super)); // call super
- (void) configureSuggestionTableCell:(UITableViewCell *)cell;
- (void) configurePopover;
- (void) configureSuggestionsViewController;
- (void) configureForExpand;
- (void) configureForCollapse;

- (void) collapse __attribute__((objc_requires_super));
- (void) expand __attribute__((objc_requires_super));

@end
