//
//  SDTableViewSectionController.h
//  ios-shared

//
//  Created by Steve Riggins & Woolie on 1/2/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECTIONCONTROLLER_MAX_HEIGHT MAXFLOAT

// New to this class?  Start with reloadWithSectionControllers:

@class SDTableViewSectionController;

//____________________________________________________________________________________________
/**
 *
 * SDTableViewSectionControllerDelegate is typically implemented by a UIViewController
 * to provide the logic for how the table view should respond to requests by the
 * table view section controller.
 *
 * Optional delete methods add navigation support.  You should implement these methods
 * If you want your view controller to support push/pop/modal navigation
 * (Proxy these methods to your navigationController)
 */

@protocol SDTableViewSectionControllerDelegate <NSObject>

@optional

/**
 *  A section controller is asking you to push a view controller
 *
 *  @param sectionController The section controller making the request
 *  @param viewController    The view controller the section controller wants pushed
 *  @param animated          YES if the section controller wants the push animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  A section controller is asking you to present a view controller
 *
 *  @param sectionController The section controller making the request
 *  @param viewController    The view controller the section controller wants presented
 *  @param animated          YES if the section controller wants the presentation animated
 *  @param completion        A completion block to call when presentation is complete
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  A section controller is asking you to dismiss the current view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the dismiss animated
 *  @param completion        A completion block to call when presentation is complete
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion;

/**
 *  A section controller is asking you to pop the current view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the pop animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController popViewController: (BOOL)animated;

/**
 *  A section controller is asking you to pop to the root view controller
 *
 *  @param sectionController The section controller making the request
 *  @param animated          YES if the section controller wants the pop animated
 */
- (void)sectionController:(SDTableViewSectionController *)sectionController popToRootViewControllerAnimated:(BOOL)animated;

@end

//________________________________________________________________________________________
/**
 *
 * The SDTableViewSectionDelegate protocol declares the data and delegate interface for section controllers
 *
 */

@protocol SDTableViewSectionDelegate <NSObject>

/////////////////////////////////////////////////////////////////////////////////////////
/// @name "DataSource" methods
/////////////////////////////////////////////////////////////////////////////////////////
@required

/**
 *  Your section must return a unique identifier per instance
 */
@property (nonatomic, copy, readonly) NSString *identifier;

- (NSInteger)numberOfRowsForSectionController:(SDTableViewSectionController *)sectionController;
- (UITableViewCell *)sectionController:(SDTableViewSectionController *)sectionController cellForRow:(NSInteger)row;

@optional

/**
 *  Return a title for the header for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a title for the header for this section
 */
- (NSString *)sectionControllerTitleForHeader:(SDTableViewSectionController *)sectionController;

/**
 *  Return a view for the header for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a view for the header for this section
 */
- (UIView *)sectionControllerViewForHeader:(SDTableViewSectionController *)sectionController;

- (CGFloat)sectionControllerHeightForHeader:(SDTableViewSectionController *)sectionController;

/**
 *  Return a title for the footer for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a title for the footer for this section
 */
- (NSString *)sectionControllerTitleForFooter:(SDTableViewSectionController *)sectionController;

/**
 *  Return a view for the footer for this section
 *
 *  @param sectionController The section controller making the request
 *
 *  @return a view for the footer for this section
 */
- (UIView *)sectionControllerViewForFooter:(SDTableViewSectionController *)sectionController;

- (CGFloat)sectionControllerHeightForFooter:(SDTableViewSectionController *)sectionController;

// "Delegate" methods
@optional
- (void)sectionController:(SDTableViewSectionController *)sectionController didSelectRow:(NSInteger)row;

@optional
// Configuring Rows for the Table View
- (CGFloat)sectionController:(SDTableViewSectionController *)sectionController heightForRow:(NSInteger)row;
- (void)sectionController:(SDTableViewSectionController *)sectionController willDisplayCell:(UITableViewCell *)cell forRow:(NSInteger)row;
- (CGFloat)sectionController:(SDTableViewSectionController *)sectionController estimatedHeightForRow:(NSInteger)row;

@optional
// Editing support
- (UITableViewCellEditingStyle)sectionController:(SDTableViewSectionController *)sectionController editingStyleForRow:(NSInteger)row;
- (BOOL)sectionController:(SDTableViewSectionController *)sectionController shouldIndentWhileEditingRow:(NSInteger)row;
- (void)sectionController:(SDTableViewSectionController *)sectionController commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRow:(NSInteger)row;

@optional
// Tracking the Removal of Views
- (void)sectionController:(SDTableViewSectionController *)sectionController didEndDisplayingCell:(UITableViewCell *)cell forRow:(NSInteger)row;

@optional
// Scroll View Delegate
- (void)sectionController:(SDTableViewSectionController *)sectionController scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)sectionController:(SDTableViewSectionController *)sectionController scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)sectionController:(SDTableViewSectionController *)sectionController scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@optional
// Section Lifecycle support
- (void)sectionDidLoad:(SDTableViewSectionController *)sectionController;
- (void)sectionDidUnload:(SDTableViewSectionController *)sectionController;
@end

//__________________________________________________________________________
/**
 *
 * SDTableViewSectionController manages objects that implement the SDTableViewSectionDelegate protocol.
 * 
 * SDTableViewSectionController allows the logic for table view sections to be broken up into discrete
 * controller objects.  The implementer of SDTableViewSectionDelegate objects is free to pass any models
 * or data to the controllers.
 *
 * SDTableViewSectionController will query its SDTableViewSectionDelegate objects in a manner similar to UITableView.
 * A SDTableViewSectionDelegate will be asked for its number of rows, cells for each rows, etc.
 *
 * Once your view controller (or any other controller) has received an update that requires the table view to be
 * refreshed, generate a new array of SDTableViewSectionDelegate objects and send them to the SDTableViewSectionController
 * by calling reloadWithSectionControllers:animated:
 */

@interface SDTableViewSectionController : NSObject

/**
 *  Initializes a newly created UITableViewSectionController with a UITableView.
 *  Takes over the UITableViewDataSource and UITableViewDelegate responsibilities for the UITableView
 *
 *  @param tableView The UITableView to manage
 *
 *  @return An newly initialized SDTableViewSectionController object 
 */
- (instancetype) initWithTableView:(UITableView *)tableView;

@property (nonatomic, weak)             id <SDTableViewSectionControllerDelegate>  delegate;
@property (nonatomic, weak, readonly)   UITableView                                 *tableView;

/**
 *  Array of objects conforming to the SDTableViewSectionDelegate protocol
 */
@property (nonatomic, strong, readonly) NSArray                                     *sectionControllers;

/**
 *  Call this method instead of reloadData on the tableView.  Pass it an array of objects that conform to SDTableViewSectionDelegate
 *
 *  @param sectionControllers Array of SDTableViewSectionDelegates
 *  @param animated YES if the table should reload with animations (currently unimplemented) or NO if a standard reloadData should occur (implemented)
 */
- (void)reloadWithSectionControllers:(NSArray *)sectionControllers animated:(BOOL)animated;

/**
 *  Asks the section controller's delegate to push this view controller.  Use this method
 *  to push the view controller instead of trying to push it yourself
 *
 *  @param viewController UIViewController to push
 *  @param animated       YES if should be animated
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  Asks the section controller's delegate to present this view controller.  Use this method
 *  to present the view controller instead of trying to present it yourself
 *
 *  @param viewController UIViewController to present
 *  @param animated       YES if should be animated
 *  @param completion     completion block to call when done
 */
- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  Asks the section controller's delegate to dismiss the currently presented view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated   YES if should be animated
 *  @param completion completion block to call when done
 */
- (void)dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion;

/**
 *  Asks the section controller's delegate to dismiss the currently pushed view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated YES if should be animated
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 *  Asks the section controller's delegate to pop to the root view controller.  Use this method
 *  instead of trying to present it yourself
 *
 *  @param animated YES if should be animated
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 *  Returns the index of the given section controller
 *
 *  @param id<SDTableViewSectionDelegate> object
 *
 *  @return NSUInteger
 */
- (NSUInteger)indexOfSection:(id<SDTableViewSectionDelegate>)section;

/**
 *  Returns a section controller for the given identifier
 *
 *  @param identifier Unique identifier for a section
 *
 *  @return Object confirming to SDTableViewSectionDelegate
 */
- (id<SDTableViewSectionDelegate>)sectionWithIdentifier:(NSString *)identifier;

/**
 *  Returns the height of all sections above the given section
 *
 *  @param section   Calculate the height of sections above this section
 *  @param maxHeight Maximum height to calculate. Pass SECTIONCONTROLLER_MAX_HEIGHT to calculate the total height of all sections above this section
 *
 *  @return The height of the sections above the given section
 */
- (CGFloat)heightAboveSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight;

/**
 *  Returns the height of all sections below the given section
 *
 *  @param section   Calculate the height of sections below this section
 *  @param maxHeight Maximum height to calculate. Pass SECTIONCONTROLLER_MAX_HEIGHT to calculate the total height of all sections below this section
 *
 *  @return The height of the sections below the given section
 */
- (CGFloat)heightBelowSection:(id<SDTableViewSectionDelegate>)section maxHeight:(CGFloat)maxHeight;

/**
 *  Add the section to the table view section controller's list of sections and to the table view
 *
 *  @param section The section object to add
 */
- (void)addSection:(id<SDTableViewSectionDelegate>)section;

/**
 *  Removes the section from the table view section controller's list of sections and from the table view
 *
 *  @param section The section object to remove
 */
- (void)removeSection:(id<SDTableViewSectionDelegate>)section;

/**
 *  Reloads a section controller for the given identifier
 *
 *  @param identifier Unique identifier for a section
 *  @param animation  UITableViewRowAnimation for a section's row(s)
 */
- (void)reloadSectionWithIdentifier:(NSString *)identifier withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *
 * Attemps to refresh the heights of the cells of the table view
 *
 */
- (void)refreshCellHeights;
@end

