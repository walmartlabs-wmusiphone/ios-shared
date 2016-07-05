//
//  NSRunLoop+SDExtensions.m
//
//  Created by Brandon Sneed on 8/28/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "NSRunLoop+SDExtensions.h"

@implementation NSRunLoop (SDExtensions)

- (void)runBlock:(NSRunLoopWaitCompletionBlock)completion interval:(NSTimeInterval)interval untilDate:(NSDate *)timeoutDate
{
    BOOL stop = NO;
    NSTimeInterval giveUpInterval = [timeoutDate timeIntervalSinceReferenceDate];

    while (!stop && ([NSDate timeIntervalSinceReferenceDate] < giveUpInterval))
    {
        [self runUntilDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
        completion(&stop);
    }
}

@end
