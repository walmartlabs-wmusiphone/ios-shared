//
//  SDTimer.m
//  TrackingApiClient
//
//  Created by Brandon Sneed on 4/10/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDTimer.h"

@implementation SDTimer

+ (SDTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock
{
    SDTimer *timer = [[SDTimer alloc] initWithInterval:interval repeats:repeats timerBlock:timerBlock];
    return timer;
}

- (id)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock
{
    self = [super init];
    if(self != nil)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        if (_timer)
        {
            __block SDTimer *blockSelf = self;
            uint64_t nanoInterval = interval * NSEC_PER_SEC;
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)nanoInterval), nanoInterval, 0);
            dispatch_source_set_event_handler(_timer, ^{
                timerBlock(blockSelf);
                if (!repeats)
                    [blockSelf invalidate];
            });
            dispatch_source_set_cancel_handler(_timer, ^{
                _timer = nil;
            });
            dispatch_resume(_timer);
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)invalidate
{
    if (_timer)
    {
        dispatch_suspend(_timer);
        dispatch_source_cancel(_timer);
    }
}

@end
