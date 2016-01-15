//
//  SDPoser.h
//
//  Created by Brandon Sneed on 10/7/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The block used to instantiate and return an instance of the posing class.
 */
typedef id(^SDPoserInstantiationBlock)(void);

/**
 SDPoser is a poor mans replacement for poseAs:.  As such, you can use it in very similar ways.  The
 one caveat is that the replacement has to be expected by the libraries or objects being talked to.
 
 This is intended to be used for internal libraries such as Lists or Pharmacy where a published internal
 API exists which has specific override points.
 
 @example
 
    Client App:
 
        // tell MyView to pose as RxView and use said block to perform the instantiation.
        [MyView poseAs:[RxView class] instantiationBlock:^() {
            return [[MyView alloc] initWithFrame:CGMakeRect(0, 0, 100, 100)];
        }];
 
    Internal API:
 
        RxView *view = [SDPoser poserForClass:[RxView class]]; // will return an instance of MyView.

 */
@interface NSObject(SDPoser)

/**
 See +poseAs:containedIn:instantiationBlock:.  This method is equivalent to calling poseAs:containedIn:instantiationBlock:
 with a containerClass of nil.
 */
+ (void)poseAs:(Class)impersonatedClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;

/**
 Instructs the system that the current class will be used instead of 'impersonatedClass' within the application when it's contained within
 'containerClass' or nil.
 
 @param impersonatedClass The class to impersonate.
 @param containerClass Impersonate the original class only when contained within containerClass.  If nil, always impersonate said class.
 @param instantiationBlock Use this block to make and configure a new instance of this poser class.  If nil, calls to poserForClass will return
 a normal alloc'd init'd object of this class.
 */
+ (void)poseAs:(Class)impersonatedClass containedIn:(Class)containerClass instantiationBlock:(SDPoserInstantiationBlock)instantiationBlock;

@end


@interface SDPoser : NSObject

/**
 Returns the shared instance of SDPoser.  This object provides a custom result for -description to view the poser mappings.
 */
+ (instancetype)sharedInstance;

/**
 See +poserForClass:containerClass for a full description.  This method calls poserForClass:containerClass: with a nil container class.
 */
+ (id)poserForClass:(Class)impersonatedClass;

/**
 Returns an instance of the poser specified for 'impersonatedClass'.  If containerClass is not nil, return the poser to be used when contained within
 the specified 'containerClass'.
 
 @param impersonatedClass The class type being impersonated.
 @param containerClass The containerClass type, or nil.
 
 @return An instance of the posing class.  If no poser is found matching the values of impersonatedClass and containerClass, this 
 returns an instance of 'impersonatedClass' via alloc/init.
 */
+ (id)poserForClass:(Class)impersonatedClass containerClass:(Class)containerClass;

/**
 See +poserClassForClass:containerClass for a full description.  This method calls poserForClass:containerClass: with a nil container class.
 */
+ (id)poserClassForClass:(Class)impersonatedClass;

/**
 Returns the poser class specified for 'impersonatedClass'.  If containerClass is not nil, return the poser to be used when contained within
 the specified 'containerClass'.
 
 @param impersonatedClass The class type being impersonated.
 @param containerClass The containerClass type, or nil.
 
 @return The posing class.  If no poser is found matching the values of impersonatedClass and containerClass, this
 returns 'impersonatedClass'.
 */
+ (Class)poserClassForClass:(Class)impersonatedClass containerClass:(Class)containerClass;

@end
