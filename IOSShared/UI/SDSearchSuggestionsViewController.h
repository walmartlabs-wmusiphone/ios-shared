//
//  SDSearchSuggestionsViewController.h
//  SetDirection
//
//  Created by Joel Bernstein on 12/8/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSearchUsageDelegate.h"
#import "SDSearchSuggestionsDataSource.h"

@class SDSearchSuggestionsViewController;


@protocol SDSearchSuggestionsViewControllerDelegate <NSObject>

-(void)searchViewController:(SDSearchSuggestionsViewController*)searchViewController didSearchForKeyword:(NSString*)keyword;

-(void) configureSuggestionTableCell:(UITableViewCell *)cell;
-(void) configureSearchSuggestionsViewController:(SDSearchSuggestionsViewController *)viewController;

@end

@interface SDSearchSuggestionsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIButton* clearButton;

@property (nonatomic, weak) id<SDSearchUsageDelegate> usageDelegate;
@property (nonatomic, weak) id<SDSearchSuggestionsViewControllerDelegate> delegate;
@property (nonatomic, weak) id<SDSearchSuggestionsDataSource> suggestionDataSource;

@property (nonatomic, copy) NSString* searchString;

@end
