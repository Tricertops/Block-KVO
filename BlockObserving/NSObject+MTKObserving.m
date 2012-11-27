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





///////////////
@implementation NSObject (MTKObserving)



#pragma mark Internal

///
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

///
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



#pragma mark Property

///
- (void)observeProperty:(NSString *)keyPath withBlock:(MTKObservationChangeBlock)observationBlock {
    MTKObserver *observer = [self observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:observationBlock];
}

///
- (void)observeProperties:(NSArray *)keyPaths withBlock:(MTKObservationChangeBlockMany)observationBlock {
    MTKObservationChangeBlock singleObservationBlock = ^(__weak id weakSelf, id old , id new){
        observationBlock(weakSelf);
    };
    MTKObservationChangeBlock singleObservationBlockCopy = [singleObservationBlock copy];
    for (NSString *keyPath in keyPaths) {
        [self observeProperty:keyPath withBlock:singleObservationBlockCopy];
    }
}

///
- (void)observeProperty:(NSString *)keyPath withSelector:(SEL)observationSelector {
    NSMethodSignature *signature = [self methodSignatureForSelector:observationSelector];
    NSInteger numberOfArguments = [signature numberOfArguments];
    [self observeProperty:keyPath withBlock:^(__weak id self, id old, id new) {
        switch (numberOfArguments) {
            case 0:
            case 1:
                [NSException raise:NSInternalInconsistencyException format:@"What the fuck?! Method should have at least two arguments!"];
                break;
                
            case 2:
                [self performSelector:observationSelector];
                break;
                
            case 3:
                [self performSelector:observationSelector withObject:new];
                break;
                
            default:
                [self performSelector:observationSelector withObject:old withObject:new];
                break;
        }
    }];
}

///
- (void)observeProperties:(NSArray *)keyPaths withSelector:(SEL)observationSelector {
    for (NSString *keyPath in keyPaths) {
        [self observeProperty:keyPath withSelector:observationSelector];
    }
}



#pragma mark Relationship

///
- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(MTKObservationChangeBlock)changeBlock
             insertionBlock:(MTKObservationInsertionBlock)insertionBlock
               removalBlock:(MTKObservationRemovalBlock)removalBlock
           replacementBlock:(MTKObservationReplacementBlock)replacementBlock
{
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

///
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKObservationChangeBlock)changeBlock {
    [self observeRelationship:keyPath changeBlock:changeBlock insertionBlock:nil removalBlock:nil replacementBlock:nil];
}



#pragma mark Mapping

///
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath null:(id)nullReplacement {
    [self map:sourceKeyPath to:destinationKeyPath transform:^id(id value) {
        return value ?: nullReplacement;
    }];
}

///
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath transform:(id (^)(id))transformationBlock {
    [self observeProperty:sourceKeyPath withBlock:^(__weak id self, id old, id new) {
        id transformedValue = (transformationBlock? transformationBlock(new) : new);
        [self setValue:transformedValue forKeyPath:destinationKeyPath];
    }];
}



#pragma Cleanup

///
- (void)removeAllObservations {
    [[self.blockObservers allValues] makeObjectsPerformSelector:@selector(detach)];
    [self.blockObservers removeAllObjects];
}



@end


