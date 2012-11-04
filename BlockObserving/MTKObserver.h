//
//  MTKObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 28.9.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^MTKObservationChangeBlock)(__weak id self, id old, id new);
typedef void(^MTKObservationChangeBlockMany)(__weak id self);
typedef void(^MTKObservationInsertionBlock)(__weak id self, id new, NSIndexSet *indexes);
typedef void(^MTKObservationRemovalBlock)(__weak id self, id old, NSIndexSet *indexes);
typedef void(^MTKObservationReplacementBlock)(__weak id self, id old, id new, NSIndexSet *indexes);


@interface MTKObserver : NSObject

@property (nonatomic, readwrite, assign) BOOL attached;
- (void)attach;
- (void)detach;

- (id)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath;

- (void)addSettingObservationBlock:(MTKObservationChangeBlock)block;
- (void)addInsertionObservationBlock:(MTKObservationInsertionBlock)block;
- (void)addRemovalObservationBlock:(MTKObservationRemovalBlock)block;
- (void)addReplacementObservationBlock:(MTKObservationReplacementBlock)block;

@end
