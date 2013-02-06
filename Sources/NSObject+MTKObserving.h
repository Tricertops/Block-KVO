//
//  NSObject+MTKObserving.h
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTKObserver.h"


/// Transformation blocks that can be used for map methods.
typedef id(^MTKMappingTransformBlock)(id);
extern MTKMappingTransformBlock const MTKMappingIsNilBlock;         // return @( value == nil );
extern MTKMappingTransformBlock const MTKMappingIsNotNilBlock;      // return @(  value != nil );
extern MTKMappingTransformBlock const MTKMappingInvertBooleanBlock; // return @( ! value.boolValue );
extern MTKMappingTransformBlock const MTKMappingURLFromString;      // return [NSURL URLWithString:value];



//////////
@interface NSObject (MTKObserving)



#pragma mark Observe Properties

/**
 Registers observation block for the specified key-path relative to the receiver. **Object should only observe itself,
 so call this method on `self`.**
 
 Observation block is executed immediately and at least once for every change of value in the property.
 The block receives old and new value of the property. First call to this block will have `nil` as `old` and current value as `new`.
 
 This block has also reference to the receiver (which should always be the caller). This internal `self` makes it easier
 to avoid retain cycles. It overrides local variable `self` (method argument) and declares it as weak. **Use of this weak
 `self` inside the block does not create retain cycle.** To make sure “outside” and “inside” `self` variables contains the same
 object, caller should always be the receiver.
 
 If you call this method multiple times on the same key-path it is guaranteed they will be executed in the same order.
 
 @param keyPath
 The key-path, relative to the receiver, of the property to observe. This value must not be `nil`.
 
 @param observationBlock
 Block to be executed when the value on specified key-path changes. This value must not be `nil`.
 */
- (void)observeProperty:(NSString *)keyPath withBlock:(MTKObservationChangeBlock)observationBlock;


/**
 Calls `-observeProperty:withBlock:` for each key-path.
 */
- (void)observeProperties:(NSArray *)keyPaths withBlock:(MTKObservationChangeBlockMany)observationBlock;


/**
 Calls `-observeProperty:withBlock:` with block that performs given selector. Selector may optionaly receive up to two arguments: old and new value.
 */
- (void)observeProperty:(NSString *)keyPath withSelector:(SEL)observationSelector;


/**
 Calls `-observeProperty:withSelector:` for each key-path.
 */
- (void)observeProperties:(NSArray *)keyPaths withSelector:(SEL)observationSelector;



#pragma mark Observe Relationships

/**
 Observe relationship. See KVC documentation for full explanation how relationships work. Basically there are two options:
 
	1. You implement KVC methods for relationship yourself.
 
	2. Use Core Data relationships.
 
 Relationship is a collection object (NSArray, NSSet, NSOrderedSet, maybe some other...) with accessor methods.
 This collection should be modified only through these accessor for changes to be observable.
 There are 3 way how the collection may be modified:
 
	1. Insert one or more objects.
	
	2. Remove one or more objects.
	
	3. Replace one or more objects with the same number of other objects.
 
 In addition there is fourth case of modification - you assign completely new collection object to the property (in case it has setter).
 This method allows you to observe all 4 modifications to the relationship with one call using blocks.
 
 Blocks that receive old and new values have declared arguments type as `id`. They are always of the same class as observed collection.
 Some of the blocks have argument `indexes`. In case of non-indexed collection it contains `nil`.
 This behavior is consistent with standard KVO observation method.
 
 @param changeBlock Called when the collection is completely replaced by new collection. Called also for any other modification type where you do not specify any block.
 @param insertionBlock Called when some objects are inserted into relationship. You receive those objects (in the same collection class) and their indexes (if the colelction is indexed). You may pass nil value and `changeBlock` will be invoked instead.
 @param removalBlock Called when some objects are removed from relationship. You receive those objects (in the same collection class) and their past indexes (if the colelction is indexed). You may pass nil value and `changeBlock` will be invoked instead.
 @param replacementBlock Called when some objects are replacedby other objects. You receive old and new objects (in the same collection class) and indexes (if the colelction is indexed). You may pass nil value and `changeBlock` will be invoked instead.
 
 */
- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(MTKObservationChangeBlock)changeBlock
             insertionBlock:(MTKObservationInsertionBlock)insertionBlock
               removalBlock:(MTKObservationRemovalBlock)removalBlock
           replacementBlock:(MTKObservationReplacementBlock)replacementBlock;

/**
 Calls `-observeRelationship:changeBlock:insertionBlock:removalBlock:replacementBlock:` with only change block.
 */
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKObservationChangeBlock)changeBlock;



#pragma mark Map Properties

/**
 Creates one direntional binding from source to destination key-paths. This method calls `-observeProperty:withBlock:`,
 so the same rules apply.
 
 This method begins observing the source key-path and everytime time value changes, executes transformatinon block, if
 any. Then it sets this value to destination key-path.
 
 Method is recursion-safe, so you can create bi-directional bindings.
 
 @param sourceKeyPath
 Key-path relative to the receiver that will be observed. This value must not be `nil`.
 
 @param destinationKeyPath
 Key-path relative to the receiver whose value will be set everytime the source chanegs. This value must not be `nil`.
 
 @param transformationBlock
 Optional block that takes the value from source as argument and its returned value will be set to destination. Here you
 are supposed to make any transformations needed. There is no internal check for returned value.
 */
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath transform:(id (^)(id value))transformationBlock;


/**
 Calls `-map:to:transform:` with transformation block that replaces `nil` value by given object.
 */
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath null:(id)nullReplacement;



#pragma mark Notifications

/**
 Registers block observer using NSNotificationCenter and current operation queue.
 See `-[NSNotificationCenter addObserverForName:object:queue:usingBlock:]` for more info.
 
 Once you call -removeAllObservations, all those blocks are removed from notification center.
 */
- (void)observeNotification:(NSString *)name fromObject:(id)object withBlock:(MTKObservationNotificationBlock)block;


/**
 Calls `-observeNotification:fromObject:withBlock:` with nil object.
 */
- (void)observeNotification:(NSString *)name withBlock:(MTKObservationNotificationBlock)block;


/**
 Calls `-observeNotification:fromObject:withBlock:` fro each combination of name and object. Objects may be nil, but can not be an empty array, because nothign will be registered.
 */
- (void)observeNotifications:(NSArray *)names fromObjects:(NSArray *)objects withBlock:(MTKObservationNotificationBlock)block;



#pragma mark Removing

/**
 Removes all observations registered with the receiver. Should be always called on `self` in `-dealloc` method.
 */
- (void)removeAllObservations;



@end
