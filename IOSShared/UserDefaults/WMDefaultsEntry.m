//
//  WMDefaultsEntry.m
//  walmart
//
//  Created by David Pettigrew on 1/22/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import "WMDefaultsEntry.h"
#import "NSUserDefaults+SDExtensions.h"

@implementation WMDefaultsEntry

- (instancetype)initWithKey:(NSString *)keyName {
    self = [super init];
    if (self) {
        _keyName = keyName;
    }
    return self;
}

- (void)clear {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation WMDefaultsLocationEntry

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    if (CLLocationCoordinate2DIsValid(coordinate)) { // ignore if invalid coordinate given
        [[NSUserDefaults standardUserDefaults] setCoordinate:coordinate forKey:self.keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
    if ([[NSUserDefaults standardUserDefaults] keyExists:self.keyName])
    {
        coordinate = [[NSUserDefaults standardUserDefaults] coordinateForKey:self.keyName];
    }
    return coordinate;
}

@end

@implementation WMDefaultsStringEntry

- (NSString *)stringValue {
    return [[NSUserDefaults standardUserDefaults] stringForKey:self.keyName];
}

- (void)setStringValue:(NSString *)stringValue {
    if (stringValue) {
        [[NSUserDefaults standardUserDefaults] setObject:stringValue forKey:self.keyName];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.keyName];
    }
}

@end

@implementation WMDefaultsBoolEntry

- (BOOL)boolValue {
    return [[NSUserDefaults standardUserDefaults] boolForKey:self.keyName];
}

- (void)setBoolValue:(BOOL)boolValue {
    [[NSUserDefaults standardUserDefaults] setBool:boolValue forKey:self.keyName];
}

@end

@implementation WMDefaultsArrayEntry

- (NSArray *)arrayValue {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:self.keyName];
}

- (void)setArrayValue:(NSArray *)arrayValue {
    [[NSUserDefaults standardUserDefaults] setObject:arrayValue forKey:self.keyName];
}

@end
