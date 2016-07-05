//
//  UITableViewCell+SDExtensions.h
//  walmart
//
//  Created by Cody Garvin on 10/17/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Extension on UITableViewCell that help with layout and other utility methods.
 */
@interface UITableViewCell (SDExtensions)

/**
 *  Used to calculate the appropriate height for a cell. Takes into account 
 *  multi-line labels, custom constraints, tableview bounds and other autolayout fun.
 *  Takes into account sizing with accessory views enabled.
 *
 *  @param tableview - The main tableview that the cell is housed in.
 *
 *  @param separatorHeight - If an added separator has to be added in to the height, make sure to pass in the height of that separator.
 *
 *  @return CGFloat - The height of the cell after calculation.
 */
- (CGFloat)calculatedHeightForCellInTableview:(UITableView *)tableview
                              separatorHeight:(CGFloat)separatorHeight;

@end
