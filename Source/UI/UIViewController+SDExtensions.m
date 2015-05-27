//
//  UIViewController+SDExtensions.m
//  Photos
//
//  Created by Brandon Sneed on 5/16/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIViewController+SDExtensions.h"

#import "NSObject+SDExtensions.h"
#import "UIDevice+machine.h"
#import <objc/runtime.h>

static char const *const kSDViewControllerHasGlobalNavigation = "kSDViewControllerHasGlobalNavigation";

@implementation UIViewController (SDExtensions)

+ (UINavigationController *)instanceInNavigationController;
{
    id instance = [[self alloc] initWithNibName:nil bundle:nil];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

+ (UINavigationController *)instanceInNavigationControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    id instance = [[self alloc] initWithNibName:nibName bundle:bundle];
    return [[UINavigationController alloc] initWithRootViewController:instance];
}

- (UINavigationController *)wrapInstanceInNavigationController
{
    return [[UINavigationController alloc] initWithRootViewController:self];
}

+ (instancetype)loadFromStoryboard
{
    return [self storyboardNamed:nil loadView:YES];
}

+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName
{
    return [self storyboardNamed:storyboardName loadView:YES];
}

+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier
{
    return [self storyboardNamed:storyboardName identifier:identifier loadView:YES];
}

+ (instancetype)storyboardNamed:(NSString *)storyboardName loadView:(BOOL)loadView
{
    NSString *modifiedName = [storyboardName copy];
    NSString *className = [self className];
    NSString *resourcePath = nil;
    UIViewController *result = nil;
    BOOL usingClassName = NO;
    
    // they passed in nil, assume the storyboardName should be the class name.
    if (!modifiedName)
    {
        modifiedName = className;
        usingClassName = YES;
    }

    // Search for: storyboardName.storyboardc / className.storyboardc
    resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];

    // Search for: storyboardName_iPhone.storyboardc / className_iPhone.storyboardc
    if (!resourcePath)
    {
        modifiedName = [NSString stringWithFormat:@"%@_%@", modifiedName, [UIDevice iPad] ? @"iPad" : @"iPhone"];
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    }

    if (!usingClassName && !resourcePath) // prevents duplicate searches.
    {
        // Search for: className.storyboardc
        if (!resourcePath)
        {
            modifiedName = className;
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }

        // Search for: className_iPhone.storyboardc
        if (!resourcePath)
        {
            modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
    }
    
    // if so, load that motherfucker.
    if (resourcePath)
    {
        // this will throw an exception if it can't find the storyboard.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
        result = [storyboard instantiateInitialViewController];
    }
    // else we're kind of SOL.  the caller had better support getting a nil view controller.

    if ([result isKindOfClass:[self class]])
    {
        if(loadView)
        {
            __attribute__((unused)) UIView *loadedView = [result view];
        }
    }
    else
    {
        result = nil;
    }
    
    // try the identifier...
    if (!result)
        result = [self storyboardNamed:storyboardName identifier:[self className] loadView:loadView];

    // the types didn't match.  best to return nil.
    return result;
}

+ (instancetype)storyboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier loadView:(BOOL)loadView
{
    // if no identifier was given, use the class name.
    if (!identifier)
        identifier = [self className];
    
    NSString *modifiedName = [storyboardName copy];
    NSString *className = [self className];
    NSString *resourcePath = nil;
    UIViewController *result = nil;
    BOOL usingClassName = NO;
    
    // they passed in nil, assume the storyboardName should be the class name.
    if (!modifiedName)
    {
        modifiedName = className;
        usingClassName = YES;
    }
    
    // Search for: storyboardName.storyboardc / className.storyboardc
    resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    
    // Search for: storyboardName_iPhone.storyboardc / className_iPhone.storyboardc
    if (!resourcePath)
    {
        modifiedName = [NSString stringWithFormat:@"%@_%@", modifiedName, [UIDevice iPad] ? @"iPad" : @"iPhone"];
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
    }
    
    if (!usingClassName && !resourcePath) // prevents duplicate searches.
    {
        // Search for: className.storyboardc
        if (!resourcePath)
        {
            modifiedName = className;
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
        
        // Search for: className_iPhone.storyboardc
        if (!resourcePath)
        {
            modifiedName = [NSString stringWithFormat:@"%@_%@", className, [UIDevice iPad] ? @"iPad" : @"iPhone"];
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:modifiedName ofType:@"storyboardc"];
        }
    }
    
    // if so, load that motherfucker.
    if (resourcePath)
    {
        // this will throw an exception if it can't find the storyboard.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:modifiedName bundle:[NSBundle bundleForClass:[self class]]];
        result = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    // else we're kind of SOL.  the caller had better support getting a nil view controller.
    
    if ([result isKindOfClass:[self class]])
    {
        if(loadView)
        {
            __attribute__((unused)) UIView *loadedView = [result view];
        }
    }
    else
    {
        result = nil;
    }

    // the types didn't match.  best to return nil.
    return result;
}

- (NSString*)recursiveDescription
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"\n"];
    [self addDescriptionToString:description indentLevel:0];
    return description;
}

- (void)addDescriptionToString:(NSMutableString *)string indentLevel:(NSUInteger)indentLevel
{
    NSString *padding = [@"" stringByPaddingToLength:indentLevel withString:@" " startingAtIndex:0];
    [string appendString:padding];
    [string appendFormat:@"%@, %@",[self debugDescription],NSStringFromCGRect(self.view.frame)];
    
    for (UIViewController *childController in self.childViewControllers)
    {
        [string appendFormat:@"\n%@>",padding];
        [childController addDescriptionToString:string indentLevel:indentLevel + 1];
    }
}

- (void)useGenericBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void) setHasGlobalNavigation:(BOOL)hasGlobalNavigation
{
    NSNumber *number = [NSNumber numberWithBool: hasGlobalNavigation];
    objc_setAssociatedObject(self, kSDViewControllerHasGlobalNavigation, number , OBJC_ASSOCIATION_RETAIN);
}

- (BOOL) hasGlobalNavigation
{
    NSNumber *number = objc_getAssociatedObject(self, kSDViewControllerHasGlobalNavigation);
    return [number boolValue];
}

@end
