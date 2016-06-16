//
//  UINavigationController+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 1/10/13.
//  Copyright (c) 2013-2014 SetDirection. All rights reserved.
//

#import "UINavigationController+SDExtensions.h"

@implementation UINavigationController (SDExtensions)

- (NSArray *)popViewControllerByLevels:(NSUInteger)numLevels animated:(BOOL)animated
{
    NSArray *viewControllersOnStack = self.viewControllers;
    NSUInteger theCount = viewControllersOnStack.count;
    NSUInteger currentLevel = (theCount > 0) ? (theCount - 1) : 0;
    
    if (numLevels == currentLevel) {
        return [self popToRootViewControllerAnimated:animated];
    }
    
    NSUInteger indexToPopTo = viewControllersOnStack.count - numLevels;
    return [self popToViewController:[viewControllersOnStack objectAtIndex:indexToPopTo] animated:animated];
}

- (void)removePreviousViewControllers:(NSUInteger)count pushViewController:(UIViewController *)controller
{
    if (!controller)
        return;
    
    NSArray *viewControllersOnStack = self.viewControllers;
    NSUInteger vcCount = viewControllersOnStack.count;
    NSMutableArray *viewControllers = [viewControllersOnStack mutableCopy];
    if (count < vcCount)
    {
        for (NSUInteger i = 0; i < count; i++)
        {
            [viewControllers removeLastObject];
        }
    }
    
    [viewControllers addObject:controller];
    
    NSArray *newViewControllers = [NSArray arrayWithArray:viewControllers];
    [self setViewControllers:newViewControllers animated:YES];
}

- (NSArray *)popToRootViewControllerDismissingModalAnimated:(BOOL)animated
{
    UIViewController *v = [self.viewControllers lastObject];
    if (v.presentedViewController != nil)
    {
        [v dismissViewControllerAnimated:animated completion:nil];
    }
    return [self popToRootViewControllerAnimated:animated];
}

- (BOOL)viewControllerClassPresentOnStack:(Class)controllerClass
{
    if (!controllerClass)
        return NO;
    
    BOOL result = NO;
    
    NSArray *viewControllersOnStack = self.viewControllers;
    for (UIViewController *controller in viewControllersOnStack)
    {
        if ([controller isKindOfClass:controllerClass])
        {
            result = YES;
            break;
        }
    }
    
    return result;
}

@end
