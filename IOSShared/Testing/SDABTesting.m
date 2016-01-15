//
//  SDABTesting.m
//  ios-shared
//
//  Created by Brandon Sneed on 8/24/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDABTesting.h"

typedef enum
{
    SDABTestingValueDoesNotExist = 0,
    SDABTestingValueAPath,
    SDABTestingValueBPath
} SDABTestingValue;

const NSString *SDABTestingKeyDataA = @"A";
const NSString *SDABTestingKeyDataB = @"B";

const NSString *SDABTestingActionTest = @"test";
const NSString *SDABTestingActionGoal = @"goal";
const NSString *SDABTestingActionFailure = @"failure";

@interface SDABTesting (Private)
@property (copy) SDABTestingAnalyticsBlock analyticsBlock;
@end

@implementation SDABTesting

+ (instancetype)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

#pragma mark - Support methods

- (SDABTestingValue)valueForDefaultsKey:(NSString *)keyName
{
    SDABTestingValue value = (SDABTestingValue)[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"SDABTesting_%@", keyName]];
    return value;
}

- (void)setValue:(SDABTestingValue)value forDefaultsKey:(NSString *)keyName
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:[NSString stringWithFormat:@"SDABTesting_%@", keyName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SDABTestingValue)getAorB
{
    NSInteger tmp = (arc4random() % 30) + 1;
    if (tmp % 5 == 0)
        return SDABTestingValueBPath;
    return SDABTestingValueAPath;
}

- (void)logDataForKey:(NSString *)keyName action:(NSString *)action
{
    // we don't have an analytics block set, nothing to do here then.
    if (!self.analyticsBlock)
        return;

    // get the path chosen for this key.
    SDABTestingValue value = [self valueForDefaultsKey:keyName];

    if (value == SDABTestingValueDoesNotExist)
    {
        // something really fucked up happened, bolt!
        return;
    }

    NSString *keyData = nil;
    if (value == SDABTestingValueAPath)
        keyData = (NSString *)SDABTestingKeyDataA;
    else
    if (value == SDABTestingValueBPath)
        keyData = (NSString *)SDABTestingKeyDataB;

    self.analyticsBlock(keyName, action, keyData);
}


#pragma mark - Public interface

+ (void)setAnalyticsBlock:(SDABTestingAnalyticsBlock)block
{
    // remember, this is a COPY!
    [SDABTesting sharedInstance].analyticsBlock = block;
}

+ (void)testForKey:(NSString *)keyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock
{
    [self testForKey:keyName dependencyKey:nil A:aBlock B:bBlock];
}

+ (void)testForKey:(NSString *)keyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock
{
    [self testForKey:keyName dependencyKey:nil data:data A:aBlock B:bBlock];
}

+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName A:(SDABTestingBlock)aBlock B:(SDABTestingBlock)bBlock
{
    [self testForKey:keyName dependencyKey:depencencyKeyName data:nil A:^(NSDictionary *data) {
        if (aBlock)
            aBlock();
    } B:^(NSDictionary *data) {
        if (bBlock)
            bBlock();
    }];
}

+ (void)testForKey:(NSString *)keyName dependencyKey:(NSString *)depencencyKeyName data:(NSDictionary *)data A:(SDABTestingDataBlock)aBlock B:(SDABTestingDataBlock)bBlock
{
    NSAssert(keyName, @"You must pass a keyName for testForKey!");
    NSAssert(aBlock, @"You must pass an A-case block for testForKey!");
    NSAssert(bBlock, @"You must pass a B-case block for testForKey!");

    SDABTesting *tester = [SDABTesting sharedInstance];
    SDABTestingValue value = [tester valueForDefaultsKey:keyName];
    SDABTestingValue dependencyValue = [tester valueForDefaultsKey:depencencyKeyName];

    // if we have a dependency value, this value has to match.
    if (dependencyValue > 0)
        value = dependencyValue;

    // we don't have a dependency value if we get here.
    if (value == SDABTestingValueDoesNotExist)
    {
        // it hasn't been set/used before, so lets choose one at random.
        value = [tester getAorB];
        [tester setValue:value forDefaultsKey:keyName];
    }

    if (depencencyKeyName && dependencyValue == SDABTestingValueDoesNotExist)
    {
        /*
         we have a dependencyKey, but the value has never been set, yet we're
         in here.. i'm going to assume we want to set the dependency key to match
         what we ultimately decided since if it happens in reverse order, we're hosed.
         
         hopefully we never get here, as someone wrote some bad code.
        */

        [tester setValue:value forDefaultsKey:depencencyKeyName];
    }

    if (value == SDABTestingValueAPath)
    {
        if (tester.analyticsBlock)
            tester.analyticsBlock(keyName, (NSString *)SDABTestingActionTest, (NSString *)SDABTestingKeyDataA);
        if (aBlock)
            aBlock(data);
    }
    else
    if (value == SDABTestingValueBPath)
    {
        if (tester.analyticsBlock)
            tester.analyticsBlock(keyName, (NSString *)SDABTestingActionTest, (NSString *)SDABTestingKeyDataB);
        if (bBlock)
            bBlock(data);
    }
}

+ (void)goalReached:(NSString *)keyName
{
    [[SDABTesting sharedInstance] logDataForKey:keyName action:(NSString *)SDABTestingActionGoal];
}

+ (void)failureReached:(NSString *)keyName
{
    [[SDABTesting sharedInstance] logDataForKey:keyName action:(NSString *)SDABTestingActionFailure];
}

@end
