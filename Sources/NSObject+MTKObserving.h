//
//  NSObject+MTKObserving.h
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTKObserver.h"



//////////
@interface NSObject (MTKObserving)



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


/**
 (To be added.)
 */
- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(MTKObservationChangeBlock)changeBlock
             insertionBlock:(MTKObservationInsertionBlock)insertionBlock
               removalBlock:(MTKObservationRemovalBlock)removalBlock
           replacementBlock:(MTKObservationReplacementBlock)replacementBlock;

/**
 Calls `- (void)observeRelationship:changeBlock:insertionBlock:removalBlock:replacementBlock:` with only change block.
 */
- (void)observeRelationship:(NSString *)keyPath changeBlock:(MTKObservationChangeBlock)changeBlock;


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
 Calls `- (void)map:to:transform:` with transformation block that replaces `nil` value by given object.
 */
- (void)map:(NSString *)sourceKeyPath to:(NSString *)destinationKeyPath null:(id)nullReplacement;


/**
 Removes all observations registered with the receiver. Should be always called on `self` in `-dealloc` method.
 */
- (void)removeAllObservations;



@end
