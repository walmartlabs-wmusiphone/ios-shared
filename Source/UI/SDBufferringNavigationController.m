//
//  SDBufferingNavigationController.m
//  walmart
//
//  Created by David Pettigrew on 12/18/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDBufferingNavigationController.h"

typedef void (^SDBufferingNavigationControllerBlock)(void);
typedef UIViewController * (^SDBufferingNavigationControllerPopBlock)(void);
typedef NSArray * (^SDBufferingNavigationControllerPopArrayBlock)(void);

@interface SDBufferingNavigationController ()

@property (nonatomic, retain) NSMutableArray* stack;
@property (nonatomic, assign) bool transitioning;

@end


@implementation SDBufferingNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.stack = [[NSMutableArray alloc] init];
}

#pragma mark UINavigationController overrides
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            SDBufferingNavigationControllerPopBlock codeBlock = [^{
                return [super popViewControllerAnimated:animated];
            } copy];
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popViewControllerAnimated:animated];
        }
    }
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            SDBufferingNavigationControllerPopArrayBlock codeBlock = [^{
                return [super popToRootViewControllerAnimated:animated];
            } copy];
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popToRootViewControllerAnimated:animated];
        }
    }
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            SDBufferingNavigationControllerPopArrayBlock codeBlock = [^{
                return [super popToViewController:viewController animated:animated];
            } copy];
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popToViewController:viewController animated:animated];
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            // Copy block so its no longer on the (real software) stack
            @weakify(self);
            SDBufferingNavigationControllerBlock codeBlock = [^{
                @strongify(self);
                self.transitioning = true;
                if (![self.viewControllers isEqualToArray:viewControllers]) {
                    [super setViewControllers:viewControllers animated:animated];
                }
            } copy];
            
            // Add to the stack list and then release
            [self.stack addObject:codeBlock];
        } else {
            if (![self.viewControllers isEqualToArray:viewControllers]) {
                self.transitioning = true;
                [super setViewControllers:viewControllers animated:animated];
            }
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            @weakify(self);
            SDBufferingNavigationControllerBlock codeBlock = [^{
                @strongify(self);
                self.transitioning = true;
                [super pushViewController:viewController animated:animated];
            } copy];
            [self.stack addObject:codeBlock];
        } else {
            self.transitioning = true;
            [super pushViewController:viewController animated:animated];
        }
    }
}

#pragma mark UINavigationControllerDelegate methods. 
// These are used to detect the pending completion of an navigation transition and set the self.transitioning to false and run the next navigation block if there is one queued up.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @synchronized (self.stack) {
        id <UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
        if (transitionCoordinator) {
            self.transitioning = true;
            @weakify(self);
            [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id <UIViewControllerTransitionCoordinatorContext> context) {
                @synchronized (self.stack) {
                    @strongify(self);
                    self.transitioning = false;
                }
            }];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @synchronized(self.stack) {
        self.transitioning = false;
        [self runNextBlock];
    }
}

#pragma mark Helpers
- (void)pushCodeBlock:(void (^)())codeBlock {
    @synchronized(self.stack) {
        [self.stack addObject:[codeBlock copy]];
        
        if (!self.transitioning)
            [self runNextBlock];
    }
}

- (void)runNextBlock {
    if (self.stack.count == 0)
        return;
    
    SDBufferingNavigationControllerBlock codeBlock = [self.stack objectAtIndex:0];
    
    // Execute block, then remove it from the stack (which will dealloc)
    codeBlock();
    
    [self.stack removeObjectAtIndex:0];
}

@end
