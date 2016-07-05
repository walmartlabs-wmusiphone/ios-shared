//
//  SDDragDropManager.h
//  testdrag
//
//  Created by Brandon Sneed on 8/23/11.
//  Copyright 2011-2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDragDropGestureRecognizer.h"

@protocol SDDropTargetProtocol <NSObject>
@optional
- (BOOL)dropTarget:(UIView *)dropTarget canAcceptView:(UIView *)view fromGestureRecognizer:(SDDragDropGestureRecognizer *)gesture;
- (void)dropTarget:(UIView *)dropTarget droppedView:(UIView *)view fromGestureRecognizer:(SDDragDropGestureRecognizer *)gesture;
@end

@interface SDDragDropManager : NSObject
{
    NSMutableArray *dropTargets;
}

@property (nonatomic, strong) UIView *dragContainer;
@property (nonatomic, readonly) NSArray *dropTargets;

+ (SDDragDropManager *)sharedManager;

- (void)addDropTarget:(UIView *)view;
- (void)removeDropTarget:(UIView *)view;

@end
