//
//  NSURL+SDExtensions.m
//  SetDirection
//
//  Created by Steven W. Riggins on 1/29/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "NSURL+SDExtensions.h"

@implementation NSURL (SDExtensions)

// from http://stackoverflow.com/questions/6309698/objective-c-how-to-add-query-parameter-to-nsurl
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
	
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
}

@end
