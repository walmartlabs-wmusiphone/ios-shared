//
//  SDExpandingTableViewController.h
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.

#import <UIKit/UIKit.h>

/**
 *  A column in an SDExpandingTableView needs an way to uniquely identify itself.  Any item that you want to use as a column 
 *  (be it a string or a custom model object) should implement this protocol.
 */
@protocol SDExpandingTableViewColumnDelegate <NSObject>
@required
/**
 *  @return An unique ID for this column
 */
- (NSString *)identifier;

/**
 *  @return A display name for this column
 */
- (NSString *)displayName;

@end

/**
 *  Datasource to provide cells and table specifics to SDExpandingTableViewController
 */
@protocol SDExpandingTableViewControllerDataSource<NSObject>
@required
/**
 *  Returns a cell for the given index path, in the given column.
 *
 *  @param indexPath The indexpath of the requested cell
 *  @param column    the column of the requested cell
 *  @param tableView The tableView where the cell will live (allows user to call dequeueCell on the tableView)
 *
 *  @return A cell for the given location
 */
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;;

/**
 *  Returns the # of rows in a section of a column
 *
 *  @param column    the column of the section
 *  @param section   the section
 *
 *  @return the number of rows in the given section
 */
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;

/**
 *  Returns the # of sections in the given column
 */
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;

/**
 *  returns a SDExpandingTableViewColumnDelegate that represents the "root" of the data hierarchy.
 */
- (id<SDExpandingTableViewColumnDelegate>)rootColumnIdentifier;
@end

/**
 *  A delegate to respond to some UI interactions
 */
@protocol SDExpandingTableViewControllerDelegate<NSObject>
@required
/**
 *  Called when a user taps on a cell in a column
 *
 *  @param indexPath The indexPath of the cell
 *  @param column    The column of the cell
 *  @param tableView The tableView comes along for the ride in case the user needs to get the selected cell.
 */
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;

/**
 *  Called when the popover is dismissed
 */
- (void)didDismissExpandingTables;

@optional
/**
 *  called before a new tableview is added.  Gives the client a chance to set up the table by doing things like register a cell's xib or class
 *
 *  @param tableView the tableView that will be added
 *  @param column    The column of the tableview.
 */
- (void)setupTableView:(UITableView *)tableView forColumn:(id<SDExpandingTableViewColumnDelegate>)column;
@end

/**
 *  SDExpandingTableViewController
 *  A VC that helps represent a taxonomy or hierarchy of data by expanding it's size and adding a new tableview as the user "drills down"
 *
 *  The data and cells are provided by the dataSource and some UI callbacks are handled by the delegate.  Either of these protocols could be
 *  expanded to have more of the UITableViewDataSoure or UITableViewDelegate protocols methods.  Currently only the bare minimum are included.
 *
 *  Generally this VC should be presented in a popover, though that is not required.  To navigate around the data use navigateToColumn:fromParentColumn:animated
 *  More than likely the client will call this in the implementation of the delegate method didSelectRowAtIndexPath:inColumn:forTableView:
 *
 *  Are this point the VC is not smart enough to keep all its content on the screen. So if your data is too deep please add that feature :)
 */
@interface SDExpandingTableViewController : UIViewController

/**
 *  The datasource to provide the cells and data to the controller
 */
@property (nonatomic, weak) id<SDExpandingTableViewControllerDataSource> dataSource;

/**
 *  delegate to respond to and make UI calls
 */
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> delegate;

/**
 *  The size for each tableView
 */
@property (nonatomic, assign) CGSize tableViewSize;

/**
 *  The padding, if any, between all the tables and self.view (note, this is not the padding between each tableView)
 */
@property (nonatomic, assign) UIEdgeInsets tableContainerPaddingInsets;

/**
 *  The padding, if any, between 2 tableviews
 */
@property (nonatomic, assign) CGFloat tableViewHorizontalPadding;

/**
 *  The max size that the view can grow in both portrait
 */
@property (nonatomic, assign) CGSize maxSizePortrait;

/**
 *  The max size that the view can grow in both landscape
 */
@property (nonatomic, assign) CGSize maxSizeLandscape;

/**
 *  The background color for the selected column
 */
@property (nonatomic, strong) UIColor *selectedColumnColor;

/**
 *  The background color of a nonselected column
 */
@property (nonatomic, strong) UIColor *nonselectedColumnColor;

/**
 *  Creates a new SDExpandingTableViewController
 *
 *  @param tableStyle The table style, plain or group
 *
 *  @return The new controller
 */
- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableStyle;

/**
 *  A client will call this to move from the current location in the data to a new location.  The parent must also be provided so 
 *  we can determine where in the hierarchy the new column lives.  We may be popping off tableviews, or we may just be added them.
 *
 *  @param column   The id of the column that you want to navigate to
 *  @param parent   The id of the parent column (or nil if this is root)
 *  @param animated Whether or not to animate the navigation
 */
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;

/**
 *  Presents the VC in a popover at the given rect
 *
 *  @param rect            where to present the popover
 *  @param view            the view to present the popover
 *  @param arrowDirections allowed arrow directions of popover
 *  @param animated        whether or not to animate
 */
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

/**
 *  Presents the VC in a popover from the given barbutton
 *
 *  @param item            The barbutton item from which to display the popup
 *  @param arrowDirections allowed arrow directions of the popover
 *  @param animated        whether or not to animate
 */
- (void)presentFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

/**
 *  Dismissed the popover
 *
 *  @param animated whether or not to animate
 */
- (void)dismissAnimated:(BOOL)animated;;

@end
