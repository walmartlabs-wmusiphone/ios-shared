//
//  SDWebServiceMockResponseQueueProvider.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWebServiceMockResponseQueueProvider.h"
#import "SDLog.h"

@implementation SDWebServiceMockResponseQueueProvider {
    // always access the mutable array inside of @synchronized(self)
    NSMutableArray *_mockStack;
}

- (instancetype) init
{
    if ((self = [super init]))
    {
        _autoPopMocks = YES;
        _mockStack = [NSMutableArray array];
    }
    return self;
}

- (NSData *)getMockResponseForRequest:(NSURLRequest *)request
{
    @synchronized(self)
    {
        if (_mockStack.count == 0)
        {
            return nil;
        }

        NSData *result = [_mockStack objectAtIndex:0];
        if (self.autoPopMocks)
        {
            [self popMockResponseFile];
        }
        
        return result;
    }
}

- (void)pushMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle
{
    @synchronized(self)
    {
        // remove a any prepended paths in case they can't read the documentation.
        NSString *safeFilename = [filename lastPathComponent];
        NSString *finalPath = [bundle pathForResource:safeFilename ofType:nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *mockData = nil;

        if (finalPath && [fileManager fileExistsAtPath:finalPath])
        {
            SDLog(@"*** Using mock data file '%@'", safeFilename);
            mockData = [NSData dataWithContentsOfFile:finalPath];
        }
        else
            SDLog(@"*** Unable to find mock file '%@'", safeFilename);

        if (mockData)
        {
            [_mockStack addObject:mockData];
        }
    }
}

- (void)pushMockResponseFiles:(NSArray *)filenames bundle:(NSBundle *)bundle
{
    @synchronized(self)
    {
        for (NSUInteger index = 0; index < filenames.count; index++)
        {
            id object = [filenames objectAtIndex:index];
            if (object && [object isKindOfClass:[NSString class]])
            {
                NSString *filename = object;

                // remove a any prepended paths in case they can't read the documentation.
                NSString *safeFilename = [filename lastPathComponent];
                NSString *finalPath = [bundle pathForResource:safeFilename ofType:nil];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSData *mockData = nil;

                if (finalPath && [fileManager fileExistsAtPath:finalPath])
                {
                    SDLog(@"*** Using mock data file '%@'", safeFilename);
                    mockData = [NSData dataWithContentsOfFile:finalPath];
                }
                else
                    SDLog(@"*** Unable to find mock file '%@'", safeFilename);

                if (mockData)
                {
                    [_mockStack addObject:mockData];
                }
            }
        }
    }
}

- (void)popMockResponseFile
{
    @synchronized(self)
    {
        if (_mockStack.count > 0)
        {
            [_mockStack removeObjectAtIndex:0];
        }
    }
}

- (void)removeAllMockResponseFiles
{
    if (_mockStack.count > 0) {
        [_mockStack removeAllObjects];
    }
}

@end
