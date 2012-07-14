//
//  NSObject+MTKBlockObserving.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTKBlockObservationTypes.h"



@interface NSObject (MTKBlockObserving)



- (NSMutableSet *)mtk_blockObservers;
- (void)mtk_addBlockObserver:(id)blockObserver;
- (void)mtk_removeAllBlockObservers;



- (void)observe:(MTKBlockObservationKind)kind
        keyPath:(NSString *)keyPath
      withBlock:(void (^)(id old, id new, NSIndexSet *indexes))block;



- (void)observeAnythingAtKeyPath:(NSString *)keyPath
                       withBlock:(void(^)(MTKBlockObservationKind kind, id old, id new, NSIndexSet *indexes))block;



- (void)observeWillChange:(NSString *)keyPath
                withBlock:(void(^)(id oldValue))block;

- (void)observeDidChange:(NSString *)keyPath
               withBlock:(void(^)(id oldValue, id newValue))block;



- (void)observeWillInsert:(NSString *)keyPath
                withBlock:(void(^)(NSIndexSet *indexes))block;

- (void)observeDidInsert:(NSString *)keyPath
               withBlock:(void(^)(id newValues, NSIndexSet *indexes))block;




- (void)observeWillRemove:(NSString *)keyPath
                withBlock:(void(^)(id oldValues, NSIndexSet *indexes))block;

- (void)observeDidRemove:(NSString *)keyPath
               withBlock:(void(^)(id oldValues, NSIndexSet *indexes))block;



- (void)observeWillReplace:(NSString *)keyPath
                 withBlock:(void(^)(id oldValues, NSIndexSet *indexes))block;

- (void)observeDidReplace:(NSString *)keyPath
                withBlock:(void(^)(id oldValues, id newValues, NSIndexSet *indexes))block;



@end
