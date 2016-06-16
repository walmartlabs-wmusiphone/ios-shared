//
//  SDWebServiceMockResponseMapProvider.m
//  ios-shared
//
//  Created by Douglas Sjoquist on 12/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDWebServiceMockResponseMapProvider.h"
#import "SDWebServiceMockResponseRequestMapping.h"

@interface SDWebServiceMockResponseRequestMappingEntry : NSObject
@property (nonatomic,strong) SDWebServiceMockResponseRequestMapping *requestMapping;
@property (nonatomic,copy) NSString *filename;
@property (nonatomic,strong) NSBundle *bundle;
@property (nonatomic,assign) NSUInteger maximumResponses;
@property (nonatomic,assign) NSUInteger matchCount;
@end

@implementation SDWebServiceMockResponseRequestMappingEntry

+ (SDWebServiceMockResponseRequestMappingEntry *) entryWithMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping withFilename:(NSString *)filename bundle:(NSBundle *) bundle maximumResponses:(NSUInteger) maximumResponses;
{
    SDWebServiceMockResponseRequestMappingEntry *result = [[SDWebServiceMockResponseRequestMappingEntry alloc] init];
    result.requestMapping = requestMapping;
    result.filename = filename;
    result.bundle = bundle;
    result.maximumResponses = maximumResponses;
    return result;
}

- (BOOL) matchesRequest:(NSURLRequest *) request;
{
    BOOL result = NO;
    if ([self.requestMapping matchesRequest:request])
    {
        self.matchCount += 1;
        result = (self.matchCount <= self.maximumResponses);
    }
    return result;
}

- (NSData *) data;
{
    NSString *path = [self.bundle pathForResource:self.filename ofType:nil];
    return [NSData dataWithContentsOfFile:path];
}

@end

@interface SDWebServiceMockResponseMapProvider()
@property (nonatomic,strong) NSMutableArray *requestMappings;
@end

@implementation SDWebServiceMockResponseMapProvider

- (instancetype) init
{
    if ((self = [super init]))
    {
        _requestMappings = [NSMutableArray array];
    }
    return self;
}

- (NSData *) getMockResponseForRequest:(NSURLRequest *)request
{
    NSData *result = nil;
    for (SDWebServiceMockResponseRequestMappingEntry *entry in self.requestMappings)
    {
        if ([entry matchesRequest:request])
        {
            result = entry.data;
            break;
        }
    }
    return result;
}

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping maximumResponses:(NSUInteger) maximumResponses
{
    SDWebServiceMockResponseRequestMappingEntry *entry = [SDWebServiceMockResponseRequestMappingEntry entryWithMapping:requestMapping withFilename:filename bundle:bundle maximumResponses:maximumResponses];
    [self.requestMappings addObject:entry];
}

- (void)addMockResponseFile:(NSString *)filename bundle:(NSBundle *)bundle forPath:(NSString *) path
{
    SDWebServiceMockResponseRequestMapping *requestMapping =
    [[SDWebServiceMockResponseRequestMapping alloc] initWithPath:path queryParameters:nil];
    [self addMockResponseFile:filename bundle:bundle forRequestMapping:requestMapping maximumResponses:NSIntegerMax];
}

- (void)removeMockResponseFileForRequestMapping:(SDWebServiceMockResponseRequestMapping *) requestMapping
{
    NSArray *requestMappings = [self.requestMappings copy];
    for (SDWebServiceMockResponseRequestMappingEntry *entry in requestMappings)
    {
        if ([entry.requestMapping isEqual:requestMapping])
        {
            [self.requestMappings removeObject:entry];
        }
    }
}

- (void)removeAllRequestMappings
{
    [self.requestMappings removeAllObjects];
}

@end
