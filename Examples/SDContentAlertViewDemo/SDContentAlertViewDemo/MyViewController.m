//
//  MyViewController.m
//  SDContentAlertViewDemo
//
//  Created by Brandon Sneed on 11/4/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "MyViewController.h"
#import "SDContentAlertView.h"
#import "SDNumberTextField.h"

@interface MyViewController ()

@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Test uiappearance bits.
/*
 @property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
 @property (nonatomic, strong) UIColor *lineColor UI_APPEARANCE_SELECTOR;
 @property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
 @property (nonatomic, strong) UIColor *buttonTextColor UI_APPEARANCE_SELECTOR;
 @property (nonatomic, strong) UIColor *buttonSelectionColor UI_APPEARANCE_SELECTOR;
 @property (nonatomic, strong) UIColor *buttonSelectionTextColor UI_APPEARANCE_SELECTOR;
*/

    SDContentAlertView *appearance = [SDContentAlertView appearance];
    appearance.backgroundColor = [UIColor blueColor];
    appearance.lineColor = [UIColor blackColor];
    appearance.textColor = [UIColor yellowColor];
    appearance.buttonTextColor = [UIColor redColor];
    appearance.buttonSelectionColor = [UIColor purpleColor];
    appearance.buttonSelectionTextColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SDContentAlertView examples

- (IBAction)simpleAlertAction:(id)sender
{
    [SDContentAlertView showAlertWithTitle:@"Title" message:@"Message." cancelTitle:@"OK" completion:^(BOOL cancelled) {
        if (cancelled)
            NSLog(@"Cancel tapped.");
        else
            NSLog(@"OK tapped.");
    }];
}

- (IBAction)largeAlertAction:(id)sender
{
    [SDContentAlertView showAlertWithTitle:@"This is a really fucking long title, Son.  A title only it's mother would be proud of.  If she weren't living under a bridge in San Jose anyway."
                                   message:@"This is the message to end all messages.  A message so awesome that God descended from heaven just to say \"You're an example to messages everywhere.\""
                               cancelTitle:@"OK"
                                completion:^(BOOL cancelled) {
                                    if (cancelled)
                                        NSLog(@"Cancel tapped.");
                                    else
                                        NSLog(@"OK tapped.");
                                }];
}

- (IBAction)twoButtonAlertAction:(id)sender
{
    [SDContentAlertView showAlertWithTitle:@"Title" message:@"Message" cancelTitle:@"Cancel" otherTitle:@"OK" completion:^(BOOL cancelled) {
        if (cancelled)
            NSLog(@"Cancel tapped.");
        else
            NSLog(@"OK tapped.");
    }];
}

- (IBAction)alertWithContentAction:(id)sender
{
    SDNumberTextField *textField = [[SDNumberTextField alloc] initWithFrame:CGRectMake(0, 0, 124, 30)];
    textField.disableFloatingLabels = YES;
    textField.format = @"##/##/####";
    textField.placeholder = @"MM/DD/YYYY";
    textField.borderStyle = UITextBorderStyleRoundedRect;

    [SDContentAlertView showAlertWithTitle:@"DOB Entry" message:@"Enter y0 birfdate" cancelTitle:@"Cancel" otherTitle:@"OK" contentView:textField completion:^(BOOL cancelled) {
        if (cancelled)
            NSLog(@"Cancel tapped.");
        else
        {
            NSLog(@"OK tapped.\nTextfield formatted text = %@\nTextfield unformatted text = %@", textField.text, textField.unformattedText);
        }
    }];
}

- (IBAction)stackedAlertAction:(id)sender
{
    for (NSInteger i = 1; i <= 5; i++)
        [SDContentAlertView showAlertWithTitle:[NSString stringWithFormat:@"Title %i", i] message:@"Message" cancelTitle:@"OK" completion:nil];
}

#pragma mark - UIAlertView examples

- (IBAction)uiAlertViewAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Title"
                                                        message:@"Message"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (IBAction)largeUIAlertViewAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a really fucking long title, Son.  A title only it's mother would be proud of.  If she weren't living under a bridge in San Jose anyway."
                                                        message:@"This is the message to end all messages.  A message so awesome that God descended from heaven just to say \"You're an example to messages everywhere.\""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (IBAction)stackedUIAlertViewAction:(id)sender
{
    for (NSInteger i = 1; i <= 5; i++)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Title %i", i]
                                                            message:@"Message"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

@end
