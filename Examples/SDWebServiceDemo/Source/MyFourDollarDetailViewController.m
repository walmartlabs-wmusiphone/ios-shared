//
//  SDWebServiceDemo - MyFourDollarDetailViewController.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyFourDollarDetailViewController.h"

#import "MyFourDollarCategory.h"
#import "MyFourDollarItem.h"


@implementation MyFourDollarDetailViewController

#pragma mark - Property overrides

- (void) setCategory: (MyFourDollarCategory*) category
{
    _category = category;
    
    self.title = category.categoryName;
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return (NSInteger)self.category.drugList.count;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* sDetailCellIdentifier = @"detailCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: sDetailCellIdentifier
                                                            forIndexPath: indexPath];
    // Configure the cell.
    
    MyFourDollarItem* itemData = (MyFourDollarItem*)[self.category.drugList objectAtIndex: (NSUInteger)indexPath.row];
    cell.textLabel.text = itemData.name;
    
    NSString* cellDetailTextFormat = NSLocalizedString( @"30 day supply: %@  /  90 Day Supply: %@", @"UITableViewCell text '30/90 day supply...'" );
    cell.detailTextLabel.text = [NSString stringWithFormat: cellDetailTextFormat, itemData.qty30Day, itemData.qty90Day];
    
    return cell;
}

@end
