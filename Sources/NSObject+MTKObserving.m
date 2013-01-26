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
- (NSMutableDictionary *)mtk_keyPathBlockObservers {
    // Observer is a shadow object that has target this object (`self`) and specific key path.
    // There should never exist two or more observers with the same target AND key path.
    // Observer has multiple observation block which are executed in order they were added.
    static char associationKey;
    NSMutableDictionary *keyPathObservers = objc_getAssociatedObject(self, &associationKey);
    if ( ! keyPathObservers) {
        keyPathObservers = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self,
                                 &associationKey,
                                 keyPathObservers,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return keyPathObservers;
}

/// Find existing observer or create new for this key-path. Multiple uses of one key-path return the same observer.
- (MTKObserver *)mtk_observerForKeyPath:(NSString *)keyPath {
    // Key path is used as key to retrieve observer.
    MTKObserver *observer = [[self mtk_keyPathBlockObservers] objectForKey:keyPath];
    if ( ! observer) {
        observer = [[MTKObserver alloc] initWithTarget:self keyPath:keyPath];
        [self.mtk_keyPathBlockObservers setObject:observer forKey:keyPath];
        [observer attach];
    }
    return observer;
}

/// Getter for set containing all registered notification observers for this object. See `NSNotificationCenter`.
- (NSMutableSet *)mtk_notificationBlockObservers {
    static char associationKey;
    NSMutableSet *notificationObservers = objc_getAssociatedObject(self, &associationKey);
    if ( ! notificationObservers) {
        notificationObservers = [[NSMutableSet alloc] init];
        objc_setAssociatedObject(self,
                                 &associationKey,
                                 notificationObservers,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return notificationObservers;
}



#pragma mark Observe Properties

/// Add observation block to appropriate observer for setting the value.
- (void)observeProperty:(NSString *)keyPath withBlock:(MTKObservationChangeBlock)observationBlock {
    MTKObserver *observer = [self mtk_observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:observationBlock];
}

/// Copy the block and register it for all given key-paths.
- (void)observeProperties:(NSArray *)keyPaths withBlock:(MTKObservationChangeBlockMany)observationBlock {
    for (NSString *keyPath in keyPaths) {
        [self observeProperty:keyPath withBlock:^(__weak id weakSelf, id old , id new){
            observationBlock(weakSelf, keyPath, old, new);
        }];
    }
}

/// Register block invoking given selector. Smart detecting of number of arguments.
- (void)observeProperty:(NSString *)keyPath withSelector:(SEL)observationSelector {
    NSMethodSignature *signature = [self methodSignatureForSelector:observationSelector];
    NSInteger numberOfArguments = [signature numberOfArguments];
    [self observeProperty:keyPath withBlock:^(__weak id weakSelf, id old, id new) {
        switch (numberOfArguments) {
            case 0:
            case 1:
                [NSException raise:NSInternalInconsistencyException format:@"WTF?! Method should have at least two arguments: self and _cmd!"];
                break;
                
            case 2:
                [weakSelf performSelector:observationSelector];
                break;
                
            case 3:
                [weakSelf performSelector:observationSelector withObject:new];
                break;
                
            default:
                [weakSelf performSelector:observationSelector withObject:old withObject:new];
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



#pragma mark Observe Relationships

/// Add observation blocks to appropriate observer. If some block was not specified, use the `changeBlock`.
- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(MTKObservationChangeBlock)changeBlock
             insertionBlock:(MTKObservationInsertionBlock)insertionBlock
               removalBlock:(MTKObservationRemovalBlock)removalBlock
           replacementBlock:(MTKObservationReplacementBlock)replacementBlock
{
    MTKObserver *observer = [self mtk_observerForKeyPath:keyPath];
    [observer addSettingObservationBlock:changeBlock];
    [observer addInsertionObservationBlock: insertionBlock ?: ^(__weak id weakSelf, id new, NSIndexSet *indexes) {
        // If no insertion block was specified, call general change block.
        changeBlock(weakSelf, nil, [weakSelf valueForKeyPath:keyPath]);
    }];
    [observer addRemovalObservationBlock: removalBlock ?: ^(__weak id weakSelf, id old, NSIndexSet *indexes) {
        // If no removal block was specified, call general change block.
        changeBlock(weakSelf, nil, [weakSelf valueForKeyPath:keyPath]);
    }];
    [observer addReplacementObservationBlock: replacementBlock ?: ^(__weak id weakSelf, id old, id new, NSIndexSet *indexes) {
        // If no removal block was specified, call general change block.
        changeBlock(weakSelf, nil, [weakSelf valueForKeyPath:keyPath]);
    }];
}

/// Call main `-observeRelationship:...` method with only first argument.
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKObservationChangeBlock)changeBlock {
    [self observeRelationship:keyPath changeBlock:changeBlock insertionBlock:nil removalBlock:nil replacementBlock:nil];
}



#pragma mark Map Properties

/// Call `-map:to:transform:` with transform block that uses returns the same value, or null replacement.
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath null:(id)nullReplacement {
    [self map:sourceKeyPath to:destinationKeyPath transform:^id(id value) {
        return value ?: nullReplacement;
    }];
}

/// Observe source key-path and set its new value to destination every time it changes. Use transformation block, if specified.
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath transform:(id (^)(id))transformationBlock {
    [self observeProperty:sourceKeyPath withBlock:^(__weak id weakSelf, id old, id new) {
        id transformedValue = (transformationBlock? transformationBlock(new) : new);
        [weakSelf setValue:transformedValue forKeyPath:destinationKeyPath];
    }];
}



#pragma mark Notifications

/// Call another one.
- (void)observeNotification:(NSString *)name withBlock:(MTKObservationNotificationBlock)block {
	[self observeNotification:name fromObject:nil withBlock:block];
}

/// Add block observer on current operation queue and the resulting internal opaque observe is stored in associated mutable set.
- (void)observeNotification:(NSString *)name fromObject:(id)object withBlock:(MTKObservationNotificationBlock)block {
	__weak typeof(self) weakSelf = self;
	id internalObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name
																			object:object
																			 queue:[NSOperationQueue currentQueue]
																		usingBlock:^(NSNotification *notification) {
																			block(weakSelf, notification);
																		}];
	[[self mtk_notificationBlockObservers] addObject:internalObserver];
}

/// Make all combination of name and object (if any are given) and call main notification observing method.
- (void)observeNotifications:(NSArray *)names fromObjects:(NSArray *)objects withBlock:(MTKObservationNotificationBlock)block {
	for (NSString *name in names) {
		if (objects) {
			for (id object in objects) {
				[self observeNotification:name fromObject:object withBlock:block];
			}
		}
		else {
			[self observeNotification:name fromObject:nil withBlock:block];
		}
	}
}



#pragma Removing

/// Called usually from dealloc (may be called at any time). Detach all observers. The associated objects are released once the deallocation process finishes.
- (void)removeAllObservations {
	
    NSMutableDictionary *keyPathBlockObservers = [self mtk_keyPathBlockObservers ];
    [[keyPathBlockObservers allValues] makeObjectsPerformSelector:@selector(detach)];
    [keyPathBlockObservers removeAllObjects];
	
	NSMutableSet *notificationObservers = [self mtk_notificationBlockObservers];
	for (id internalObserver in notificationObservers) {
		[[NSNotificationCenter defaultCenter] removeObserver:internalObserver];
	}
	[notificationObservers removeAllObjects];
}



@end


