//
//  SDTableViewSectionController.m
//  ios-shared

//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDTableViewSectionController.h"
#import "SDMacros.h"

// Define USES_RESPONDS_TO_SELECTOR_SHORTCUT in your project to have SDTableViewSectionController figure out which methods are actually implemented by
// sections.  This code, while more "proper' in terms of what is actually implemented, appears to be causing
// crashes and other issues because of how it fiddles with tableView's dataSource and delegate.

//#define USES_RESPONDS_TO_SELECTOR_SHORTCUT // For debugging

// Define SDTABLEVIEWSECTIONCONTROLLER_INCLUDE_ESTIMATEDHEIGHTFORROW in your project to have SDTableViewSectionController implement
// estimatedHeightForRow.  This method is flaky, so beware!

@interface SDTableViewSectionController () <UITableViewDataSource, UITableViewDelegate, SDTableViewAutoUpdateDataSource>
{
#ifdef USES_RESPONDS_TO_SELECTOR_SHORTCUT
    // Private flags
    BOOL _sectionsImplementHeightForRow;
    BOOL _sectionsImplementTitleForHeader;
    BOOL _sectionsImplementViewForHeader;
    BOOL _sectionsImplementHeightForHeader;
    BOOL _sectionsImplementTitleForFooter;
    BOOL _sectionsImplementViewForFooter;
    BOOL _sectionsImplementHeightForFooter;
    BOOL _sectionsImplementEditingStyleForRow;
    BOOL _sectionsImplementShouldIndentWhileEditingRow;
    BOOL _sectionsImplementCommitEditingStyleForRow;
    BOOL _sectionsImplementWillDisplayCellForRow;
    BOOL _sectionsImplementDidEndDisplayingCellForRow;
    BOOL _sectionsImplementScrollViewDidScroll;
    BOOL _sectionsImplementEstimatedHeightForRow;
#endif
}

@property (nonatomic, weak)   UITableView       *tableView;
@property (nonatomic, strong) NSArray           *sectionControllers;
@property (nonatomic, strong) NSArray           *outgoingSectionControllers;
@end

@implementation SDTableViewSectionController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    return self;
}

- (void)dealloc
{
    @strongify(self.tableView, strongTableView);
    strongTableView.delegate = nil; // Due to strange crashes, let's just be sure we're not getting called after we're tossed
    strongTableView.dataSource = nil; // See above
}

- (void)reloadWithSectionControllers:(NSArray *)sectionControllers animated:(BOOL)animated
{
    self.outgoingSectionControllers = self.sectionControllers;  // Hold onto until we are at the end of this method so when the delegate is swapped, they are not immediately dealloced
    // This is an attempt to "fix" the unreproducible crashes:
    //      https://www.crashlytics.com/walmartlabs/ios/apps/com.walmart.electronics/issues/539ad53ae3de5099ba56db1e
    //      https://www.crashlytics.com/walmartlabs/ios/apps/com.walmart.electronics/issues/539a7a35e3de5099ba568723
    //      https://www.crashlytics.com/walmartlabs/ios/apps/com.walmart.electronics/issues/539ab68ee3de5099ba56bd4e
    
    @strongify(self.tableView, strongTableView);
    
    [self p_sendSectionDidUnload:self.sectionControllers];
    
    self.sectionControllers = sectionControllers;
    
    // Send sectionDidLoad to all new controllers because
    // These new controllers will come into play if:
    // 1) The section is new
    // 2) The section has rows that are added, removed, or updated
    [self p_sendSectionDidLoad:self.sectionControllers];
    
#ifdef USES_RESPONDS_TO_SELECTOR_SHORTCUT
    // Force caching of our flags and the table view's flags
    [self p_updateFlags];
    strongTableView.delegate = nil;
    strongTableView.dataSource = nil;
    strongTableView.delegate = self;
    strongTableView.dataSource = self;
#endif
    
    if (animated)
    {
        // Debug only check to make sure we're doing the right thing
        [self p_sections:sectionControllers conformToProtocol:@protocol(SDTableSectionProtocol)];

        NSDictionary *animationTypes = @{SDTableCommandAddRowAnimationKey : @(UITableViewRowAnimationTop),
                                         SDTableCommandAddSectionAnimationKey : @(UITableViewRowAnimationTop),
                                         SDTableCommandRemoveRowAnimationKey : @(UITableViewRowAnimationBottom),
                                         SDTableCommandRemoveSectionAnimationKey : @(UITableViewRowAnimationBottom),
                                         SDTableCommandUpdateRowAnimationKey : @(UITableViewRowAnimationFade)};

        // First copy the outgoing array of controllers into a mutable array, so we can mutate it
        // Cannot just call mutableCopy because outgoingSectionControllers may be nil
        NSMutableArray *sectionControllersPrime = [NSMutableArray arrayWithCapacity:10];
        [sectionControllersPrime addObjectsFromArray:self.outgoingSectionControllers];

        [strongTableView updateWithAutoUpdateDataSource:self
                       withRowAnimationTypes:animationTypes
                                 updateBlock:^{
                                 }
                        commandCallbackblock:^(SDTableViewCommand *command) {
                            switch (command.commandType)
                            {
                                case kSDTableCommandRemoveSection:
                                {
                                    // Remove all the section from prime
                                    [sectionControllersPrime removeObjectAtIndex:(NSUInteger)command.resolvedIndexPath.section];
                                    break;
                                }
                                case kSDTableCommandAddSection:
                                {
                                    id sectionAdded = [self p_sectionInControllers:self.sectionControllers withIdentifier:command.sectionIdentifier];
                                    if (sectionAdded)
                                    {
                                        [sectionControllersPrime insertObject:sectionAdded atIndex:(NSUInteger)command.resolvedIndexPath.section];
                                    }
                                    break;
                                }
                                case kSDTableCommandUpdateRow:
                                case kSDTableCommandAddRow:
                                case kSDTableCommandRemoveRow:
                                {
                                    // If a row is updated, added, or removed, we need to make sure that the new section controller
                                    // replaces the old section controller
                                    id outgoingSection =  [self p_sectionInControllers:self.outgoingSectionControllers withIdentifier:command.sectionIdentifier];
                                    id incomingSection =  [self p_sectionInControllers:self.sectionControllers withIdentifier:command.sectionIdentifier];
                                    NSUInteger index = [self p_indexOfSection:outgoingSection inControllers:sectionControllersPrime];
                                    if (index != NSNotFound)
                                    {
                                        [sectionControllersPrime removeObject:outgoingSection];
                                        if (incomingSection)
                                        {
                                            [sectionControllersPrime insertObject:incomingSection atIndex:index];
                                        }
                                    }
                                    break;
                                }
                                default:
                                    // Ignore other commands
                                    break;
                            }
                        }];
        // Set section controllers to the updated array
        self.sectionControllers = [sectionControllersPrime copy];
     }
    else
    {
        [strongTableView reloadData];
    }
    self.outgoingSectionControllers = nil;

}

#pragma mark - UITableView DataSource

// This is where we hook to ask our dataSource for the Array of controllers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount;
    
    sectionCount = (NSInteger)self.sectionControllers.count;
    
    return sectionCount;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:commitEditingStyle:forRow:)])
    {
        [sectionController sectionController:self commitEditingStyle:editingStyle forRow:row];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    NSString *title;
    if ([sectionController respondsToSelector:@selector(sectionControllerTitleForHeader:)])
    {
        title = [sectionController sectionControllerTitleForHeader:self];
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    NSString *title;
    if ([sectionController respondsToSelector:@selector(sectionControllerTitleForFooter:)])
    {
        title = [sectionController sectionControllerTitleForFooter:self];
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(numberOfRowsForSectionController:)])
    {
        numberOfRows = [sectionController numberOfRowsForSectionController:self];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell *cell = nil;
    
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:cellForRow:)])
    {
        cell = [sectionController sectionController:self cellForRow:row];
    }
    return cell;
}

#pragma mark - UITableView Delegate

#pragma mark Managing Selections

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0)
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    // Respect the IB settings.
    BOOL highlight = [tableView isEditing] ? [tableView allowsSelectionDuringEditing] : [tableView allowsSelection];
    
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:shouldHighlightRow:)])
    {
        highlight = [sectionController sectionController:self shouldHighlightRow:row];
    }
    
    return highlight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // DEV NOTE: disable user interaction temporarily here to prevent button mashing issues.
    tableView.userInteractionEnabled = NO;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:didSelectRow:)])
    {
        [sectionController sectionController:self didSelectRow:row];
    }
    
    // re-enable user interaction.
    tableView.userInteractionEnabled = YES;
}


#pragma mark Configuring Rows for the Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    CGFloat rowHeight = 44.0;
    if ([sectionController respondsToSelector:@selector(sectionController:heightForRow:)])
    {
        rowHeight = [sectionController sectionController:self heightForRow:row];
    }
    return rowHeight;
}

#ifdef SDTABLEVIEWSECTIONCONTROLLER_INCLUDE_ESTIMATEDHEIGHTFORROW
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    CGFloat estimatedRowHeight = 44.0;
    if ([sectionController respondsToSelector:@selector(sectionController:estimatedHeightForRow:)])
    {
        estimatedRowHeight = [sectionController sectionController:self estimatedHeightForRow:row];
    }
    else
    {
        estimatedRowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return estimatedRowHeight;
}
#endif

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:willDisplayCell:forRow:)])
    {
        [sectionController sectionController:self willDisplayCell:cell forRow:row];
    }
}

#pragma mark Modifying the Header and Footer of Sections

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = 0.0;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionControllerHeightForHeader:)])
    {
        headerHeight =[sectionController sectionControllerHeightForHeader:self];
    }
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *result = nil;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionControllerViewForHeader:)])
    {
        result = [sectionController sectionControllerViewForHeader:self];
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footerHeight = 0.0;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionControllerHeightForFooter:)])
    {
        footerHeight = [sectionController sectionControllerHeightForFooter:self];
    }
    return footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = nil;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionControllerViewForFooter:)])
    {
        result = [sectionController sectionControllerViewForFooter:self];
    }
    return result;
}

#pragma mark Editing Table Rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:editingStyleForRow:)])
    {
        editingStyle =[sectionController sectionController:self editingStyleForRow:row];
    }
    
    return editingStyle;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
{
    BOOL shouldIndent = YES;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:shouldIndentWhileEditingRow:)])
    {
        shouldIndent =[sectionController sectionController:self shouldIndentWhileEditingRow:row];
    }
    
    return shouldIndent;
}

#pragma mark Tracking the Removal of Views

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    id<SDTableViewSectionDelegate>sectionController = [self p_sectionAtIndex:section];
    if ([sectionController respondsToSelector:@selector(sectionController:didEndDisplayingCell:forRow:)])
    {
        [sectionController sectionController:self didEndDisplayingCell:cell forRow:row];
    }
}

#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (id<SDTableViewSectionDelegate> sectionController in self.sectionControllers)
    {
        if ([sectionController respondsToSelector:@selector(sectionController:scrollViewDidScroll:)])
        {
            [sectionController sectionController:self scrollViewDidScroll:scrollView];
        }
    }
    
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:scrollViewDidScroll:)])
    {
        [delegate sectionController:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for (id<SDTableViewSectionDelegate> sectionController in self.sectionControllers)
    {
        if ([sectionController respondsToSelector:@selector(sectionController:scrollViewWillBeginDragging:)])
        {
            [sectionController sectionController:self scrollViewWillBeginDragging:scrollView];
        }
    }
    
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:scrollViewWillBeginDragging:)])
    {
        [delegate sectionController:self scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    for (id<SDTableViewSectionDelegate> sectionController in self.sectionControllers)
    {
        if ([sectionController respondsToSelector:@selector(sectionController:scrollViewDidEndDragging:willDecelerate:)])
        {
            [sectionController sectionController:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
    }
    
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:scrollViewDidEndDragging:willDecelerate:)])
    {
        [delegate sectionController:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - SectionController Methods

- (void)refreshTable
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(refreshTableForSectionController:)])
    {
        [delegate refreshTableForSectionController:self];
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate conformsToProtocol:@protocol(SDTableViewSectionControllerDelegate)])
    {
        [delegate sectionController:self pushViewController:viewController animated:animated];
    }
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:presentViewController:animated:completion:)])
    {
        [delegate sectionController:self presentViewController:viewController animated:animated completion:completion];
    }
}

- (void)dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:dismissViewControllerAnimated:completion:)])
    {
        [delegate sectionController:self dismissViewControllerAnimated:animated completion:completion];
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:popViewController:)])
    {
        [delegate sectionController:self popViewController:animated];
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    @strongify(self.delegate, delegate);
    if ([delegate respondsToSelector:@selector(sectionController:popToRootViewControllerAnimated:)])
    {
        [delegate sectionController:self popToRootViewControllerAnimated:animated];
    }
}

- (NSUInteger)p_indexOfSection:(id<SDTableViewSectionDelegate>)section inControllers:(NSArray *)controllers
{
    NSUInteger sectionIndex = [controllers indexOfObject:section];
    return sectionIndex;
}


- (NSUInteger)indexOfSection:(id<SDTableViewSectionDelegate>)section
{
    NSUInteger sectionIndex = [self p_indexOfSection:section inControllers:self.sectionControllers];
    return sectionIndex;
}

// Private method to find a section within an array of controllers
- (id<SDTableViewSectionDelegate>)p_sectionInControllers:(NSArray *)controllers withIdentifier:(NSString *)identifier
{
    id<SDTableViewSectionDelegate>section = nil;

    NSUInteger indexOfSection = [controllers indexOfObjectPassingTest:^BOOL(id<SDTableViewSectionDelegate> obj, NSUInteger idx, BOOL *stop) {
        BOOL sectionAlreadyInArray = [obj.identifier isEqualToString: identifier];
        *stop = sectionAlreadyInArray;
        return sectionAlreadyInArray;
    }];

    if (indexOfSection != NSNotFound)
    {
        section = controllers[indexOfSection];
    }

    return section;
}


- (id<SDTableViewSectionDelegate>)sectionWithIdentifier:(NSString *)identifier
{
    id<SDTableViewSectionDelegate>section = nil;

    section = [self p_sectionInControllers:self.sectionControllers withIdentifier:identifier];

    return section;
}

- (id<SDTableViewSectionDelegate>)p_sectionAtIndex:(NSInteger)index
{
    id<SDTableViewSectionDelegate> sectionController = nil;
    if ((index != NSNotFound) && (index < self.sectionControllers.count))
    {
        sectionController = self.sectionControllers[(NSUInteger)index];
    }
    return sectionController;
}

#pragma mark - Height Methods

- (CGFloat)heightAboveSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight
{
    CGFloat height = 0;
    NSUInteger sectionIndex = [self indexOfSection:section];
    if (sectionIndex > 0 && sectionIndex != NSNotFound)
    {
        NSRange rangeOfIndexes = NSMakeRange(0, sectionIndex);
        NSIndexSet *sectionIndexes = [[NSIndexSet alloc] initWithIndexesInRange:rangeOfIndexes];
        NSArray *sections = [self.sectionControllers objectsAtIndexes:sectionIndexes];
        height = [self p_heightForSections:sections maxHeight:maxHeight];
    }
    return height;
}

- (CGFloat)heightBelowSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight
{
    CGFloat height = 0;
    NSUInteger sectionIndex = [self indexOfSection:section];
    if ((sectionIndex < (self.sectionControllers.count - 1) && sectionIndex != NSNotFound))
    {
        NSRange rangeOfIndexes = NSMakeRange(sectionIndex + 1, self.sectionControllers.count - sectionIndex - 1);
        NSIndexSet *sectionIndexes = [[NSIndexSet alloc] initWithIndexesInRange:rangeOfIndexes];
        NSArray *sections = [self.sectionControllers objectsAtIndexes:sectionIndexes];
        height = [self p_heightForSections:sections maxHeight:maxHeight];
    }
    return height;
}

- (CGFloat)p_heightForSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight
{
    CGFloat sectionHeight = 0;
    
    @strongify(self.tableView, strongTableView);
    // Must check selector because section height is optional
    if ([section respondsToSelector:@selector(sectionControllerHeightForHeader:)])
    {
        sectionHeight = [section sectionControllerHeightForHeader:self];
    }
    else
    {
        if ([section respondsToSelector:@selector(sectionControllerTitleForHeader:)] ||
            [section respondsToSelector:@selector(sectionControllerViewForHeader:)])
        {
            sectionHeight = [strongTableView sectionHeaderHeight];
        }
    }
    
    // If we have not already exceeded maxHeight, let's look at the rows
    if (sectionHeight < maxHeight)
    {
        NSInteger numberOfCells = [section numberOfRowsForSectionController:self];
        for (NSInteger cellIndex = 0; cellIndex < numberOfCells; cellIndex++)
        {
            if ([section respondsToSelector:@selector(sectionController:heightForRow:)])
            {
                sectionHeight += [section sectionController:self heightForRow:cellIndex];
            }
            else
            {
                sectionHeight += [strongTableView rowHeight];
            }
            
            if (sectionHeight > maxHeight)
            {
                sectionHeight = maxHeight;
                break;
            }
        }
    }
    else
    {
        sectionHeight = maxHeight;
    }
    
    return sectionHeight;
}

- (CGFloat)p_heightForSections:(NSArray *)sections maxHeight:(CGFloat)maxHeight
{
    CGFloat height = 0;
    for (id<SDTableViewSectionDelegate>section in sections)
    {
        height += [self p_heightForSection:section maxHeight:maxHeight];
        if (height > maxHeight)
        {
            height = maxHeight;
            break;
        }
    }
    return height;
}

#pragma mark RespondsToSelector methods

#ifdef USES_RESPONDS_TO_SELECTOR_SHORTCUT
// Based on the results of calling p_updateFlags, let table view know if we do or do not have
// sections that implement our proxy delegat methods
// This allows table view behavior to remain the same as if the we had never implemented those methods
- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result;
    if (aSelector == @selector(tableView:heightForRowAtIndexPath:))
    {
        result = _sectionsImplementHeightForRow;
    } else if (aSelector == @selector(tableView:titleForHeaderInSection:))
    {
        result = _sectionsImplementTitleForHeader;
    } else if (aSelector == @selector(tableView:viewForHeaderInSection:))
    {
        result = _sectionsImplementViewForHeader;
    } else if (aSelector == @selector(tableView:heightForHeaderInSection:))
    {
        result = _sectionsImplementHeightForHeader;
    } else if (aSelector == @selector(tableView:titleForFooterInSection:))
    {
        result = _sectionsImplementTitleForFooter;
    } else if (aSelector == @selector(tableView:viewForFooterInSection:))
    {
        result = _sectionsImplementViewForFooter;
    } else if (aSelector == @selector(tableView:heightForFooterInSection:))
    {
        result = _sectionsImplementHeightForFooter;
    } else if (aSelector == @selector(tableView:editingStyleForRowAtIndexPath:))
    {
        result = _sectionsImplementEditingStyleForRow;
    } else if (aSelector == @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:))
    {
        result = _sectionsImplementShouldIndentWhileEditingRow;
    } else if (aSelector == @selector(tableView:commitEditingStyle:forRowAtIndexPath:))
    {
        result = _sectionsImplementCommitEditingStyleForRow;
    } else if (aSelector == @selector(tableView:willDisplayCell:forRowAtIndexPath:))
    {
        result = _sectionsImplementWillDisplayCellForRow;
    } else if (aSelector == @selector(tableView:didEndDisplayingCell:forRowAtIndexPath:))
    {
        result = _sectionsImplementDidEndDisplayingCellForRow;
    } else if (aSelector == @selector(scrollViewDidScroll:))
    {
        result = _sectionsImplementScrollViewDidScroll;
    } else if (aSelector == @selector(tableView:estimatedHeightForRowAtIndexPath:))
    {
        result = _sectionsImplementEstimatedHeightForRow;
    } else
    {
        result = [super respondsToSelector:aSelector];
    }
    return result;
}

// For every table view delegate/datasource method we proxy, keep a flag
// That we can use to lie to table view about whether we "implement" that
// API or not via respondsToSelector
- (void)p_updateFlags
{
    _sectionsImplementHeightForRow = NO;
    _sectionsImplementTitleForHeader = NO;
    _sectionsImplementViewForHeader = NO;
    _sectionsImplementHeightForHeader = NO;
    _sectionsImplementTitleForFooter = NO;
    _sectionsImplementViewForFooter = NO;
    _sectionsImplementHeightForFooter = NO;
    _sectionsImplementCommitEditingStyleForRow = NO;
    _sectionsImplementEditingStyleForRow = NO;
    _sectionsImplementShouldIndentWhileEditingRow = NO;
    _sectionsImplementWillDisplayCellForRow = NO;
    _sectionsImplementDidEndDisplayingCellForRow = NO;
    _sectionsImplementScrollViewDidScroll = NO;
    _sectionsImplementEstimatedHeightForRow = NO; // OFF
    
    // Radar: 16266367
    // There appears to be a bug in UITableView that will cause a crash when a UITableViewDelegate that implements estimatedHeightForRow
    // for section 1 (of 3) is replaced by another UITableViewDelegate that has two sections that do NOT implement estimatedHeightForRow.
    // To stop the crash we tell our UITableView that we always implement estimatedHeightForRow.  When we get the callback we check
    // to see if the sections actually implement the method.  If they do we return the value computer by the seciton, otherwise we
    // return the default UITableViewAutomaticDimension.
    // Here is an sample app that shows the crash: https://github.com/steveriggins/EstimatedHeight
    
    // Disabled setting _sectionsImplementEstimatedHeightForRow to YES
    
    // Due to other issues with estimated height, such as reloadTable causing a table to scroll if you call it
    // WHen the table is not at 0,0, or causing cells to not re-render, I am making estimatedHeight opt in and then permanent
    // Once any section determines it wants estimated height, this section controller will always respond YES for estimatedHeight
    // And thus if you see any weirdnesses with your table, this may be the reason.
    
    for (NSUInteger controllerIndex = 0; controllerIndex < self.sectionControllers.count; controllerIndex++)
    {
        id<SDTableViewSectionDelegate>sectionController = self.sectionControllers[controllerIndex];
        
        // OR (option) delegate methods
        // We need to handle this delegate if ANY of the sections implement these delegate methods
        _sectionsImplementTitleForHeader |= [sectionController respondsToSelector:@selector(sectionControllerTitleForHeader:)];
        _sectionsImplementViewForHeader |= [sectionController respondsToSelector:@selector(sectionControllerViewForHeader:)];
        _sectionsImplementHeightForHeader |= [sectionController respondsToSelector:@selector(sectionControllerHeightForHeader:)];
        _sectionsImplementTitleForFooter |= [sectionController respondsToSelector:@selector(sectionControllerTitleForFooter:)];
        _sectionsImplementViewForFooter |= [sectionController respondsToSelector:@selector(sectionControllerViewForFooter:)];
        _sectionsImplementHeightForFooter |= [sectionController respondsToSelector:@selector(sectionControllerHeightForFooter:)];
        _sectionsImplementEditingStyleForRow |= [sectionController respondsToSelector:@selector(sectionController:editingStyleForRow:)];
        _sectionsImplementShouldIndentWhileEditingRow |= [sectionController respondsToSelector:@selector(sectionController:shouldIndentWhileEditingRow:)];
        _sectionsImplementCommitEditingStyleForRow |= [sectionController respondsToSelector:@selector(sectionController:commitEditingStyle:forRow:)];
        _sectionsImplementWillDisplayCellForRow |= [sectionController respondsToSelector:@selector(sectionController:willDisplayCell:forRow:)];
        _sectionsImplementDidEndDisplayingCellForRow |= [sectionController respondsToSelector:@selector(sectionController:didEndDisplayingCell:forRow:)];
        _sectionsImplementScrollViewDidScroll |= [sectionController respondsToSelector:@selector(sectionController:scrollViewDidScroll:)];
        
        // AND delegate methods
        // If one of the sections implements these delegate methods, then all must
        BOOL sectionsImplementHeightForRow = [sectionController respondsToSelector:@selector(sectionController:heightForRow:)];
        if (controllerIndex == 0)
        {
            _sectionsImplementHeightForRow = sectionsImplementHeightForRow;
        }
        else
        {
            NSAssert(_sectionsImplementHeightForRow == sectionsImplementHeightForRow, @"If one section implements sectionController:heightForRow:, then all sections must");
        }
    }
}

#endif

#pragma mark - Section Methods

- (void)addSection:(id<SDTableViewSectionDelegate>)section
{
    NSUInteger index = [self.sectionControllers count];
    
    // make sure we are not adding the same section twice
    id<SDTableViewSectionDelegate>sectionWithSameIdentifier;
    sectionWithSameIdentifier = [self sectionWithIdentifier:section.identifier];
    NSAssert(sectionWithSameIdentifier == nil, @"Adding section of identifier: %@ that already exists", section.identifier);
    
    // First change the model of section controllers
    NSMutableArray *newSectionControllers = [NSMutableArray arrayWithArray:self.sectionControllers];
    [newSectionControllers addObject:section];
    self.sectionControllers = [newSectionControllers copy];
    
    // Now add the section to the tableview
    @strongify(self.tableView, tableView);
    NSIndexSet *setOfSectionsToAdd = [[NSIndexSet alloc] initWithIndex:index];
    [tableView beginUpdates];
    [tableView insertSections:setOfSectionsToAdd withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

- (void)removeSection:(id<SDTableViewSectionDelegate>)section
{
    NSUInteger index = [self.sectionControllers indexOfObject:section];
    if (index > 0)
    {
        // First change the model of section controllers
        NSMutableArray *newSectionControllers = [NSMutableArray arrayWithArray:self.sectionControllers];
        [newSectionControllers removeObjectAtIndex:index];
        self.sectionControllers = [newSectionControllers copy];
        
        // Now nuke the section from the tableview
        @strongify(self.tableView, tableView);
        NSIndexSet *setOfSectionsToDelete = [[NSIndexSet alloc] initWithIndex:index];
        [tableView beginUpdates];
        [tableView deleteSections:setOfSectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)reloadSectionWithIdentifier:(NSString *)identifier withRowAnimation:(UITableViewRowAnimation)animation
{
    id<SDTableViewSectionDelegate> section = [self sectionWithIdentifier:identifier];
    if (section) {
        NSUInteger sectionIndex = [self indexOfSection:section];
        if (sectionIndex != NSNotFound)
        {
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:sectionIndex];
            @strongify(self.tableView, tableView);
            [tableView reloadSections:indexSet withRowAnimation:animation];
        }
    }
}

- (void)reloadRow:(NSUInteger)row inSectionWithIdentifier:(NSString *)identifier withRowAnimation:(UITableViewRowAnimation)animation
{
    id<SDTableViewSectionDelegate> section = [self sectionWithIdentifier:identifier];
    if (section) {
        NSUInteger sectionIndex = [self indexOfSection:section];
        if (sectionIndex != NSNotFound)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)row inSection:(NSInteger)sectionIndex];
            @strongify(self.tableView, tableView);
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        }
    }
}

// This current relies on a side effect of endUpdates refreshing the table view
- (void)refreshCellHeights
{
    @strongify(self.tableView, tableView);
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)p_sendSectionDidLoad:(NSArray *)sectionControllers
{
    for (id sectionController in sectionControllers)
    {
        if ([sectionController respondsToSelector:@selector(sectionDidLoad:)])
        {
            [sectionController sectionDidLoad:self];
        }
    }
}

- (void)p_sendSectionDidUnload:(NSArray *)sectionControllers
{
    for (id sectionController in sectionControllers)
    {
        if ([sectionController respondsToSelector:@selector(sectionDidUnload:)])
        {
            [sectionController sectionDidUnload:self];
        }
    }
}

/// This is a runtime check to make sure sections are being passed in properly
- (void)p_sections:(NSArray *)sections conformToProtocol:(Protocol *)protocol
{
#if DEBUG
    for (id section in sections)
    {
        NSAssert([section conformsToProtocol:protocol], @"Section %@ does not implement %@", section, protocol);
    }
#endif
}

#pragma mark - SDTableViewAutoUpdateDataSource methods

- (NSArray *)sectionsForPass:(SDTableViewAutoUpdatePass)pass
{
    NSArray *sections;
    
    switch (pass)
    {
        case kSDTableViewAutoUpdatePassBeforeUpdate:
            sections = self.outgoingSectionControllers;
            break;
        case kSDTableViewAutoUpdatePassAfterUpdate:
            sections = self.sectionControllers;
            break;
    }
    return sections;
}

// Section should be a SDTableViewSectionDelegate
- (NSArray *)rowsForSection:(id<SDTableSectionProtocol>)section pass:(SDTableViewAutoUpdatePass)pass
{
    NSArray *rows;
    
    NSAssert([section conformsToProtocol:@protocol(SDTableViewSectionDelegate)], @"Section %@ does not conform to SDTableViewSectionDelegate", section);
    id <SDTableViewSectionDelegate> sectionDelegate = (id<SDTableViewSectionDelegate>)section;
    
    rows = [sectionDelegate sectionControllerAutoUpdateRows];
    
    NSAssert(rows != nil, @"Rows cannot be nil");
    
    return rows;
}

@end
