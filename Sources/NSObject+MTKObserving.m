//
//  NSObject+MTKObserving.m
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "NSObject+MTKObserving.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MTKObserver.h"





///////////////
@implementation NSObject (MTKObserving)



#pragma mark Internal

/// Getter for dictionary containing all registered observers for this object. Keys are observed key-paths.
- (NSMutableDictionary *)mtk_keyPathBlockObservers {
    // Observer is hidden object that has target this object (`self`) and specific key path.
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

/// Find existing observer or create new for this key-path and owner. Multiple uses of one key-path per owner return the same observer.
- (MTKObserver *)mtk_observerForKeyPath:(NSString *)keyPath owner:(id)owner {
	MTKObserver *observer = nil;
    // Key path is used as key to retrieve observer.
	// For one key-path may be more observers with different owners.
    NSMutableSet *observersForKeyPath = [[self mtk_keyPathBlockObservers] objectForKey:keyPath];
	if ( ! observersForKeyPath) {
		observersForKeyPath = [[NSMutableSet alloc] init];
		[[self mtk_keyPathBlockObservers] setObject:observersForKeyPath forKey:keyPath];
	}
	else {
		for (MTKObserver *existingObserver in observersForKeyPath) {
			if (existingObserver.owner == owner) {
				observer = existingObserver;
				break;
			}
		}
	}
	if ( ! observer) {
		observer = [[MTKObserver alloc] initWithTarget:self keyPath:keyPath owner:owner];
        [observersForKeyPath addObject:observer];
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
- (void)observeProperty:(NSString *)keyPath withBlock:(MTKBlockChange)observationBlock {
    [self observeObject:self property:keyPath withBlock:observationBlock];
}

/// Register the block for all given key-paths.
- (void)observeProperties:(NSArray *)keyPaths withBlock:(MTKBlockChangeMany)observationBlock {
    [self observeObject:self properties:keyPaths withBlock:observationBlock];
}

/// Register block invoking given selector. Smart detecting of number of arguments.
- (void)observeProperty:(NSString *)keyPath withSelector:(SEL)observationSelector {
	[self observeObject:self property:keyPath withSelector:observationSelector];
}

/// Register the selector for each key-path.
- (void)observeProperties:(NSArray *)keyPaths withSelector:(SEL)observationSelector {
    [self observeObject:self properties:keyPaths withSelector:observationSelector];
}



#pragma mark Foreign Property

- (void)observeObject:(id)object property:(NSString *)keyPath withBlock:(MTKObservationForeignChangeBlock)observationBlock {
	MTKObserver *observer = [object mtk_observerForKeyPath:keyPath owner:self];
	[observer addSettingObservationBlock:observationBlock];
}

- (void)observeObject:(id)object property:(NSString *)keyPath withSelector:(SEL)observationSelector {
	NSMethodSignature *signature = [self methodSignatureForSelector:observationSelector];
    NSInteger numberOfArguments = [signature numberOfArguments];
	[self observeObject:object property:keyPath withBlock:^(__weak id object, id old, id new) {
		switch (numberOfArguments) {
            case 0:
            case 1:
                [NSException raise:NSInternalInconsistencyException format:@"WTF?! Method should have at least two arguments: self and _cmd!"];
                break;
                
            case 2: // +0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:observationSelector];
                break;
                
            case 3: // +1
                [self performSelector:observationSelector withObject:new];
                break;
            
			case 4: // +2
				[self performSelector:observationSelector withObject:old withObject:new];
#pragma clang diagnostic pop
				
            default:// +3
				// Fuck off NSInvocation!
                objc_msgSend(self, observationSelector, object, old, new);
                break;
        }
	}];
}

- (void)observeObject:(id)object properties:(NSArray *)keyPaths withBlock:(MTKObservationForeignChangeBlockMany)observationBlock {
	for (NSString *keyPath in keyPaths) {
        [self observeObject:object property:keyPath withBlock:^(__weak id weakObject, id old , id new){
            observationBlock(weakObject, keyPath, old, new);
        }];
    }
}

- (void)observeObject:(id)object properties:(NSArray *)keyPaths withSelector:(SEL)observationSelector {
	for (NSString *keyPath in keyPaths) {
        [self observeObject:object property:keyPath withSelector:observationSelector];
    }
}




#pragma mark Observe Relationships

/// Add observation blocks to appropriate observer. If some block was not specified, use the `changeBlock`.
- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(MTKBlockChange)changeBlock
             insertionBlock:(MTKBlockInsert)insertionBlock
               removalBlock:(MTKBlockRemove)removalBlock
           replacementBlock:(MTKBlockReplace)replacementBlock
{
    MTKObserver *observer = [self mtk_observerForKeyPath:keyPath owner:self];
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
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKBlockGeneric)changeBlock {
    [self observeRelationship:keyPath
                  changeBlock:^(__weak id weakSelf, id old, id new) {
                      changeBlock(weakSelf);
                  }
               insertionBlock:nil
                 removalBlock:nil
             replacementBlock:nil];
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
- (void)observeNotification:(NSString *)name withBlock:(MTKBlockNotify)block {
	[self observeNotification:name fromObject:nil withBlock:block];
}

/// Add block observer on current operation queue and the resulting internal opaque observe is stored in associated mutable set.
- (void)observeNotification:(NSString *)name fromObject:(id)object withBlock:(MTKBlockNotify)block {
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
- (void)observeNotifications:(NSArray *)names fromObjects:(NSArray *)objects withBlock:(MTKBlockNotify)block {
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
	
    NSMutableDictionary *keyPathBlockObservers = [self mtk_keyPathBlockObservers];
	for (NSMutableSet *observersForKeyPath in [[self mtk_keyPathBlockObservers] allValues]) {
		for (MTKObserver *observer in observersForKeyPath) {
			[observer detach];
			[observersForKeyPath removeObject:observer];
		}
	}
    [keyPathBlockObservers removeAllObjects];
	
	NSMutableSet *notificationObservers = [self mtk_notificationBlockObservers];
	for (id internalObserver in notificationObservers) {
		[[NSNotificationCenter defaultCenter] removeObserver:internalObserver];
	}
	[notificationObservers removeAllObjects];
}

- (void)removeAllObservationsOfObject:(id)object {
	[object mtk_removeAllObservationsForOwner:self];
}

- (void)mtk_removeAllObservationsForOwner:(id)owner {
	for (NSMutableSet *observersForKeyPath in [[self mtk_keyPathBlockObservers] allValues]) {
		for (MTKObserver *observer in observersForKeyPath) {
			if (observer.owner == owner) {
				[observer detach];
				[observersForKeyPath removeObject:observer];
			}
		}
	}
}



@end





//////////
MTKMappingTransformBlock const MTKMappingIsNilBlock = ^NSNumber *(id value){
    return @( value == nil );
};

MTKMappingTransformBlock const MTKMappingIsNotNilBlock = ^NSNumber *(id value){
    return @( value != nil );
};

MTKMappingTransformBlock const MTKMappingInvertBooleanBlock = ^NSNumber *(NSNumber *value){
    return @( ! value.boolValue );
};

MTKMappingTransformBlock const MTKMappingURLFromStringBlock = ^NSURL *(NSString *value){
    return [NSURL URLWithString:value];
};


