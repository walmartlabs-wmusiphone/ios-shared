//
//  NSURLCache+SDExtensions.m
//  SetDirection
//
//  Created by Stephen Elliott on 07/25/2013.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "NSURLRequest+SDExtensions.h"


@implementation NSURLRequest(SDExtensions)

// Returns `YES` if the request contains a RFC1738-compliant, valid URL (non-empty).

- (BOOL) isValid
{
    BOOL returnValue = NO;
    
    NSString* urlValidationExpression = @"http(s)?://([\\w-]+\\.)+[\\w-(:)]+(/[\\w-\\+ ./?%&amp;=]*)?";
    NSPredicate* urlValidator = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", urlValidationExpression];
    
    if (self.URL.absoluteString.length > 0  && [urlValidator evaluateWithObject: self.URL.absoluteString])
    {
        returnValue = YES;
    }
    
    return returnValue;
}

@end
