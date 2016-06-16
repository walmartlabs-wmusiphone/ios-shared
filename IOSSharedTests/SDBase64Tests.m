//
//  SDBase64Tests.m
//  ios-shared
//
//  Created by Brandon Sneed on 2/11/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDBase64.h"

@interface SDBase64Tests : XCTestCase
@property (nonatomic, copy) NSData *blahblahblahData;
@property (nonatomic, copy) NSString *blahblahblahString;
@property (nonatomic, copy) NSString *blahblahblahEncodedString;
@property (nonatomic, copy) NSData *emailData;
@property (nonatomic, copy) NSString *emailString;
@property (nonatomic, copy) NSString *emailEncodedString;
@end

@implementation SDBase64Tests

- (void)setUp
{
    [super setUp];
    
    self.blahblahblahString = @"blahblahblahh hf hehuh dfsj hh !7!&^&^!&@& u@ @ @@U @HUH@UH@ HU@ja hhshs jsh";
    self.blahblahblahData = [self.blahblahblahString dataUsingEncoding:NSUTF8StringEncoding];
    self.blahblahblahEncodedString = @"YmxhaGJsYWhibGFoaCBoZiBoZWh1aCBkZnNqIGhoICE3ISZeJl4hJkAmIHVAIEAgQEBVIEBIVUhAVUhAIEhVQGphIGhoc2hzIGpzaA==";
    
    self.emailString = @"someEmailAddress2015&&@walmart.com";
    self.emailData = [self.emailString dataUsingEncoding:NSUTF8StringEncoding];
    self.emailEncodedString = @"c29tZUVtYWlsQWRkcmVzczIwMTUmJkB3YWxtYXJ0LmNvbQ==";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicStringEncodeDecode
{
    NSString *dummyString = @"blahblahblah";
    NSString *base64String = [dummyString encodeToBase64String];
    
    XCTAssertNotEqualObjects(base64String,dummyString, @"The strings should not match!");
    
    NSString *decodedString = [base64String decodeBase64ToString];
    XCTAssertEqualObjects(decodedString ,dummyString, @"The strings should match!");
}

// Test the NSData APIs

- (void)testDataEncodeToBase64DataBlah
{
    NSData *base64EncodedBlah = [self.blahblahblahData encodeToBase64Data];
    NSString *base64String = [[NSString alloc] initWithData:base64EncodedBlah encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(base64String, self.blahblahblahEncodedString, @"Strings do not match");
}

- (void)testDataEncodeToBase64DataEmail
{
    NSData *base64EncodedEmail = [self.emailData encodeToBase64Data];
    NSString *base64String = [[NSString alloc] initWithData:base64EncodedEmail encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(base64String, self.emailEncodedString, @"Strings do not match");
}

- (void)testDataDecodeBase64ToDataBlah
{
    NSData *endodedData = [self.blahblahblahEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decodedData = [endodedData decodeBase64ToData];
    
    XCTAssertEqualObjects(decodedData, self.blahblahblahData, @"The decoded data does not match the original data");
}

- (void)testDataDecodeBase64ToDataEmail
{
    NSData *endodedData = [self.emailEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decodedData = [endodedData decodeBase64ToData];
    
    XCTAssertEqualObjects(decodedData, self.emailData, @"The decoded data does not match the original data");
}

- (void)testDataEncodeToBase64StringBlah
{
    NSString *encodedString = [self.blahblahblahData encodeToBase64String];
    
    XCTAssertEqualObjects(encodedString, self.blahblahblahEncodedString, @"The encoded strings do not match");
}

- (void)testDataEncodeToBase64StringEmail
{
    NSString *encodedString = [self.emailData encodeToBase64String];
    
    XCTAssertEqualObjects(encodedString, self.emailEncodedString, @"The encoded strings do not match");
}

- (void)testDataDecodeBase64ToStringBlah
{
    NSData *endodedData = [self.blahblahblahEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodedString = [endodedData decodeBase64ToString];
    
    XCTAssertEqualObjects(decodedString, self.blahblahblahString, @"The decoded strings do not match");
}

- (void)testDataDecodeBase64ToStringEmail
{
    NSData *endodedData = [self.emailEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodedString = [endodedData decodeBase64ToString];
    
    XCTAssertEqualObjects(decodedString, self.emailString, @"The decoded strings do not match");
}

// Test the NSString APIs

- (void)testStringEncodeToBase64DataBlah
{
    NSData *encodedTestData = [self.blahblahblahString encodeToBase64Data];
    NSData *encodedData = [self.blahblahblahEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(encodedData, encodedTestData, @"The encoded data do not match");
}

- (void)testStringEncodeToBase64DataEmail
{
    NSData *encodedTestData = [self.emailString encodeToBase64Data];
    NSData *encodedData = [self.emailEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(encodedData, encodedTestData, @"The encoded data do not match");
}

- (void)testStringDecodeBase64ToDataBlah
{
    NSData *decodedData = [self.blahblahblahEncodedString decodeBase64ToData];
    
    XCTAssertEqualObjects(decodedData, self.blahblahblahData, @"The decoded data do not match");
}

- (void)testStringDecodeBase64ToDataEmail
{
    NSData *decodedData = [self.emailEncodedString decodeBase64ToData];
    
    XCTAssertEqualObjects(decodedData, self.emailData, @"the decoded data do not match");
}

- (void)testStringEncodeToBase64StringBlah
{
    NSString *encodedString = [self.blahblahblahString encodeToBase64String];
    
    XCTAssertEqualObjects(encodedString, self.blahblahblahEncodedString, @"The encoded strings do not match");
}

- (void)testStringEncodeToBase64StringEmail
{
    NSString *encodedString = [self.emailString encodeToBase64String];
    
    XCTAssertEqualObjects(encodedString, self.emailEncodedString, @"The encoded strings do not match");
}

- (void)testStringDecodeBase64ToStringBlah
{
    NSString *decodedString = [self.blahblahblahEncodedString decodeBase64ToString];
    
    XCTAssertEqualObjects(decodedString, self.blahblahblahString, @"The decoded strings do not match");
}

- (void)testStringDecodeBase64ToStringEmail
{
    NSString *decodedString = [self.emailEncodedString decodeBase64ToString];
    
    XCTAssertEqualObjects(decodedString, self.emailString, @"The decoded strings do not match");
}

@end
