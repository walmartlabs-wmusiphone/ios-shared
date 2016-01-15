//
//  SDCCTextField.h
//
//  Created by Michaël Villar on 03/20/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDCCTextField : UITextField

+ (NSString*)textByRemovingUselessSpacesFromString:(NSString*)string;

@end

@protocol SDCCTextFieldProtocol<NSObject>
- (void)ccTextFieldDidBackSpaceWhileTextIsEmpty:(SDCCTextField*)textField;
@end