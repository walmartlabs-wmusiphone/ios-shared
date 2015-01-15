//
//  SDTableViewSectionControllerAutoUpdateRow.h
//  walmart
//
//  Created by Steve Riggins on 11/10/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableView+SDAutoUpdate.h"

/**
 * This class represents the hash data used by UITableView+SDAutoUpdate
 *
 * It overrides hash and returns the hash passed to it
 *
 * It also returns the required attributeHash
 *
 * This should be used by SDTableViewSectionDelegates when asked for
 * auto update rows
 *
 */

@interface SDTableViewSectionControllerAutoUpdateRow : NSObject <SDTableRowProtocol>
// hash is inherited from NSObject
@property (nonatomic, assign, readonly) NSInteger attributeHash;

/// Shortcut for simple sections with only one non-changing row
+ (instancetype)genericRowOne;
+ (instancetype)genericAlwaysUpdateWithHash:(NSUInteger)hash;
- (instancetype)initWithHash:(NSUInteger)hash attributeHash:(NSInteger)attributeHash;
- (instancetype)initWithHash:(NSUInteger)hash;

@end
