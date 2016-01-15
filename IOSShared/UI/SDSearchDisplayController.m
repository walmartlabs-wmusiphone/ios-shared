//
//  SDSearchDisplayController.m
//  SetDirection
//
//  Created by brandon on 3/9/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDSearchDisplayController.h"
#import "SDLog.h"

@interface SDSearchDisplayController(Private)
- (void)setup;
@end

@interface SDSearchDisplayController()
@property (nonatomic, assign) BOOL addingSearchTableView;

/// This overrides the internal addingSearchTableView lock in setActive:animated:. Only use this override if you are certain you need to.
@property (nonatomic, assign) BOOL shouldOverrideBlock;

@end

@implementation SDSearchDisplayController

@synthesize userDefaultsKey;
@synthesize maximumCount;
@synthesize filterString;
@synthesize alternateResults;
@synthesize selectedSearchItem;
@synthesize showsClearRecentSearchResultsRow;
@synthesize recentSearchTableView;

static NSString *kSDSearchUserDefaultsKey = @"kSDSearchUserDefaultsKey";

- (id)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController
{
    self = [super initWithSearchBar:searchBar contentsController:viewController];
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}


- (void)setup
{
    self.userDefaultsKey = kSDSearchUserDefaultsKey;
    self.maximumCount = 5;
    
    alternateResults = [[NSMutableArray alloc] init];
    masterList = [[NSMutableArray alloc] init];
}

- (void)setFilterString:(NSString *)value
{
    [masterList addObjectsFromArray:filteredHistory];
    filterString = value;
    
    filteredHistory = nil;
    
    if (filterString && [filterString length] > 0)
    {
        recentSearchTableView.hidden = YES;

        if ([alternateResults count] == 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF beginswith[cd] %@)", filterString];
            filteredHistory = [searchHistory filteredArrayUsingPredicate:predicate];
        }
        else
        {
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF beginswith[cd] %@)", filterString];
            //NSMutableArray *temp = [[alternateResults filteredArrayUsingPredicate:predicate] mutableCopy];
            NSMutableArray *temp = [alternateResults mutableCopy];
            //[temp sortUsingSelector:@selector(compare:)];
            filteredHistory = temp;
        }
    }
    else
    {
        recentSearchTableView.hidden = NO;
        
        filteredHistory = searchHistory;
        UIView *superview = self.searchContentsController.view;
        // this is sketchy, but needs to happen.  if it doesn't, our tableview ends up in the BG because something
        // internal to the searchDisplayController puts the darkened overlay over us.
        [superview performSelector:@selector(bringSubviewToFront:) withObject:recentSearchTableView afterDelay:0];
    }
}

- (void)removeSearchItemFromHistory:(NSString*)string
{
	if([string length])
	{
		NSMutableArray *theArray = nil;
		theArray = searchHistory;
		if(theArray == nil)
		{
			//See if we have nil'd it out but we have it saved to NSUserDefaults
			theArray = [[[NSUserDefaults standardUserDefaults] objectForKey: [self userDefaultsKey]] mutableCopy];
		}
		
		if([theArray count])
		{
			NSUInteger itemIndex = [theArray indexOfObject: string];
			if(itemIndex != NSNotFound)
			{
				@try {
					[theArray removeObjectAtIndex: itemIndex];
				}
				@catch (NSException *exception) {
					SDLog(@"ERR: Couldn't remove history string '%@' from search history", string);
				}
				@finally {
					
				}
				
				[[NSUserDefaults standardUserDefaults] setObject:theArray forKey:self.userDefaultsKey];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}
	}
	[self.recentSearchTableView reloadData];
}

- (void)addStringToHistory:(NSString *)string
{
    if (string && [string length] > 0)
    {
        if ([searchHistory count] == 0) {
            [searchHistory addObject:string];
        } else {
			if ([searchHistory indexOfObject:string] == NSNotFound) {
				[searchHistory insertObject:string atIndex:0];
            } else {
                NSUInteger itemIndex = [searchHistory indexOfObject:string];
                [searchHistory removeObjectAtIndex:itemIndex];
                [searchHistory insertObject:string atIndex:0];
            }
        }
    }
    
    if ([searchHistory count] >= self.maximumCount)
        [searchHistory removeLastObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:searchHistory forKey:self.userDefaultsKey];
    // write it immediately, don't let it lazy-write.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    if (self.addingSearchTableView && !self.shouldOverrideBlock) {
        return;
    }
    
    if (!self.searchResultsDelegate)
        self.searchResultsDelegate = self;
    if (!self.searchResultsDataSource)
        self.searchResultsDataSource = self;
    
    [super setActive:visible animated:animated];
    
    if (visible && !recentSearchTableView)
    {
        self.addingSearchTableView = YES;
        
        [self updateSearchHistory];
        if (!searchHistory)
            searchHistory = [[NSMutableArray alloc] init];
       
    
        UITableView *defaultTableView = self.searchResultsTableView;
        
        recentSearchTableView = [[UITableView alloc] initWithFrame:CGRectZero style:defaultTableView.style];
        recentSearchTableView.delegate = self;
        recentSearchTableView.dataSource = self;
        
        UIView *superview = self.searchContentsController.view;
        
        recentSearchTableView.frame = CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 280);
        recentSearchTableView.alpha = 0;
        [superview addSubview:recentSearchTableView];
        
        // if our subclass wants to color background of simple results tables, do so with simpleResultsTableBackgroundColor
        if (self.simpleResultsTableBackgroundColor)
        {
            self.searchResultsTableView.backgroundColor = self.simpleResultsTableBackgroundColor;
            recentSearchTableView.backgroundColor = self.simpleResultsTableBackgroundColor;
        }
        
        if (animated)
        {
            [UIView animateWithDuration:0.2 animations:^{
                recentSearchTableView.alpha = 1.0;
            } completion:^(BOOL finished){
                self.addingSearchTableView = NO;
            }];
        }
        else
        {
            recentSearchTableView.alpha = 1.0;
            self.addingSearchTableView = NO;
        }
    }
    else {
        if (!visible && recentSearchTableView && !self.addingSearchTableView)
		{
			if (animated)
			{
                __strong id delegate = self.searchBar.delegate;
            
                if ([delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
                    [delegate searchBarCancelButtonClicked:self.searchBar];
                }
                
				[UIView animateWithDuration:0.2 
								 animations:^{
									 recentSearchTableView.alpha = 0;
								 }
								 completion:^(BOOL finished){
									 [recentSearchTableView removeFromSuperview];
									 recentSearchTableView = nil;
								 }];            
			}
			else
			{
				[recentSearchTableView removeFromSuperview];
				recentSearchTableView = nil;            
			}
			[masterList removeAllObjects];
			searchHistory = nil;
		}
    }
}

- (void)forceInactive
{
    // To make sure this works, we turn the override on, change the state (which calls setActive:), and then turn the override back off
    self.shouldOverrideBlock = YES;
    self.active = NO;
    self.shouldOverrideBlock = NO;
}

- (NSUInteger)recentSearchesSectionNumber
{
	//Subclasses can (and should) override if needed to customize
	return 0;
}

#pragma mark tableview delegate/datasource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __strong id oldDelegate = self.searchBar.delegate;
    self.searchBar.delegate = nil;
    
    if (tableView == recentSearchTableView)
    {
        // set the searchbar text here.
        if (indexPath.row < [searchHistory count])
		{
            self.searchBar.text = [searchHistory objectAtIndex:(NSUInteger)indexPath.row];
            self.selectedSearchItem = [searchHistory objectAtIndex:(NSUInteger)indexPath.row];
        }
		else
		{
			if(showsClearRecentSearchResultsRow)
			{
				[searchHistory removeAllObjects];
				[[NSUserDefaults standardUserDefaults] setObject:searchHistory forKey:self.userDefaultsKey];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[recentSearchTableView reloadSections: [NSIndexSet indexSetWithIndex: [self recentSearchesSectionNumber]] withRowAnimation: UITableViewRowAnimationFade];
				self.searchBar.delegate = oldDelegate;
				// ---------------------------------------------------------------- //
				return;
				// ---------------------------------------------------------------- //
			}
		}
    }
    else
    {
        if (indexPath.row < [filteredHistory count]) {
            id<SDSearchDisplayResultsProtocol> item = [filteredHistory objectAtIndex:(NSUInteger)indexPath.row];
            if ([item conformsToProtocol:@protocol(SDSearchDisplayResultsProtocol)])
				self.searchBar.text = [item name];
			else if ([item isKindOfClass:[NSString class]])
				self.searchBar.text = (NSString *)item;
			else
				self.searchBar.text = [item description];
			self.selectedSearchItem = item;
        }
    }
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.delegate = oldDelegate;
	
    if ([oldDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
        [oldDelegate searchBarSearchButtonClicked:self.searchBar];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == recentSearchTableView)
    {
        if (searchHistory)
		{
			NSInteger searchHistoryCount = (NSInteger)[searchHistory count];
			if(showsClearRecentSearchResultsRow && (searchHistoryCount > 0))
			{
				return searchHistoryCount + 1;
			}
			else
			{
				return searchHistoryCount;
			}
		}
    }
    else
    {
        return (NSInteger)[filteredHistory count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (tableView == recentSearchTableView)
    {
        static NSString *identifier = @"SDSearchDisplayControllerHistoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if (indexPath.row < [searchHistory count])
			cell.textLabel.text = [searchHistory objectAtIndex:(NSUInteger)indexPath.row];
		else if(showsClearRecentSearchResultsRow)
			cell.textLabel.text = @"Clear All Recent Searches";
		else
			cell.textLabel.text = nil;
    }
    else
    {
        static NSString *searchCell = @"SDSearchDisplayControllerCell";
        cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell];
        
        if (indexPath.row < [filteredHistory count]) {
			id<SDSearchDisplayResultsProtocol> item = [filteredHistory objectAtIndex:(NSUInteger)indexPath.row];
			if ([item conformsToProtocol:@protocol(SDSearchDisplayResultsProtocol)])
				cell.textLabel.text = [item displayName];
			else if ([item isKindOfClass:[NSString class]])
				cell.textLabel.text = (NSString *)item;
			else
				cell.textLabel.text = [item description];
		} else {
			cell.textLabel.text = nil;
		}
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == recentSearchTableView)
        return @"Recent Searches";
    return nil;
}

- (void)updateSearchHistory
{
    searchHistory = [[[NSUserDefaults standardUserDefaults] arrayForKey:self.userDefaultsKey] mutableCopy];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTableViewScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isTableViewScrolling = NO;
}

@end
