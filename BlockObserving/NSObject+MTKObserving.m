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

/// Getter for dictionary containing all registered observers for this object. Keys are observed key-paths.
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

/// Find existing observer or create new for this key-path. Multiple uses of one key-path return the same observer.
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

/// Add observation block to appropriate observer for setting the value.
- (void)observeProperty:(NSString *)keyPath withBlock:(MTKObservationChangeBlock)observationBlock {
    MTKObserver *observer = [self observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:observationBlock];
}

/// Copy the block and register it for all given key-paths.
- (void)observeProperties:(NSArray *)keyPaths withBlock:(MTKObservationChangeBlockMany)observationBlock {
    MTKObservationChangeBlock singleObservationBlock = ^(__weak id weakSelf, id old , id new){
        observationBlock(weakSelf);
    };
    // This should reduce memroy footprint, the block should have only one copy (not sure how blocks are stored in memory, so this may be useless)
    MTKObservationChangeBlock singleObservationBlockCopy = [singleObservationBlock copy];
    for (NSString *keyPath in keyPaths) {
        [self observeProperty:keyPath withBlock:singleObservationBlockCopy];
    }
}

/// Register block invoking given selector. Smart detecting of number of arguments.
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

/// Register the selector for each key-path.
- (void)observeProperties:(NSArray *)keyPaths withSelector:(SEL)observationSelector {
    for (NSString *keyPath in keyPaths) {
        [self observeProperty:keyPath withSelector:observationSelector];
    }
}



#pragma mark Relationship

/// Add observation blocks to appropriate observer. If some block was not specified, use the `changeBlock`.
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

/// Call main `-observeRelationship:...` method with only first argument.
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKObservationChangeBlock)changeBlock {
    [self observeRelationship:keyPath changeBlock:changeBlock insertionBlock:nil removalBlock:nil replacementBlock:nil];
}



#pragma mark Mapping

/// Call `-map:to:transform:` with transform block that uses returns the same value, or null replacement.
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath null:(id)nullReplacement {
    [self map:sourceKeyPath to:destinationKeyPath transform:^id(id value) {
        return value ?: nullReplacement;
    }];
}

/// Observe source key-path and set its new value to destination every time it changes. Use transformation block, if specified.
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath transform:(id (^)(id))transformationBlock {
    [self observeProperty:sourceKeyPath withBlock:^(__weak id self, id old, id new) {
        id transformedValue = (transformationBlock? transformationBlock(new) : new);
        [self setValue:transformedValue forKeyPath:destinationKeyPath];
    }];
}



#pragma Cleanup

/// Called usually from dealloc (may be called at any time). Detach all observers. The associated dictionary is released once the deallocation process finishes.
- (void)removeAllObservations {
    [[self.blockObservers allValues] makeObjectsPerformSelector:@selector(detach)];
    [self.blockObservers removeAllObjects];
}



@end


