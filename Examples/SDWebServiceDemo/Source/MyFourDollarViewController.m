//
//  SDWebServiceDemo - MyFourDollarViewController.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyFourDollarViewController.h"

#import "MyFourDollarDetailViewController.h"
#import "MyFourDollarDrugList.h"
#import "MyFourDollarCategory.h"
#import "MyResponseError.h"
#import "MyServices.h"


@interface MyFourDollarViewController ()

@property (nonatomic, strong) NSArray<MyFourDollarCategory>* categories;

@end


@implementation MyFourDollarViewController

#pragma mark - Object lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString( @"$4 Prescriptions", "Navigation title '$4 Prescriptions'" );

    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return (NSInteger)self.categories.count;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* sCategoryCellIdentifier = @"categoryCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: sCategoryCellIdentifier
                                                            forIndexPath: indexPath];
    // Configure the cell.

    MyFourDollarCategory* categoryItem = (MyFourDollarCategory*)[self.categories objectAtIndex: (NSUInteger)indexPath.row];
    cell.textLabel.text = categoryItem.categoryName;
    
    return cell;
}

#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *)segue
                  sender: (id) sender
{
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

    if( [segue.identifier isEqualToString: @"itemDetail"] )
    {
        MyFourDollarDetailViewController* detailViewController = segue.destinationViewController;
        
        NSAssert( [detailViewController isKindOfClass: [MyFourDollarDetailViewController class]], @"%s prepareForSegue: %@", __PRETTY_FUNCTION__, detailViewController );
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        MyFourDollarCategory* categoryItem = (MyFourDollarCategory*)[self.categories objectAtIndex: (NSUInteger)indexPath.row];

        detailViewController.category = categoryItem;
    }
}

#pragma mark - Helpers

- (void) reloadData
{
    // Perform our Pharmacy service call here.
    
    @weakify( self );
    
    [[MyServices sharedInstance] fourDollarPrescriptionsWithDataProcessingBlock: [MyServices defaultJSONProcessingBlockForClass: [MyFourDollarDrugList class]]
                                                                  uiUpdateBlock: ^( id dataObject, NSError* error )
     {
         @strongify( self );
         
         if( [dataObject isKindOfClass: [MyResponseError class]] || error )
         {
             // Check to see if we received an error or a response error and process accordingly.
             // In this example, we display an alert that shows the failure's message.
             
             NSString* message = nil;
             if( dataObject )
             {
                 MyResponseError* responseError = dataObject;
                 message = responseError.message;
             }
             else if ( error.localizedFailureReason )
             {
                 message = error.localizedFailureReason;
             }
             else if( error.localizedDescription )
             {
                 message = error.localizedDescription;
             }
             
             [SDAlertView showAlertWithTitle: NSLocalizedString( @"Get $4 Prescriptions Failure", @"UIAlertView title 'Get $4 Prescriptions Failure'" )
                                     message: message];
         }
         else if( [dataObject isKindOfClass: [MyFourDollarDrugList class]] )
         {
             // If the response data object came back in the format we specificed, process accordingly and update our UI.
             
             MyFourDollarDrugList* fourDollarDrugList = dataObject;
             
             self.categories = fourDollarDrugList.drugCategoryList;
             
             [self.tableView reloadData];
         }
         else
         {
             // NB: With your specific service call, a nil return may be acceptable.
             // In this particular example, it means that something went wrong.
             
             NSAssert( NO, @"The service call didn't return a data response in an expected format; fix this either in your class or error model, or fix the service." );
         }
     }];
}

@end
