//
//  NSObject+MTKBlockObserving.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTKBlockObservationTypes.h"
#import "MTKBlockObserver.h"



@interface NSObject (MTKBlockObserving)



- (NSSet *)blockObservers;
- (NSSet *)blockObserversForKeyPath:(NSString *)keyPath;
- (NSSet *)blockObserversOfKind:(MTKBlockObservationKind)kind forKeyPath:(NSString *)keyPath;

- (void)addBlockObserver:(MTKBlockObserver *)blockObserver;

- (void)removeBlockObserversForKeyPath:(NSString *)keyPath;
- (void)removeBlockObserversOfKind:(MTKBlockObservationKind)kind forKeyPath:(NSString *)keyPath;
- (void)removeBlockObserver:(MTKBlockObserver *)blockObserver;
- (void)removeAllBlockObservers;


- (void)observe:(NSString *)keyPath
      withBlock:(void (^)(id oldValue,
                          id newValue))observationBlock;

- (MTKBlockObserver *)observeChanges:(NSString *)keyPath
                         beforeBlock:(void(^)(id oldValue))beforeBlock
                          afterBlock:(void(^)(id newValue))afterBlock;

- (MTKBlockObserver *)observeSetting:(NSString *)keyPath
                         beforeBlock:(void(^)(id oldValue))beforeBlock
                          afterBlock:(void(^)(id oldValue,
                                              id newValue))afterBlock;

- (MTKBlockObserver *)observeInsertion:(NSString *)keyPath
                           beforeBlock:(void(^)(NSIndexSet *indexes))beforeBlock
                            afterBlock:(void(^)(id newValues,
                                                NSIndexSet *indexes))afterBlock;

- (MTKBlockObserver *)observeRemoval:(NSString *)keyPath
                         beforeBlock:(void(^)(id oldValues,
                                              NSIndexSet *indexes))beforeBlock
                          afterBlock:(void(^)(id oldValues,
                                              NSIndexSet *indexes))afterBlock;

- (MTKBlockObserver *)observeReplacement:(NSString *)keyPath
                             beforeBlock:(void(^)(id oldValues,
                                                  NSIndexSet *indexes))beforeBlock
                              afterBlock:(void(^)(id oldValues,
                                                  id newValues,
                                                  NSIndexSet *indexes))afterBlock;



@end
