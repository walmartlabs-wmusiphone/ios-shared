//
//  UITableViewCell+SDExtensions.m
//  walmart
//
//  Created by Cody Garvin on 10/17/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "UITableViewCell+SDExtensions.h"
#import "UIView+SDExtensions.h"
#import "UIDevice+machine.h"

@implementation UITableViewCell (SDExtensions)

- (CGFloat)calculatedHeightForCellInTableview:(UITableView *)tableview
                              separatorHeight:(CGFloat)separatorHeight
{
    // Grab the original bounds, so that it can be reset later
    CGRect originalBoundsToBeReset = self.bounds;
    
    // Set the temporary sizing bounds so that we can use systemLayoutSizeFittingSize:
    // Note the contentView width is used. This helps with cells that could have a
    // manipulated contentView width or have an accessory view. If this isn't accounted
    // for than multi-line labels could be incorrectly calculated since the entire
    // width of the cell would be used during the calculation. CB-2666 / CB-2631 cgarvin
    
    // Figure out the difference between the contentView and the cell, and then subtract
    // that from the tableview bounds (might be wider than cell on wide phones)
    
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableview.bounds) - (CGRectGetWidth(self.bounds) - CGRectGetWidth(self.contentView.bounds)), CGRectGetHeight(tableview.bounds));

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGFloat cellHeight;
    if ([UIDevice systemMajorVersion] >= 8.0)
    {
        CGSize tempSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize
                              withHorizontalFittingPriority:UILayoutPriorityRequired
                                    verticalFittingPriority:UILayoutPriorityDefaultHigh];
        cellHeight = (tempSize.height + separatorHeight);
    }
    else
    {
        cellHeight = ([self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + separatorHeight);
    }
    
    // Set the original bounds back, just in case it was changed by another area
    // besides here.
    self.bounds = originalBoundsToBeReset;
    
    // Redraw again to make sure that the bounds reset takes place immediately. CB-2693
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    return cellHeight;
}

@end
