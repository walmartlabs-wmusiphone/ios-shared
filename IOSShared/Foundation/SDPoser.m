//
//  SDPoser.m
//
//  Created by Brandon Sneed on 10/7/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDPoser.h"
#import "SDLog.h"

#pragma mark - SDPoser item storage

@interface SDPoserItem : NSObject
@property (nonatomic, assign) Class poserClass;
@property (nonatomic, assign) Class impersonatedClass;
@property (nonatomic, assign) Class containerClass;
@property (nonatomic, strong) SDPoserInstantiationBlock instantiationBlock;
+ (instancetype)poserItem;
@end

@implementation SDPoserItem

+ (instancetype)poserItem
{
    return [[SDPoserItem alloc] init];
}

@end

#pragma mark - SDPoser private interface

@interface SDPoser()

- (id)poserForClass:(Class)impersonatedClass;
- (id)poserForClass:(Class)impersonatedClass containerClass:(Class)containerClass;
- (void)poserClass:(Class)poserClass impersonateClass:(Class)impersonatedClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;
- (void)poserClass:(Class)poserClass impersonateClass:(Class)impersonatedClass containedIn:(Class)containerClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;

@end

#pragma mark - SDPoser's NSObject extensions

@implementation NSObject(SDPoser)

+ (void)poseAs:(Class)impersonatedClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock
{
    [self poseAs:impersonatedClass containedIn:nil instantiationBlock:instantiationBlock];
}

+ (void)poseAs:(Class)impersonatedClass containedIn:(Class)containerClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock
{
    [[SDPoser sharedInstance] poserClass:[self class] impersonateClass:impersonatedClass containedIn:containerClass instantiationBlock:instantiationBlock];
}

@end

#pragma mark - SDPoser implementation

@implementation SDPoser
{
    NSMutableDictionary *_poserMap;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (id)poserForClass:(Class)impersonatedClass
{
    return [[self sharedInstance] poserForClass:impersonatedClass];
}

+ (id)poserForClass:(Class)impersonatedClass containerClass:(Class)containerClass
{
    return [[self sharedInstance] poserForClass:impersonatedClass containerClass:containerClass];
}

+ (id)poserClassForClass:(Class)impersonatedClass
{
    return [[self sharedInstance] poserClassForClass:impersonatedClass containerClass:nil];
}

+ (id)poserClassForClass:(Class)impersonatedClass containerClass:(Class)containerClass
{
    return [[self sharedInstance] poserClassForClass:impersonatedClass containerClass:containerClass];
}

- (id)poserForClass:(Class)impersonatedClass
{
    return [self poserForClass:impersonatedClass containerClass:nil];
}

- (id)poserForClass:(Class)impersonatedClass containerClass:(Class)containerClass
{
    NSString *lookupName = [self lookupNameForImpersonatedClass:impersonatedClass containerClass:containerClass];
    if (!lookupName)
        return nil;

    id result = nil;

    SDPoserItem *item = [_poserMap objectForKey:lookupName];

    if (!item && containerClass!=nil)
    {
        lookupName = [self lookupNameForImpersonatedClass:impersonatedClass containerClass:nil];
        item = [_poserMap objectForKey:lookupName];
    }
    
    if (!item)
    {
        // if there's no item for this, just return a raw version of the impersonated object.

        result = [[impersonatedClass alloc] init];
    }
    else
    if (item.instantiationBlock)
    {
        // if the item has an instantiationBlock, run it....

        // make a copy so we don't jack up the original and can copy it again later.
        SDPoserInstantiationBlock instantiationBlock = [item.instantiationBlock copy];
        result = instantiationBlock();
    }
    else
    {
        // ... otherwise, just init a raw one.
        result = [[item.poserClass alloc] init];
    }

    return result;
}

- (Class)poserClassForClass:(Class)impersonatedClass containerClass:(Class)containerClass
{
    NSString *lookupName = [self lookupNameForImpersonatedClass:impersonatedClass containerClass:containerClass];
    if (!lookupName)
        return nil;
    
    Class result = nil;
    
    SDPoserItem *item = [_poserMap objectForKey:lookupName];
    
    if (!item && containerClass!=nil)
    {
        lookupName = [self lookupNameForImpersonatedClass:impersonatedClass containerClass:nil];
        item = [_poserMap objectForKey:lookupName];
    }
    
    if (!item)
        result = impersonatedClass;
    else
        result = item.poserClass;
    
    return result;
}

- (id)init
{
    self = [super init];
    _poserMap = [NSMutableDictionary dictionary];
    return self;
}

- (void)poserClass:(Class)poserClass impersonateClass:(Class)impersonatedClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;
{
    [self poserClass:poserClass impersonateClass:impersonatedClass containedIn:nil instantiationBlock:instantiationBlock];
}

- (void)poserClass:(Class)poserClass impersonateClass:(Class)impersonatedClass containedIn:(Class)containerClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;
{
    NSString *lookupName = [self lookupNameForImpersonatedClass:impersonatedClass containerClass:containerClass];

    if (!lookupName)
        return;

    SDPoserItem *item = [SDPoserItem poserItem];
    item.poserClass = poserClass;
    item.impersonatedClass = impersonatedClass;
    item.containerClass = containerClass;
    item.instantiationBlock = instantiationBlock;

    [_poserMap setObject:item forKey:lookupName];
}

- (NSString *)lookupNameForImpersonatedClass:(Class)impersonatedClass containerClass:(Class)containerClass
{
    if (!impersonatedClass)
    {
        SDLog(@"lookupNameForImpersonatedClass doesn't accept a nil impersonatedClass");
        return nil;
    }

    NSString *impersonatedClassName = NSStringFromClass(impersonatedClass);
    NSString *containerClassName = NSStringFromClass(containerClass);

    NSString *result = nil;

    if (containerClass)
        result = [NSString stringWithFormat:@"%@(%@)", impersonatedClassName, containerClassName];
    else
        result = impersonatedClassName;

    return result;
}

#pragma mark - SDPoser utilities

- (NSString *)description
{
    NSMutableString *result = [@"\n" mutableCopy];

    [_poserMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SDPoserItem *item = (SDPoserItem *)obj;
        if (item.containerClass)
            [result appendFormat:@"%@ poses as %@ when contained in %@\n", NSStringFromClass(item.poserClass), NSStringFromClass(item.impersonatedClass), NSStringFromClass(item.containerClass)];
        else
            [result appendFormat:@"%@ poses as %@\n", NSStringFromClass(item.poserClass), NSStringFromClass(item.impersonatedClass)];
    }];

    [result appendString:@"\n"];
    
    return result;
}

@end
