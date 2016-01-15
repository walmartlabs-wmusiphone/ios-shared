//
//  SDDataMapTests.m
//  ios-shared
//
//  Created by Brandon Sneed on 12/9/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+SDExtensions.h"
#import "NSObject+SDExtensions.h"
#import "NSData+SDExtensions.h"
#import "SDModelObject.h"
#import "RxRefillsModel.h"

#pragma mark - Test Support

@interface MyObject : SDModelObject

@property (nonatomic, strong) NSArray<NSString> *blah1;
@property (nonatomic, strong) NSString *blah2;
@property (nonatomic, strong) MyObject *blah3;
@property (nonatomic, strong) MyObject *blah4;
@property (nonatomic, strong) NSNumber *blah5;
@property (nonatomic, strong) NSDictionary *blah6;
@property (nonatomic, assign) NSInteger blah7;
@property (nonatomic, strong) NSString *subBlah8;
@property (nonatomic, assign) BOOL shouldBeInvalid;
@property (nonatomic, assign) BOOL transformed;
@end

@implementation MyObject

- (void)setBlah4:(id)data
{
    _blah4 = data;
}

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{
             @"blah1": sdmo_key(self.blah1),
             @"blah2": sdmo_key(self.blah2),
             @"blah7": sdmo_key(self.blah7),
             @"subBlah8": sdmo_selector(@selector(setSubBlah8:)),
             @"shouldBeInvalid": sdmo_key(self.shouldBeInvalid),
             @"transformed": sdmo_transformed_key(self.transformed, NSNegateBooleanTransformerName),
             };
}

- (BOOL)validModel
{
    if (self.shouldBeInvalid)
        return NO;
    return YES;
}

@end

#pragma mark - Tests

@interface SDDataMapTests : XCTestCase

@end

@implementation SDDataMapTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testKeyPathExists
{
    MyObject *dummyObject1 = [[MyObject alloc] init];
    MyObject *dummyObject2 = [[MyObject alloc] init];
    
    dummyObject1.blah3 = dummyObject2;
    
    XCTAssert([dummyObject1 keyPathExists:@"blah2"], @"it says blah2 doesn't exist and it does!");
    XCTAssert([dummyObject1 keyPathExists:@"blah3.blah2"], @"it says blah3.blah2 doesn't exist and it does!");
    XCTAssert(![dummyObject1 keyPathExists:@"blah3blah2"], @"it says blah3blah2 exists and it doesn't!");
}

- (void)testSDMOMacros
{
    MyObject *inputObject = [[MyObject alloc] init];
    inputObject.blah1 = (NSArray<NSString> *)@[@"blah1", @"blah2", @"blah3"];
    inputObject.blah2 = @"this is blah2";
    inputObject.blah3 = [[MyObject alloc] init];
    inputObject.blah7 = 1337;
    inputObject.subBlah8 = @"this is subBlah8";
    inputObject.transformed = NO;
    
    MyObject *outputObject = [[MyObject alloc] init];
    
    [[SDDataMap map] mapObject:inputObject toObject:outputObject];
    
    XCTAssertTrue(outputObject.blah1.count == 3, "outputObject.blah1 is supposed to have 3 items!");
    XCTAssertTrue([outputObject.blah2 isEqualToString:@"this is blah2"], "outputObject.blah1 is supposed to have 3 items!");
    XCTAssertTrue(outputObject.blah7 == 1337, "outputObject.blah7 has the wrong value!");
    XCTAssertTrue([outputObject.subBlah8 isEqualToString:@"this is subBlah8"], @"outputObject.subBlah8 isn't set right!");
    XCTAssert(outputObject.transformed == YES);
}

- (void)testBasicMappingNamesMatch
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @"correctValue"};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue([dummyObject.blah2 isEqualToString:@"correctValue"], @"dummyObject doesn't the correct value for blah2!");
}

- (void)testBasicMappingNamesDontMatch
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @"correctValue"};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"subBlah8"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue([dummyObject.subBlah8 isEqualToString:@"correctValue"], @"dummyObject doesn't the correct value for subBlah8!");
}

- (void)testTypeConversionNSStringToNSInteger
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah7" : @"1337"};
    
    NSDictionary *mappingDictionary = @{@"blah7" : @"blah7"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah7 == 1337), @"dummyObject doesn't have the correct value for blah7!");
}

- (void)testTypeConversionNSStringToNSNumber
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah5" : @"1337"};
    
    NSDictionary *mappingDictionary = @{@"blah5" : @"blah5"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah5.integerValue == 1337), @"dummyObject doesn't have the correct value for blah5!");
    XCTAssertTrue([dummyObject.blah5 isKindOfClass:[NSNumber class]], @"dummyObject.blah5 isn't an NSNumber!");
}

- (void)testTypeConversionNSNumberToNSString
{
    MyObject *dummyObject = [[MyObject alloc] init];
    NSDictionary *dummyDictionary = @{@"blah2" : @1337};
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue(([dummyObject.blah2 isEqualToString:@"1337"]), @"dummyObject doesn't have the correct value for blah2!");
    XCTAssertTrue([dummyObject.blah2 isKindOfClass:[NSString class]], @"dummyObject.blah2 isn't an NSString!");
}

- (void)testTypeConversionNSIntegerToNSString
{
    MyObject *dummyObject = [[MyObject alloc] init];
    dummyObject.blah7 = 1337;
    NSMutableDictionary *dummyDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{@"blah7" : @"blah7"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyObject toObject:dummyDictionary];
    
    id value = [dummyDictionary objectForKey:@"blah7"];
    XCTAssertTrue([value isKindOfClass:[NSNumber class]], @"value isn't an NSNumber!");
    XCTAssertTrue(([value integerValue] == 1337), @"value doesn't have the correct value for blah7!");
}

- (void)testTypeConversionToModelsArray
{
    MyObject *dummyObject = [[MyObject alloc] init];
    
    NSArray *blah1 = @[@1, @2, @3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<NSString>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    XCTAssertTrue((dummyObject.blah1.count == 3), @"dummyObject doesn't have 3 items like it should!");
    
    NSString *item = [dummyObject.blah1 objectAtIndex:1];
    XCTAssertTrue([item isKindOfClass:[NSString class]], @"blah1's sub items aren't of the NSString type!");
    XCTAssertTrue(item.integerValue == 2, @"item's value should be 2!");
}

- (void)testObjectArrayToDictionary
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    
    NSArray *blah1 = @[@"test1", @"test2", @"test3"];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<NSString>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
}

- (void)testDictionaryWithArrayToDictionaryWithModelObjects
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    NSDictionary *object1 = @{@"blah2": @"object1"};
    NSDictionary *object2 = @{@"blah2": @"object2"};
    NSDictionary *object3 = @{@"blah2": @"object3"};
    
    NSArray *blah1 = @[object1, object2, object3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<MyObject>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
    XCTAssertTrue([[output objectAtIndex:0] isKindOfClass:[MyObject class]], @"The items in the output array aren't of MyObject!");
}

- (void)testDictionaryWithArrayToDictionaryWithModelObjects_oldStyle
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    NSDictionary *object1 = @{@"blah2": @"object1"};
    NSDictionary *object2 = @{@"blah2": @"object2"};
    NSDictionary *object3 = @{@"blah2": @"object3"};
    
    NSArray *blah1 = @[object1, object2, object3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"<MyObject>blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 3), @"dummyObject doesn't have 3 items like it should!");
    XCTAssertTrue([[output objectAtIndex:0] isKindOfClass:[MyObject class]], @"The items in the output array aren't of MyObject!");
}

- (void)testModelObjectToDictionary
{
    MyObject *inputObject = [[MyObject alloc] init];
    inputObject.blah2 = @"output output.";
    
    NSMutableDictionary *outputObject = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{@"blah2" : @"<NSString>blah2"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputObject toObject:outputObject];
    
    NSString *output = (NSString *)[outputObject objectForKey:@"blah2"];
    XCTAssertTrue([output isEqualToString:@"output output."], @"dummyObject doesn't have 3 items like it should!");
}

- (void)testDictionaryToSelector
{
    NSDictionary *inputObject = @{@"blah2": @"hello"};
    
    MyObject *outputObject = [[MyObject alloc] init];
    
    NSDictionary *mappingDictionary = @{@"blah2" : sddm_selector(outputObject, @selector(setSubBlah8:))};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputObject toObject:outputObject];
    
    XCTAssertTrue([outputObject.subBlah8 isEqualToString:@"hello"], @"dummyObject doesn't have 3 items like it should!");
}

- (void)testModelsStaticImport
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"json1" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *fileDictionary = [fileData JSONDictionary];
    
    RxRefillsModel *refillsObject = [[RxRefillsModel alloc] init];
    [[SDDataMap map] mapObject:fileDictionary toObject:refillsObject];
    
    NSDictionary *dictionary = [refillsObject dictionaryRepresentation];
    NSLog(@"dictionary = %@", dictionary);
    
    XCTAssertTrue([refillsObject.patient.lastName isEqualToString:@"PHARMA2"], @"The patient field didn't get set properly!");
    XCTAssertTrue([((RxOrderModel *)[refillsObject.orders objectAtIndex:0]).drug isEqualToString:@"ALPRAZOLAM 0.5MG    TAB"], @"The orders array didn't get set properly!");
}

- (void)testModelsStaticImportAndExport
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"json1" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *fileDictionary = [fileData JSONDictionary];
    
    RxRefillsModel *refillsObject = [[RxRefillsModel alloc] init];
    [[SDDataMap map] mapObject:fileDictionary toObject:refillsObject];
    
    NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
    [[SDDataMap map] mapObject:refillsObject toObject:newDictionary];
    
    NSArray *rxFillItems = [newDictionary valueForKey:@"RxFill"];
    NSDictionary *patientNameDict = [newDictionary valueForKey:@"patientName"];
    NSString *lastName = [patientNameDict valueForKey:@"lastName"];
    NSDictionary *orderInfo = [rxFillItems objectAtIndex:0];
    NSString *order = [orderInfo valueForKey:@"drug"];
    
    XCTAssertTrue((rxFillItems.count == 6), @"RxFill in newDictionary doesn't have 6 items like it should!");
    XCTAssertTrue([lastName isEqualToString:@"PHARMA2"], @"patientName in newDictionary didn't come out properly!");
    XCTAssertTrue([order isEqualToString:@"ALPRAZOLAM 0.5MG    TAB"], @"the first order in RxFill didn't come out properly!");
}

- (void)testDictionaryToEmptyDictionaryAnd2CharNames
{
    NSDictionary *inputDictionary = @{@"itemId": @28421697};
    NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{@"itemId" : @"id"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputDictionary toObject:outputDictionary];
    
    NSNumber *itemId = [outputDictionary objectForKey:@"id"];
    XCTAssertTrue([itemId isKindOfClass:[NSNumber class]], @"id isn't of the NSNumber type!");
    XCTAssertTrue(itemId.integerValue == 28421697, @"itemId's value should be 28421697!");
}

- (void)testTraverseArrayToFindMappedFields
{
    NSDictionary *inputDictionary = @{@"blah": @"someString",
                                      @"topLevel": @[
                                              @{@"itemName" : @"item0", @"itemValue" : @"A Horse"},
                                              @{@"itemName" : @"item1", @"itemValue" : @"Leprocy"},
                                              @{@"itemName" : @"item2", @"itemValue" : @"Three Hamburgers"},
                                              @{@"itemName" : @"item3", @"itemValue" : @"Unknown smells",
                                                @"sources" : @[
                                                        @{ @"city" : @"Portland" },
                                                        @{ @"city" : @"Malmo" },
                                                        @{ @"city" : @"Gross Pointe" },
                                                        @{ @"city" : @"Prego" }
                                                        ]}
                                              ]};
    NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary = @{
                                        @"blah" : @"blah",
                                        @"topLevel[0].itemValue" : @"value0",
                                        @"topLevel[2].itemName" : @"name2",
                                        @"topLevel[3].sources[0].city" : @"pdx",
                                        @"topLevel[3].sources" : @"cityArray",
                                        @"topLevel[0]" : @"anObj"
                                        };
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:inputDictionary toObject:outputDictionary];
    
    NSString *value0    = [outputDictionary objectForKey:@"value0"];
    NSString *name2     = [outputDictionary objectForKey:@"name2"];
    NSString *pdx       = [outputDictionary objectForKey:@"pdx"];
    NSArray  *cityArray = [outputDictionary objectForKey:@"cityArray"];
    NSDictionary *anObj = [outputDictionary objectForKey:@"anObj"];
    
    XCTAssertTrue([value0    isKindOfClass:[NSString     class]], @"value0 isn't of the NSString type!");
    XCTAssertTrue([name2     isKindOfClass:[NSString     class]], @"name2 isn't of the NSString type!");
    XCTAssertTrue([pdx       isKindOfClass:[NSString     class]], @"pdx isn't of the NSString type!");
    XCTAssertTrue([cityArray isKindOfClass:[NSArray      class]], @"cityArray isn't of the NSArray type!");
    XCTAssertTrue([anObj     isKindOfClass:[NSDictionary class]], @"anObj isn't of the NSDictionary type!");
    
    XCTAssertTrue([value0 isEqualToString:@"A Horse"], @"value0 should be A Horse!");
    XCTAssertTrue([name2  isEqualToString:@"item2"], @"name2 should be item2!");
    XCTAssertTrue([pdx    isEqualToString:@"Portland"], @"pdx should be Portland!");
    XCTAssertTrue([cityArray count]==4, @"cityArray should have 4 entries!");
    XCTAssertTrue([anObj count]==2, @"anObj should have 2 entries!");
}

- (void)testTraverseArrayFailures
{
    NSDictionary *inputDictionary = @{@"topLevel": @[
                                              @{@"itemName" : @"item0", @"itemValue" : @"A Horse"},
                                              @{@"itemName" : @"item1", @"itemValue" : @"Leprocy"},
                                              @{@"itemName" : @"item2", @"itemValue" : @"Three Hamburgers"},
                                              @{@"itemName" : @"item3", @"itemValue" : @"Unknown smells",
                                                @"sources" : @[
                                                        @{ @"city" : @"Portland" },
                                                        @{ @"city" : @"Malmo" },
                                                        @{ @"city" : @"Gross Pointe" },
                                                        @{ @"city" : @"Prego" }
                                                        ]}
                                              ]};
    NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mappingDictionary1 = @{
                                         @"topLevel[400].itemValue" : @"value0", // beyond the end of the array
                                         @"topLevel[0.itemValue" : @"value1",
                                         @"topLevel0].itemValue" : @"value2",
                                         @"topLevel[].itemValue" : @"value3",
                                         @"topLevel.[0].itemValue" : @"value4",
                                         @"topLevel.[0]itemValue" : @"value5"
                                        };

    SDDataMap *mapper = nil;
    
    mapper = [SDDataMap mapForDictionary:mappingDictionary1];
    [mapper mapObject:inputDictionary toObject:outputDictionary];
    
    XCTAssertTrue(outputDictionary.count==0, @"the mapping returned results when they should have failed!");
}

- (void)testValueForKeyOddity
{
    NSDictionary *mappingDictionary = @{@"error": @"error"};
    NSDictionary *outputDictionary = [NSMutableDictionary dictionary];
    NSArray *testArray = @[
                           @{@"blah": @"1"},
                           @{@"blah": @"2"},
                           @{@"blah": @"3"},
                           ];
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:testArray toObject:outputDictionary];
}

- (void)testArrayErrorBehavior
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];

    // purposefully see how it handles bad data.
    // NSString is not a MyObject and isn't an array.
    NSDictionary *dummyDictionary = @{@"blah1" : @"NSString"};
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<MyObject>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue(output == nil, @"we gave it bad data, there should be NO output!");
}

- (void)testArrayErrorBehavior2
{
    NSMutableDictionary *dummyObject = [NSMutableDictionary dictionary];
    NSDictionary *object1 = @{@"blah2": @"object1"};
    NSDictionary *object2 = @{@"blah2": @"object2", @"shouldBeInvalid": @YES }; // make this guy return that he's invalid.
    NSDictionary *object3 = @{@"blah2": @"object3"};
    NSArray *blah1 = @[object1, object2, object3];
    
    NSDictionary *dummyDictionary = @{@"blah1" : blah1};
    
    NSDictionary *mappingDictionary = @{@"blah1" : @"(NSArray<MyObject>)blah1"};
    
    SDDataMap *mapper = [SDDataMap mapForDictionary:mappingDictionary];
    [mapper mapObject:dummyDictionary toObject:dummyObject];
    
    NSArray *output = (NSArray *)[dummyObject objectForKey:@"blah1"];
    XCTAssertTrue((output.count == 2), @"dummyObject should only have 2 items!");
    XCTAssertTrue([[output objectAtIndex:0] isKindOfClass:[MyObject class]], @"The items in the output array aren't of MyObject!");
    XCTAssertTrue([[[output objectAtIndex:1] valueForKey:@"blah2"] isEqualToString:@"object3"], @"blah2 on item 1 should be 'object3'!");
}

- (void)testSDDMTransformedMacro
{
    MyObject *object = [MyObject new];
    NSString *result = sddm_transformed_key(object, object.shouldBeInvalid, NSNegateBooleanTransformerName);
    XCTAssert([result isEqualToString:@"@transformed(shouldBeInvalid,NSNegateBoolean)"]);
}

- (void)testMapWithTransformsActuallyTransformsValues
{
    NSDictionary *data = @{@"shouldBeInvalid": @YES};
    MyObject *object = [MyObject new];
    NSDictionary *map = @{@"shouldBeInvalid": sddm_transformed_key(object, object.shouldBeInvalid, NSNegateBooleanTransformerName)};
    SDDataMap *mapper = [SDDataMap mapForDictionary:map];
    [mapper mapObject:data toObject:object];

    XCTAssert(object.shouldBeInvalid == NO);
}

@end
