//
//  NSURLCache+SDExtensions.h
//  SetDirection
//
//  Created by Stephen Elliott on 07/25/2013.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (SDExtensions)

/**
 Returns `YES` if the request contains a RFC1738-compliant, valid URL (non-empty). Returns `NO` otherwise.
 */
- (BOOL) isValid;

@end
