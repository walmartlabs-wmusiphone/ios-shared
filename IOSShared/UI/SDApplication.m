//
//  SDApplication.m
//
//  Created by Brandon Sneed on 1/6/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDApplication.h"
#import "SDTimer.h"
#import "NSObject+SDExtensions.h"

#pragma mark - SDWindowAction

@interface SDApplicationAction : NSObject

@property (nonatomic, assign) NSTimeInterval timerTimestamp;
@property (nonatomic, copy) NSObjectPerformBlock handlerBlock;
@property (nonatomic, weak) UIViewController *controller;

- (void)performActionBlock;

@end

@implementation SDApplicationAction

- (void)performActionBlock
{
    if (self.handlerBlock && self.controller)
    {
        // Reset our timestamp for the next time the timer executes.
        self.timerTimestamp = [NSDate timeIntervalSinceReferenceDate];
        NSObjectPerformBlock tempHandlerBlock = [self.handlerBlock copy];
        tempHandlerBlock();
    }
}

@end

#pragma mark - SDWindowTimeout

@interface SDApplicationTimeoutAction : SDApplicationAction

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

- (void)startTimeoutMonitor;
- (void)stopTimeoutMonitor;

@end


@implementation SDApplicationTimeoutAction
{
    NSTimer *_internalTimer;
}

- (void)startTimeoutMonitor
{
    [_internalTimer invalidate];
    /*_internalTimer = [[SDTimer alloc] initWithInterval:self.timeoutInterval repeats:YES timerBlock:^(SDTimer *aTimer) {
        // maybe i'm being paranoid by checking this, but oh well.
        if (aTimer == _internalTimer)
            [self performTimeoutBlock];
    }];*/
    
    self.timerTimestamp = [NSDate timeIntervalSinceReferenceDate];
    _internalTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInterval target:self selector:@selector(performActionBlock) userInfo:nil repeats:YES];
}

- (void)stopTimeoutMonitor
{
    [_internalTimer invalidate];
    _internalTimer = nil;
}

- (void)resetTimeoutMonitor
{
    [self stopTimeoutMonitor];
    [self startTimeoutMonitor];
}

- (void)handleOverdueTimer
{
    if (self.timerTimestamp && (self.timerTimestamp + self.timeoutInterval)<=[NSDate timeIntervalSinceReferenceDate])
    {
        // Time should have fired
        [self resetTimeoutMonitor];
        [self performActionBlock];
    }
}

- (void)checkForTimerReset
{
    // We only reset the timer if it wasn't already scheduled to fire
    // If it is overdue to fire, we do nothing, assuming that the run loop
    // preparing to fire will trigger in the near future.
    NSTimeInterval nowInterval = [NSDate timeIntervalSinceReferenceDate];
    if (self.timerTimestamp &&
        (self.timerTimestamp + self.timeoutInterval)>nowInterval &&     // This insures the timer isn't already past due.
        (nowInterval - self.timerTimestamp) > 1.0)                      // This insures that we don't reset the timer more frequently than every second
    {
        [self resetTimeoutMonitor];
    }
}

@end

#pragma mark - SDWindow implementation

@implementation SDApplication
{
    NSMutableArray *_timeoutHandlers;
    NSMutableArray *_backgroundHandlers;
}

+ (instancetype)sharedApplication
{
    return (SDApplication *)[super sharedApplication];
}

- (id)init
{
    self = [super init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    return self;
}

- (void)dealloc
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Idle Timeout Methods

- (void)addIdleTimeout:(NSTimeInterval)timeoutInterval controller:(UIViewController *)controller handlerBlock:(NSObjectPerformBlock)handlerBlock
{
    @synchronized(self)
    {
        if (!_timeoutHandlers)
            _timeoutHandlers = [NSMutableArray array];
        
        SDApplicationTimeoutAction *timeoutHandler = [[SDApplicationTimeoutAction alloc] init];
        timeoutHandler.timeoutInterval = timeoutInterval;
        timeoutHandler.controller = controller;
        timeoutHandler.handlerBlock = handlerBlock;
        
        [_timeoutHandlers addObject:timeoutHandler];
        [timeoutHandler startTimeoutMonitor];
    }
}

- (void)cleanupIdleTimers
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=nil"];
        NSArray *itemsToRemove = [_timeoutHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
        {
            [_timeoutHandlers removeObjectsInArray:itemsToRemove];
            [itemsToRemove makeObjectsPerformSelector:@selector(stopTimeoutMonitor)];
        }
    }
}

- (void)handleOverdueTimers
{
    // First let's clean up any that are no longer valid
    [self cleanupIdleTimers];
    [_timeoutHandlers makeObjectsPerformSelector:@selector(handleOverdueTimer)];
}

- (void)removeIdleTimeoutsForController:(UIViewController *)controller
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller==%@", controller];
        NSArray *itemsToRemove = [_timeoutHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
        {
            [_timeoutHandlers removeObjectsInArray:itemsToRemove];
            [itemsToRemove makeObjectsPerformSelector:@selector(stopTimeoutMonitor)];
        }
    }
}

- (void)checkForTimerResets:(UIEvent *)event
{
    if (_timeoutHandlers.count < 1)
        return;
    
    NSSet *touches = [event allTouches];
    if (touches.count < 1)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_timeoutHandlers makeObjectsPerformSelector:@selector(checkForTimerReset)];
    });
}

#pragma mark - Backgrounding Action methods

/*- (void)addActionOnBackgroundingController:(UIViewController *)controller actionBlock:(NSObjectPerformBlock)actionBlock
{
    @synchronized(self)
    {
        if (!_backgroundHandlers)
            _backgroundHandlers = [NSMutableArray array];
        
        SDApplicationAction *actionHandler = [[SDApplicationAction alloc] init];
        actionHandler.controller = controller;
        actionHandler.handlerBlock = actionBlock;
        
        [_backgroundHandlers addObject:actionHandler];
    }
}

- (void)removeBackgroundingsActionFor:(UIViewController *)controller
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=%@", controller];
        NSArray *itemsToRemove = [_backgroundHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
            [_backgroundHandlers removeObjectsInArray:itemsToRemove];
    }
}

- (void)cleanupBackgroundingActions
{
    @synchronized(self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"controller=nil"];
        NSArray *itemsToRemove = [_backgroundHandlers filteredArrayUsingPredicate:predicate];
        
        if (itemsToRemove.count > 0)
            [_backgroundHandlers removeObjectsInArray:itemsToRemove];
    }
}*/

#pragma mark - Overrides

- (void)sendEvent:(UIEvent *)event
{
    [self checkForTimerResets:event];
    
    [super sendEvent:event];
}

@end

#pragma mark - SDApplicationMain()

int SDApplicationMain(int argc, char *argv[], NSString *delegateClassName)
{
    return UIApplicationMain(argc, argv, @"SDApplication", delegateClassName);
}
