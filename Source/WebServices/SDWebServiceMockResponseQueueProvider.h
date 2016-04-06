//
//  SDWebServiceMockResponseQueueProvider.h
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebServiceMockResponseProvider.h"

/**
 Default implementation of SDWebServiceMockResponseProvider for SDWebService.  
 
 Defaults to returning response data in FIFO manner, but also allows tester to 
 explicitly control when responses are popped from the queue.
 */
@interface SDWebServiceMockResponseQueueProvider : NSObject<SDWebServiceMockResponseProvider>

/**
 Enables/Disables auto-popping of the mocks stack.  The default value is YES.
 */
@property (atomic, assign) BOOL autoPopMocks;

/**
 Push mock data onto the stack.  These are accessed sequentially.  Each service call
 will use index 0.  If autoPopMocks is enabled, they'll be automatically pulled off
 of the stack as tey are accessed.  If autoPopMocks is disabled, one needs to manually
 call popMockResponseFile as appropriate.
 */
- (void)pushMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle;

/**
 Adds several mock response files at once.
 */
- (void)pushMockResponseFiles:(NSArray *)filenames bundle:(NSBundle *)bundle;

/**
 Pops the index 0 mock off of the stack.
 */
- (void)popMockResponseFile;

/**
 Removes all mock files from the stack
 */
- (void)removeAllMockResponseFiles;

@end
