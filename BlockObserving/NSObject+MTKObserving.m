//
//  NSObject+MTKObserving.m
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "NSObject+MTKObserving.h"
#import <objc/runtime.h>
#import "MTKObserver.h"






@implementation NSObject (MTKObserving)



#pragma mark Internal

- (NSMutableDictionary *)blockObservers {
    // Observer is a shadow object that has target this object (`self`) and specific key path.
    // There should never exist two or more observers with the same target AND key path.
    // Observer has multiple observation block which are executed in order they were added.
    static char associationKey;
    NSMutableDictionary *blockObservers = objc_getAssociatedObject(self, &associationKey);
    if ( ! blockObservers) {
        blockObservers = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self,
                                 &associationKey,
                                 blockObservers,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return blockObservers;
}

- (MTKObserver *)observerForKeyPath:(NSString *)keyPath {
    // Key path is used as key to retrieve observer.
    MTKObserver *observer = [[self blockObservers] objectForKey:keyPath];
    if ( ! observer) {
        observer = [[MTKObserver alloc] initWithTarget:self keyPath:keyPath];
        [self.blockObservers setObject:observer forKey:keyPath];
        [observer attach];
    }
    return observer;
}

- (void)observeProperty:(NSString *)keyPath
              withBlock:(void (^)(__weak id self,
                                  id old,
                                  id new))observationBlock {
    MTKObserver *observer = [self observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:observationBlock];
}

- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath transform:(id (^)(id))transformationBlock {
    [self observeProperty:sourceKeyPath withBlock:^(__weak id self, id old, id new) {
        id transformedValue = (transformationBlock? transformationBlock(new) : new);
        [self setValue:transformedValue forKeyPath:destinationKeyPath];
    }];
}

- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(void (^)(id self,
                                      id old,
                                      id new))changeBlock
             insertionBlock:(void (^)(id self,
                                      id news,
                                      NSIndexSet *indexes))insertionBlock
               removalBlock:(void (^)(id self,
                                      id olds,
                                      NSIndexSet *indexes))removalBlock
           replacementBlock:(void (^)(id self,
                                      id olds,
                                      id news,
                                      NSIndexSet *indexes))replacementBlock {
    MTKObserver *observer = [self observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:changeBlock];
    [observer addInsertionObservationBlock: insertionBlock ?: ^(__weak id self, id new, NSIndexSet *indexes) {
        // If no insertion block was specified, call general change block.
        changeBlock(self, nil, [self valueForKeyPath:keyPath]);
    }];
    [observer addRemovalObservationBlock: removalBlock ?: ^(__weak id self, id old, NSIndexSet *indexes) {
        // If no removal block was specified, call general change block.
        changeBlock(self, nil, [self valueForKeyPath:keyPath]);
    }];
    [observer addReplacementObservationBlock: replacementBlock ?: ^(__weak id self, id old, id new, NSIndexSet *indexes) {
        // If no removal block was specified, call general change block.
        changeBlock(self, nil, [self valueForKeyPath:keyPath]);
    }];
}

- (void)removeAllObservations {
    [[self.blockObservers allValues] makeObjectsPerformSelector:@selector(detach)];
    [self.blockObservers removeAllObjects];
}



@end


