//
//  NSObject+MTKBlockObserving.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "NSObject+MTKBlockObserving.h"

#import <objc/runtime.h>

#import "MTKBlockObserver.h"
#import "MTKChangeBlockObserver.h"
#import "MTKSettingBlockObserver.h"
#import "MTKInsertionBlockObserver.h"
#import "MTKRemovalBlockObserver.h"
#import "MTKReplacementBlockObserver.h"



@interface NSObject (MTKBlockObserving_Private)

@end






@implementation NSObject (MTKBlockObserving)



- (NSSet *)blockObservers {
    static char associationKey;
    NSMutableSet *blockObservers = objc_getAssociatedObject(self, &associationKey);
    if ( ! blockObservers) {
        blockObservers = [[NSMutableSet alloc] init];
        objc_setAssociatedObject(self,
                                 &associationKey,
                                 blockObservers,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return blockObservers;
}

- (NSSet *)blockObserversForKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"keyPath == %@", keyPath];
    return [self.blockObservers filteredSetUsingPredicate:predicate];
}

- (NSSet *)blockObserversOfKind:(MTKBlockObservationKind)kind forKeyPath:(NSString *)keyPath; {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"kind == %i AND keyPath == %@", kind, keyPath];
    return [self.blockObservers filteredSetUsingPredicate:predicate];
}

- (void)addBlockObserver:(MTKBlockObserver *)blockObserver {
    [(NSMutableSet *)self.blockObservers addObject:blockObserver];
    [blockObserver attach];
}

- (void)removeBlockObserversForKeyPath:(NSString *)keyPath {
    for (MTKBlockObserver *blockObserver in [self blockObserversForKeyPath:keyPath]) {
        [self removeBlockObserver:blockObserver];
    }
}

- (void)removeBlockObserversOfKind:(MTKBlockObservationKind)kind forKeyPath:(NSString *)keyPath {
    for (MTKBlockObserver *blockObserver in [self blockObserversOfKind:kind forKeyPath:keyPath]) {
        [self removeBlockObserver:blockObserver];
    }
}

- (void)removeBlockObserver:(MTKBlockObserver *)blockObserver {
    [blockObserver detach];
    [(NSMutableSet *)self.blockObservers removeObject:blockObserver];
}

- (void)removeAllBlockObservers {
    [self.blockObservers makeObjectsPerformSelector:@selector(detach)];
    [(NSMutableSet *)self.blockObservers removeAllObjects];
}



- (void)observe:(NSString *)keyPath
      withBlock:(void (^)(id oldValue,
                          id newValue))observationBlock {
    [self observeSetting:keyPath beforeBlock:nil afterBlock:observationBlock];
}

- (MTKBlockObserver *)observeChanges:(NSString *)keyPath
                         beforeBlock:(void(^)(id))beforeBlock
                          afterBlock:(void(^)(id))afterBlock {
    MTKBlockObserver *blockObserver = [MTKBlockObserver changeBlockObserverWithObject:self
                                                                              keyPath:keyPath
                                                                          beforeBlock:beforeBlock
                                                                           afterBlock:afterBlock];
    [self addBlockObserver:blockObserver];
    return blockObserver;
}

- (MTKBlockObserver *)observeSetting:(NSString *)keyPath
                         beforeBlock:(void(^)(id))beforeBlock
                          afterBlock:(void(^)(id, id))afterBlock {
    MTKBlockObserver *blockObserver = [MTKBlockObserver settingBlockObserverWithObject:self
                                                                               keyPath:keyPath
                                                                           beforeBlock:beforeBlock
                                                                            afterBlock:afterBlock];
    [self addBlockObserver:blockObserver];
    return blockObserver;
}

- (MTKBlockObserver *)observeInsertion:(NSString *)keyPath
                           beforeBlock:(void(^)(NSIndexSet *))beforeBlock
                            afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    MTKBlockObserver *observer = [MTKBlockObserver insertionBlockObserverWithObject:self
                                                                            keyPath:keyPath
                                                                        beforeBlock:beforeBlock
                                                                         afterBlock:afterBlock];
    [self addBlockObserver:observer];
    return observer;
}

- (MTKBlockObserver *)observeRemoval:(NSString *)keyPath
                         beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
                          afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    MTKBlockObserver *observer = [MTKBlockObserver removalBlockObserverWithObject:self
                                                                          keyPath:keyPath
                                                                      beforeBlock:beforeBlock
                                                                       afterBlock:afterBlock];
    [self addBlockObserver:observer];
    return observer;
}

- (MTKBlockObserver *)observeReplacement:(NSString *)keyPath
                             beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
                              afterBlock:(void(^)(id, id, NSIndexSet *))afterBlock {
    MTKBlockObserver *observer = [MTKBlockObserver replacementBlockObserverWithObject:self
                                                                              keyPath:keyPath
                                                                          beforeBlock:beforeBlock
                                                                           afterBlock:afterBlock];
    [self addBlockObserver:observer];
    return observer;
}



@end


