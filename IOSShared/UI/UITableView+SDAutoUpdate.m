//
//  UITableView+SDAutoUpdate.m
//
//  Created by ricky cancro on 4/22/14.
//

#import "UITableView+SDAutoUpdate.h"

#pragma mark - NSString(SDTableSectionObject)
@implementation NSString(SDTableSectionProtocol)

- (NSString *)identifier
{
    return self;
}

@end

#pragma mark - UITableView(SDAutoUpdate)
@implementation UITableView(SDAutoUpdate)

- (void)updateWithAutoUpdateDataSource:(id<SDTableViewAutoUpdateDataSource>)updateDataSource updateBlock:(SDUpdateTableDataBlock)updateBlock
{
    [self updateWithAutoUpdateDataSource:updateDataSource withRowAnimationType:UITableViewRowAnimationAutomatic updateBlock:updateBlock commandCallbackblock:nil];
}

- (void)updateWithAutoUpdateDataSource:(id<SDTableViewAutoUpdateDataSource>)updateDataSource withRowAnimationType:(UITableViewRowAnimation)animationType updateBlock:(SDUpdateTableDataBlock)updateBlock;
{
    [self updateWithAutoUpdateDataSource:updateDataSource withRowAnimationType:animationType updateBlock:updateBlock commandCallbackblock:nil];
}

- (void)updateWithAutoUpdateDataSource:(id<SDTableViewAutoUpdateDataSource>)updateDataSource withRowAnimationTypes:(NSDictionary *)animationTypes updateBlock:(SDUpdateTableDataBlock)updateBlock
{
    [self updateWithAutoUpdateDataSource:updateDataSource withRowAnimationTypes:animationTypes updateBlock:updateBlock commandCallbackblock:nil];
}

- (void)updateWithAutoUpdateDataSource:(id<SDTableViewAutoUpdateDataSource>)updateDataSource withRowAnimationType:(UITableViewRowAnimation)animationType updateBlock:(SDUpdateTableDataBlock)updateBlock commandCallbackblock:(SDTableCommandCallbackBlock)commandCallbackBlock
{
    NSDictionary *animationTypes = @{SDTableCommandAddRowAnimationKey : @(animationType),
                                     SDTableCommandAddSectionAnimationKey : @(animationType),
                                     SDTableCommandRemoveRowAnimationKey : @(animationType),
                                     SDTableCommandRemoveSectionAnimationKey : @(animationType),
                                     SDTableCommandUpdateRowAnimationKey : @(animationType)};
    [self updateWithAutoUpdateDataSource:updateDataSource withRowAnimationTypes:animationTypes updateBlock:updateBlock commandCallbackblock:commandCallbackBlock];
}

- (void)updateWithAutoUpdateDataSource:(id<SDTableViewAutoUpdateDataSource>)updateDataSource withRowAnimationTypes:(NSDictionary *)animationTypes updateBlock:(SDUpdateTableDataBlock)updateBlock commandCallbackblock:(SDTableCommandCallbackBlock)commandCallbackBlock
{
    // get the data that is about to be updated
    NSArray *outdatedSections = [[updateDataSource sectionsForPass:kSDTableViewAutoUpdatePassBeforeUpdate] copy];
    NSMutableDictionary *outdatedRowData = [NSMutableDictionary dictionary];
    
    for (id<SDTableSectionProtocol> section in outdatedSections)
    {
        outdatedRowData[section.identifier] = [[updateDataSource rowsForSection:section pass:kSDTableViewAutoUpdatePassBeforeUpdate] copy];
    }
    
    // call the block to update the table's underlying data
    if (updateBlock)
    {
        updateBlock();
    }
    
    // get the new state of the table
    NSArray *updatedSections = [[updateDataSource sectionsForPass:kSDTableViewAutoUpdatePassAfterUpdate] copy];
    NSMutableDictionary *updatedRowData = [NSMutableDictionary dictionary];
    
    for (id<SDTableSectionProtocol> section in updatedSections)
    {
        updatedRowData[section.identifier] = [[updateDataSource rowsForSection:section pass:kSDTableViewAutoUpdatePassAfterUpdate] copy];
    }
    
    
    SDTableCommandManager *manager = [[SDTableCommandManager alloc] initWithOutdatedSections:outdatedSections updatedSections:updatedSections];
    
    NSMutableSet *allSectionIdentifiers = [NSMutableSet setWithArray:[outdatedRowData allKeys]];
    [allSectionIdentifiers addObjectsFromArray:[updatedRowData allKeys]];
    
    for (NSString *sectionIdentifier in allSectionIdentifiers)
    {
        [manager addCommandsForOutdatedData:outdatedRowData[sectionIdentifier] newData:updatedRowData[sectionIdentifier] forSectionIdentifier:sectionIdentifier];
    }
    
    if ([manager hasCommands])
    {
        // Moving beginUpdates back to here because we only want this to run if we actually have work to do
        // Also, beginUpdates was sometimes being called without a matching endUpdates
        // We do not want to *always* call these methods because they trigger unneccessary side effects like heightForRow: being called on existing cells
        [self beginUpdates];
        [manager runCommands:self withAnimationTypes:animationTypes callback:commandCallbackBlock];
        [self endUpdates];
    }
}

@end
