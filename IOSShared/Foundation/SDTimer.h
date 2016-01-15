//
//  SDTimer.h
//  TrackingApiClient
//
//  Created by Brandon Sneed on 4/10/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple block based timer.
 */

@class SDTimer;

typedef void (^SDTimerBlock)(SDTimer *aTimer);

@interface SDTimer : NSObject
{
    dispatch_source_t _timer;
}

/**
 Initialize and start a timer immediately based on the parameters.
 @param interval The interval after which the timer fires, in seconds.
 @param repeats Indicates if the timer should fire indefinitely until invalidated or only once.
 @param timerBlock The block to execute when the timer fires.
 */
- (id)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock;

/**
 Invalidate the receiver timer.
 */
- (void)invalidate;

/**
 Returns a `SDTimer` object that is created and started based on the parameters.
 @param interval The interval after which the timer fires, in seconds.
 @param repeats Indicates if the timer should fire indefinitely until invalidated or only once.
 @param timerBlock The block to execute when the timer fires.
 */
+ (SDTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock;

@end
