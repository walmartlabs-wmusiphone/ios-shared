//
//  SDWebViewCell.h
//  SetDirection
//
//  Created by Sam Grover on 2/27/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A UITableView subclass to display a varying height UIWebView and associated title label inside a table cell.
 */

@interface SDWebViewCell : UITableViewCell {
	UILabel *titleLabel;
	UIWebView *webView;
	CGFloat webViewHeight;
}

/**
 The title for the cell content.
 */
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

/**
 The web view into which to load the web content.
 */
@property (nonatomic, strong) IBOutlet UIWebView *webView;

/**
 It's the responsibility of the VC that manages this cell to set the height after it loads the HTML.
 */
@property (nonatomic, assign) CGFloat webViewHeight;

@end
