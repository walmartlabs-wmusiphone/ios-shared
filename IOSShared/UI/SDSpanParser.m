//
//  SDSpanParser.m
//
//  Created by Steven W. Riggins on 1/19/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDSpanParser.h"
#import "NSError+SDExtensions.h"

typedef NS_ENUM(NSUInteger, SRSpanMatchType)
{
    SRSpanMatchTypeOpen = 0,
    SRSpanMatchTypeClose
};


/**
 *  SRSpanMatch is a class that wraps the results of a NSTextCheckingResult
 *  and exposes the ranges in a sane manner
 */

@interface SRSpanMatch : NSObject
@property (nonatomic, assign, readonly) NSRange               classRange;
@property (nonatomic, assign, readonly) NSRange               spanRange;
@property (nonatomic, assign, readonly) SRSpanMatchType       type;

/**
 *  Find all span tags and return SRSpanMatches for them
 *
 *  @param string The string to parse
 *
 *  @return NSArray of SRSpanMatch objects
 */
+ (NSArray *)matchesIn:(NSString *)string;

/**
 *  Convert an array of NSTextCheckingResult objects into an array
 *  of SRSpanMatch objects with the given type
 *
 *  @param array NSArray of NSTextCheckingResult objects
 *  @param type  SRSpanMatchType to assign to new SRSpanMatch objects
 *
 *  @return NSArray ofSRSpanMatch objects
 */
+ (NSArray *)arrayWithArray:(NSArray *)array type:(SRSpanMatchType)type;

/**
 *  Sorts an NSArray of SRSpanMatch objects by the spanRange
 *
 *  @param matches NSArray of SRSpanMatch objects
 *
 *  @return Sorted NSArray of SRSpanMatch objects
 */
+ (NSArray *)arrayBySortingMatches:(NSArray *)matches;

- (instancetype)initWithType:(SRSpanMatchType)type result:(NSTextCheckingResult *)result;

/**
 * Returns the range of the class name within a current classRange that is set.
 *
 * @param string - The wholestic string of text with span. Not a fragment.
 *
 * @param error - An error is returned if a class is not found.
 * 
 * @return The new range that will dictate where the class name is. Make sure to 
 * have classRange set first since it will only look within that range. classRange 
 * should be set on initWithType:result:.
 */
- (NSRange)properRangeForSpanWithClassOnString:(NSString *)string error:(NSError **)error;
@end

#pragma mark - SDSpanParser

@implementation SDSpanParser

+ (NSAttributedString *)parse:(NSString *)string withStyles:(NSDictionary *)styles
{
    NSArray *rawMatches = [SRSpanMatch matchesIn:string];
    
    NSMutableArray *styleStack = [NSMutableArray arrayWithCapacity:1];
    
    NSMutableDictionary *currentAttributes = [NSMutableDictionary dictionary];
    NSDictionary *normalAttributes = [styles objectForKey:@"normal"];
    if (normalAttributes)
    {
        [currentAttributes addEntriesFromDictionary:normalAttributes];
    }
    NSMutableAttributedString *currentStyledString = [[NSMutableAttributedString alloc] init];
    
    NSUInteger currentIndex = 0;

    
    if (rawMatches.count == 0)
    {
        currentStyledString = [[NSMutableAttributedString alloc] initWithString:string];
    }
    else
    {
        for (SRSpanMatch *match in rawMatches)
        {
            NSUInteger spanLocation = match.spanRange.location;
            if (spanLocation > currentIndex)
            {
                NSRange subRange = NSMakeRange(currentIndex, spanLocation - currentIndex);
                NSString *subString = [string substringWithRange:subRange];
                NSAttributedString *styledSubString = [[NSAttributedString alloc] initWithString:subString attributes:currentAttributes];
                [currentStyledString appendAttributedString:styledSubString];
                currentIndex += subRange.length;
            }
            
            if (spanLocation == currentIndex)
            {
                switch (match.type)
                {
                    case SRSpanMatchTypeOpen:
                    {
                        NSError *error = nil;
                        NSString *styleName = [[string substringWithRange:[match properRangeForSpanWithClassOnString:string error:&error]] lowercaseString];
                        
                        if (!error)
                        {
                            NSDictionary *styleDictionary = [styles objectForKey:styleName];
                            if (styleDictionary)
                            {
                                [styleStack addObject:currentAttributes];
                                currentAttributes = [currentAttributes mutableCopy];
                                [currentAttributes addEntriesFromDictionary:styleDictionary];
                            }
                        }
                        break;
                    }
                        
                    case SRSpanMatchTypeClose:
                        if (styleStack.count > 0)
                        {
                            currentAttributes = [styleStack lastObject];
                            [styleStack removeLastObject];
                        }
                        break;
                }
                currentIndex += match.spanRange.length;
            }
            
        }
        
        // Add any remaining text after the last tag
        if (currentIndex < (string.length - 1))
        {
            NSRange subRange = NSMakeRange(currentIndex, string.length - currentIndex);
            NSString *subString = [string substringWithRange:subRange];
            NSAttributedString *styledSubString = [[NSAttributedString alloc] initWithString:subString attributes:currentAttributes];
            [currentStyledString appendAttributedString:styledSubString];
        }
        
    }
    
    
    return [[NSAttributedString alloc] initWithAttributedString:currentStyledString];
}

@end

#pragma mark - SRSpanMatch
//________________________________________________________________________________________________________

@interface SRSpanMatch()
@property (nonatomic, assign) NSRange               classRange;
@property (nonatomic, assign) NSRange               spanRange;
@property (nonatomic, strong) NSTextCheckingResult *result;
@property (nonatomic, assign) SRSpanMatchType       type;
@end

@implementation SRSpanMatch

- (NSString *)description
{
    NSString *typeDesc;
    switch (self.type)
    {
        case SRSpanMatchTypeOpen:
            typeDesc = @"<span class=\"\">";
            break;
        case SRSpanMatchTypeClose:
            typeDesc = @"</span>";
            break;
    }
    
    NSString *desc = [NSString stringWithFormat:@"type: %@\nlocation: %zd\nlength: %zd\n", typeDesc, self.spanRange.location, self.spanRange.length];
    return desc;
}

+ (NSArray *)matchesIn:(NSString *)string
{
    // Case Insensitive for speed
    NSString *spanPattern = @"<span(.+?)>";
    NSRegularExpression *spanRegEx = [[NSRegularExpression alloc] initWithPattern:spanPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *endSpanPattern = @"</span>";
    NSRegularExpression *endSpanRegEx = [[NSRegularExpression alloc] initWithPattern:endSpanPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRange matchRange = NSMakeRange(0, string.length);
    
    NSArray *spanMatches = [spanRegEx matchesInString:string options:0 range:matchRange];
    NSArray *endSpanMatches = [endSpanRegEx matchesInString:string options:0 range:matchRange];
    
    NSAssert(spanMatches.count == endSpanMatches.count,@"Number of <span> tags does not match number of </span> tags");
    
    NSArray *openSpanMatches;
    NSArray *closeSpanMatches;
    openSpanMatches = [SRSpanMatch arrayWithArray:spanMatches type:SRSpanMatchTypeOpen];
    closeSpanMatches = [SRSpanMatch arrayWithArray:endSpanMatches type:SRSpanMatchTypeClose];
    
    NSArray *matches;
    matches = [openSpanMatches arrayByAddingObjectsFromArray:closeSpanMatches];
    matches = [SRSpanMatch arrayBySortingMatches:matches];

    return matches;
}

+ (NSArray *)arrayWithArray:(NSArray *)array type:(SRSpanMatchType)type
{
    NSMutableArray *matchArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSTextCheckingResult *match in array)
    {
        NSAssert([match isKindOfClass:[NSTextCheckingResult class]],@"array contains a non NSTextCheckingResult object");
        
        SRSpanMatch *spanMatch = [[SRSpanMatch alloc] initWithType:type result:match];
        [matchArray addObject:spanMatch];
    }
    return [matchArray copy];
}

- (instancetype)initWithType:(SRSpanMatchType)type result:(NSTextCheckingResult *)result
{
    self = [super init];
    if (self)
    {
        _type = type;
        _result = result;
        
        _spanRange = [_result rangeAtIndex:0];
        if (_type == SRSpanMatchTypeOpen)
        {
            NSAssert(_result.numberOfRanges > 1, @"open span tag missing class ");
            _classRange = [_result rangeAtIndex:1];
        }
        // Do nothing with the close as it doesn't have a class to replace with, e.g. </span>
    }
    return self;
}

+ (NSArray *)arrayBySortingMatches:(NSArray *)matches
{
    NSArray *sortedArray;
    sortedArray = [matches sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(SRSpanMatch *obj1, SRSpanMatch *obj2) {
        NSAssert([obj1 isKindOfClass:[SRSpanMatch class]],@"array contains a non SRSpanMatch object");
        NSAssert([obj2 isKindOfClass:[SRSpanMatch class]],@"array contains a non SRSpanMatch object");
        
        NSRange obj1Range;
        NSRange obj2Range;
        
        obj1Range = obj1.spanRange;
        obj2Range = obj2.spanRange;
        
        NSComparisonResult result = NSOrderedSame;
        
        if (obj2Range.location > obj1Range.location)
        {
            result = NSOrderedAscending;
        }
        else if (obj1Range.location > obj2Range.location)
        {
            result = NSOrderedDescending;
        }
        return result;
    }];
    
    return sortedArray;
}

- (NSRange)properRangeForSpanWithClassOnString:(NSString *)string error:(NSError **)error
{
    NSRange finalRange = NSMakeRange(0, 0);
    
    // Attempt to get the string from the current class range
    NSString *foundString = [string substringWithRange:self.classRange];
    if ([foundString rangeOfString:@"class="].location != NSNotFound)
    {
        // Create a new final range offset
        NSRegularExpression *classExpression = [NSRegularExpression regularExpressionWithPattern:@"class=\"(.+?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [classExpression matchesInString:string options:0 range:self.classRange];

        // Make sure we found a class, if not just bail with the current class range
        if ([matches count] > 0)
        {
            NSTextCheckingResult *checkingResult = [matches firstObject];
            if (checkingResult.numberOfRanges > 1)
            {
                NSRange tempRange = [checkingResult rangeAtIndex:1];
                finalRange = tempRange;
            }
            
        }
    }
    else if (error != NULL)
    {
        *error = [NSError errorWithDomain:@"Class Not Found on Span" code:NSURLErrorUnknown];
    }
    
    return finalRange;
}

@end

