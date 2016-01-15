//
//  NSRunLoop+SDExtensions.h
//  RxClient
//
//  Created by Brandon Sneed on 8/28/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSRunLoopWaitCompletionBlock)(BOOL *stop);

@interface NSRunLoop (SDExtensions)

/**
 *	Pumps the current runloop in at an interval with a final timeout.  The block can set stop=FALSE to
 *  exit sooner, thus avoiding the timeout.
 *
 *	@param	completion	The block to execute repeatedly.
 *	@param	interval	The interval at which to pump the current runloop.
 *	@param	timeoutDate	The point in the future when timeout should occur.
 */
- (void)runBlock:(NSRunLoopWaitCompletionBlock)completion interval:(NSTimeInterval)interval untilDate:(NSDate *)timeoutDate;

@end
