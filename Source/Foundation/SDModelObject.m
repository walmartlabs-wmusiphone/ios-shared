//
//  SDModelObject.m
//  ios-shared
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"

@implementation SDModelObject

- (id)init
{
    self = [super init];
    return self;
}

- (BOOL)validModel
{
    @throw [NSException exceptionWithName:@"SDModelObjectException" reason:@"Subclasses MUST override -validModel." userInfo:nil];
}

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    // this is the base class, so we'll return nothing.
    return nil;
}

+ (instancetype)mapFromObject:(id)sourceObject
{
    id modelObject = [[self alloc] init];
    [[SDDataMap map] mapObject:sourceObject toObject:modelObject];

    if ([modelObject validModel])
        return modelObject;

    return nil;
}

- (NSString *)description
{
    NSDictionary *aDict = [self dictionaryRepresentation];

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:aDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        SDLog(@"error converting event into JSON: %@", error);
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"%@\n%@", [super description], result];
}

- (id)representationForKey:(NSString *)aKey
{
    NSObject *theObj = [self valueForKey:aKey];

    if (!theObj)
    {
        return nil;
    }
    else
    if ([theObj respondsToSelector:@selector(dictionaryRepresentation)])
    {
        return [(SDModelObject *)theObj dictionaryRepresentation];
    }
    else
    if ([theObj isKindOfClass:[NSArray class]])
    {
        NSArray *theArray = (NSArray *)theObj;
        NSMutableArray *arrayRep = [NSMutableArray arrayWithCapacity:[theArray count]];
        for (NSObject *arrayItem in theArray)
        {
            if ([arrayItem respondsToSelector:@selector(dictionaryRepresentation)])
            {
                // It's a sub item
                [arrayRep addObject:[(SDModelObject *)arrayItem dictionaryRepresentation]];
            }
            else
            {
                // It's a plain nsvalue sub item
                [arrayRep addObject:arrayItem];
            }
        }
        return arrayRep;
    }

    // If we get here, we need to validate this
    NSAssert([theObj isKindOfClass:[NSValue class]], @"representationForKey: failed");
    return theObj;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *aDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *aSubDictionary = [NSMutableDictionary dictionary];
    NSDictionary *mappingDictionary = [self mappingDictionaryForData:nil];
    NSMutableDictionary *cleanMappingDictionary = [NSMutableDictionary dictionary];
    
    // Here we change the @"<RxObject>foo" values to @"foo" to force nsdictionary output
    NSArray *cleanKeys = [mappingDictionary allKeys];
    
    for (NSString *theKey in cleanKeys)
    {
        NSString *thePath = [mappingDictionary objectForKey:theKey];
        
        // The values that were mapped to a selector cannot be "unmapped"
        if ([thePath rangeOfString:@"@selector("].location == NSNotFound)
        {
            NSString *theMappedPath = [thePath stringByReplacingOccurrencesOfString:@"<(.*)>(.*)" withString:@"$2" options:NSRegularExpressionSearch range:NSMakeRange(0, thePath.length)];
            if ([theMappedPath isEqualToString:thePath])
            {
                // We are creating a reverse dictionary
                [cleanMappingDictionary setObject:theKey forKey:thePath];
            }
            else
            {
                NSObject *theSubValue = [self representationForKey:theKey];
                if (theSubValue)
                    [aSubDictionary setObject:theSubValue forKey:theMappedPath];
            }
        }
    }
    
    SDDataMap *dataMapper = [SDDataMap mapForDictionary:cleanMappingDictionary];
    [dataMapper mapObject:self toObject:aDictionary];
    
    if ([aSubDictionary count]>0)
        [aDictionary addEntriesFromDictionary:aSubDictionary];
    
    return aDictionary;
}

- (NSData *)JSONRepresentation
{
    return [[self dictionaryRepresentation] JSONRepresentation];
}

- (NSString *)JSONStringRepresentation
{
    return [[self dictionaryRepresentation] JSONStringRepresentation];
}

@end

@implementation SDErrorModelObject

- (BOOL)validModel
{
    @throw [NSException exceptionWithName:@"SDErrorModelObjectException" reason:@"Subclasses MUST override -validModel." userInfo:nil];
}

@end
