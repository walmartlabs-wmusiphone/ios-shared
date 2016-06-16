//
//  UIImageViewTests.m
//  ios-shared
//
//  Created by Brandon Sneed on 7/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIImageView+SDExtensions.h"
#import "NSRunLoop+SDExtensions.h"
#import "SDImageCache.h"

@interface UIImageViewTests : XCTestCase
@end

@implementation UIImageViewTests
{
    UIImageView *_imageView;
    NSTimeInterval _runLoopWait;
}

- (void)setUp
{
    [super setUp];

    // Set-up code here.
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _runLoopWait = 10;

    // make sure we don't have any stored images initially.
    [[SDImageCache sharedInstance] flushCache];
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testGoodImageURL
{
    NSURL *imageURL = [NSURL URLWithString:@"http://www.google.com/images/srpr/logo4w.png"];
    __block BOOL blockWasCalled = NO;
    __block NSError *outputError = nil;

    [_imageView setImageWithURL:imageURL placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        blockWasCalled = YES;
        outputError = error;
    }];

    [[NSRunLoop mainRunLoop] runBlock:^(BOOL *stop) {
        if (blockWasCalled)
            *stop = YES;
    } interval:0.1 untilDate:[NSDate dateWithTimeIntervalSinceNow:120]];

    XCTAssertTrue(blockWasCalled == YES, @"The block was not called.");
    XCTAssertTrue(_imageView.image != nil, @"The image was not downloaded.");
    XCTAssertTrue(outputError == nil, @"outputError is not nil bitches.");

    _imageView.image = nil;
}

- (void)testBadImageURL
{
    NSURL *imageURL = [NSURL URLWithString:@"http://www.google.com/imageslksjdflksdjf/srpr/logo4w.png"];
    __block BOOL blockWasCalled = NO;
    __block NSError *outputError = nil;

    [_imageView setImageWithURL:imageURL placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        blockWasCalled = YES;
        outputError = error;
    }];

    [[NSRunLoop mainRunLoop] runBlock:^(BOOL *stop) {
        if (blockWasCalled)
            *stop = YES;
    } interval:0.1 untilDate:[NSDate dateWithTimeIntervalSinceNow:120]];


    XCTAssertTrue(blockWasCalled == YES, @"The block was not called.");
    XCTAssertTrue([outputError.domain isEqualToString:SDImageViewErrorDomain], @"The error domain isn't correct.");
    XCTAssertTrue(outputError.code == SDImageViewErrorConnectionError, @"The error code should be SDImageViewErrorConnectionError.");
    XCTAssertTrue(_imageView.image == nil, @"This test was designed to fail, there should be no image set, yet there is.");

    _imageView.image = nil;
}

- (void)testReallyBadImageURL
{
    NSURL *imageURL = [NSURL URLWithString:@"http"];
    __block BOOL blockWasCalled = NO;
    __block NSError *outputError = nil;

    [_imageView setImageWithURL:imageURL placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        blockWasCalled = YES;
        outputError = error;
    }];

    [[NSRunLoop mainRunLoop] runBlock:^(BOOL *stop) {
        if (blockWasCalled)
            *stop = YES;
    } interval:0.1 untilDate:[NSDate dateWithTimeIntervalSinceNow:120]];

    XCTAssertTrue(blockWasCalled == YES, @"The block was not called.");
    XCTAssertTrue([outputError.domain isEqualToString:SDImageViewErrorDomain], @"The error domain isn't correct.");
    XCTAssertTrue(outputError.code == SDImageViewErrorConnectionError, @"The error code should be SDImageViewErrorConnectionError.");
    XCTAssertTrue(_imageView.image == nil, @"This test was designed to fail, there should be no image set, yet there is.");

    _imageView.image = nil;
}

- (void)testReallyReallyBadImageURL
{
    // we assume setting the a nil url is expected and not necessarily an error.
    NSURL *imageURL = nil;
    __block BOOL blockWasCalled = NO;
    __block NSError *outputError = nil;

    [_imageView setImageWithURL:imageURL placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        blockWasCalled = YES;
        outputError = error;
    }];

    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_runLoopWait]];

    XCTAssertTrue(blockWasCalled == YES, @"The block was not called.");
    XCTAssertTrue(outputError == nil, @"The output error should be nil.");
    XCTAssertTrue(_imageView.image == nil, @"This test was designed to fail, there should be no image set, yet there is.");

    _imageView.image = nil;
}

- (void)testImageViewReuse
{
    // make sure our cache is cleared.
    [[SDImageCache sharedInstance] flushCache];

    NSURL *imageURL = [NSURL URLWithString:@"http://www.google.com/images/srpr/logo4w.png"];
    __block BOOL firstBlockWasCalled = NO;
    __block NSError *firstOutputError = nil;

    [_imageView setImageWithURL:imageURL placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        firstBlockWasCalled = YES;
        firstOutputError = error;
    }];

    __block BOOL secondBlockWasCalled = NO;
    __block NSError *secondOutputError = nil;

    [_imageView setImageWithURL:nil placeholderImage:nil completionBlock:^(UIImage *image, NSError *error) {
        secondBlockWasCalled = YES;
        secondOutputError = error;
    }];

    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_runLoopWait]];

    XCTAssertTrue(firstBlockWasCalled == YES, @"The first block was not called.");
    XCTAssertTrue([firstOutputError.domain isEqualToString:SDImageViewErrorDomain], @"The error domain isn't correct.");
    XCTAssertTrue(firstOutputError.code == SDImageViewErrorHasBeenReused, @"The error code should be SDImageViewErrorHasBeenReused.");

    XCTAssertTrue(secondBlockWasCalled == YES, @"The second block was not called.");
    XCTAssertTrue(secondOutputError == nil, @"The output error should be nil.");

    XCTAssertTrue(_imageView.image == nil, @"This test was designed to fail, there should be no image set, yet there is.");

    _imageView.image = nil;
}

@end
