//
//  SDPickerModalViewController.m
//  SetDirection
//
//  Created by brandon on 4/29/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "SDPickerModalViewController.h"
#import "UIDevice+machine.h"

@interface SDPickerModalViewController ()

@property (strong, nonatomic) IBOutlet UIView *pickerContainer;

@end

@implementation SDPickerModalViewController

@synthesize pickerView;

- (id)init
{
    if ([UIDevice bcdSystemVersion] >= 0x070000)
        self = [super initWithNibName:@"SDPickerModalViewController-iOS7" bundle:[NSBundle bundleForClass:self.class]];
    else
        self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        __attribute__((unused)) UIView *loadedView = [self view];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel
{
    [self presentModallyFromViewController:controller onDone:done onCancel:cancel withSelectedRow:-1 inComponent:-1];
}

- (void)presentModallyFromViewController:(UIViewController *)controller onDone:(SDPickerBlock)done onCancel:(SDPickerBlock)cancel withSelectedRow:(NSInteger)row inComponent:(NSInteger)component
{
    doneBlock = [done copy];
    cancelBlock = [cancel copy];
    
    backgroundView.alpha = 0;
    
    UIWindow *window = controller.view.window;
    
	CGFloat stateBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	
    CGRect mainFrame = self.view.frame;
    mainFrame.size.width = window.bounds.size.width;
	mainFrame.size.height = window.bounds.size.height - stateBarHeight;
    mainFrame.origin.y = stateBarHeight;
    self.view.frame = mainFrame;
    
    CGRect containerFrame = self.pickerContainer.frame;
    CGRect containerStartFrame = containerFrame;
    containerFrame.origin.y = mainFrame.size.height;
    self.pickerContainer.frame = containerFrame;
        
    [window addSubview:self.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    backgroundView.alpha = 0.7;
    self.pickerContainer.frame = containerStartFrame;
    
    [UIView commitAnimations];
    
    // Default to a selected row in component
    if ( (row > -1) && (component > -1) ) {
        [pickerView selectRow:(NSInteger)row inComponent:component animated:NO];
    }
}

- (void)dismiss
{
    CGRect containerFrame = self.pickerContainer.frame;
    containerFrame.origin.y = [[UIScreen mainScreen] bounds].size.height;

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        backgroundView.alpha = 0.0;
        self.pickerContainer.frame = containerFrame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(id)sender
{
    cancelBlock();
    [self dismiss];
}

- (IBAction)doneAction:(id)sender
{
    doneBlock();
    [self dismiss];
}

@end
