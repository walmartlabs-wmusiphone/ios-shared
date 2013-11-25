//
//  SDWebServiceDemo - MyViewController.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "MyViewController.h"

#import "MyFourDollarViewController.h"


@implementation MyViewController

#pragma mark - Actions

- (IBAction) fourDollarPrescriptionsAction: (id) sender
{
    MyFourDollarViewController* fourDollarController = [MyFourDollarViewController loadFromStoryboard];
    
    [self.navigationController pushViewController: fourDollarController
                                         animated: YES];
}

@end
