//
//  SDWebServiceDemoTests - SDWebServiceDemoTests.m
//
//  Created by Stephen Elliott on 2013/11/12.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "MyServices.h"
#import "MyFourDollarDrugList.h"
#import "MyResponseError.h"


@interface SDWebServiceDemoTests : SenTestCase

@property (nonatomic, assign) BOOL testIsRunning;
@property (nonatomic, copy) NSRunLoopWaitCompletionBlock serviceCompletion;

@end


@implementation SDWebServiceDemoTests

- (void) setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.testIsRunning = YES;
    
    @weakify( self );
    
    self.serviceCompletion = ^( BOOL *stop )
    {
        @strongify( self );
        
        *stop = !self.testIsRunning;
    };
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [super tearDown];
    
    self.testIsRunning = NO;
}

#pragma mark - Four Dollar Prescriptions Service Unit Tests

- (void) testFourDollarPrescriptions
{
    __block MyFourDollarDrugList* testPrescriptions = nil;
    __block MyResponseError* testError = nil;
    
    @weakify( self );

    [[MyServices sharedInstance] fourDollarPrescriptionsWithDataProcessingBlock: [MyServices defaultJSONProcessingBlockForClass: [MyFourDollarDrugList class]]
                                                                  uiUpdateBlock: ^( id dataObject, NSError* error )
    {
        @strongify( self );
        
        if( [dataObject isKindOfClass: [MyResponseError class]] )
        {
            testError = dataObject;
        }
        else
        {
            testPrescriptions = dataObject;
        }
        
        self.testIsRunning = NO;
    }];
    
    [[NSRunLoop mainRunLoop] runBlock: ^( BOOL *stop )
    {
        *stop = !self.testIsRunning;
    }
                             interval: 0.2
                            untilDate: [NSDate dateWithTimeIntervalSinceNow: 120.0]]; // 120 second timeout for services
    
    STAssertFalse( self.testIsRunning, @"The completion block for %s was never called", __PRETTY_FUNCTION__ );
    STAssertFalse( testError, @"There was a service error: %@ %@", testError.error, testError.message );
    STAssertTrue( testPrescriptions, @"There was no prescriptions response" );
    STAssertFalse( testPrescriptions.drugCategoryList.count == 0, @"There were no drug categories in the response" );
}

@end
