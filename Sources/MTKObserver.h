//
//  MTKObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 28.9.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark Block Typedefs

typedef void(^MTKBlockGeneric)          (id self, id newValue);
typedef void(^MTKBlockChange)           (id self, id oldValue, id newValue);
typedef void(^MTKBlockChangeMany)       (id self, NSString *keyPath, id oldValue, id newValue);
typedef void(^MTKBlockInsert)           (id self, id newValue, NSIndexSet *indexes);
typedef void(^MTKBlockRemove)           (id self, id oldValue,  NSIndexSet *indexes);
typedef void(^MTKBlockReplace)          (id self, id oldValue, id newValue, NSIndexSet *indexes);

typedef void(^MTKBlockForeignChange)    (id self, id object, id oldValue, id newValue);
typedef void(^MTKBlockForeignChangeMany)(id self, id object, NSString *keyPath, id oldValue, id newValue);

typedef void(^MTKBlockNotify)           (id self, NSNotification *notification);





/**
 This is private class. This is the object that holds observation blocks and observes given property using standatd KVO.
 For multiple observations of the same key-path (and object) only one observer is used.
 */
@interface MTKObserver : NSObject


#pragma mark Initialization
/// Do not use. Observation target will be nil, so any calls to it will have no effect.
- (id)init;
/// Designated initializer.
- (id)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner;


#pragma mark Ownership
/// Object that 'owns' all blocks in this observer. This object was the caller of observation method.
@property (nonatomic, readonly, assign) id owner;


#pragma mark Attaching
/// Attached means, that this object really observes the key-path it was initialized with. Set it to add/remove this observer.
@property (nonatomic, readwrite, assign) BOOL attached;
/// Convenience method to set `attached` to YES.
- (void)attach;
/// Convenience method to set `attached` to NO.
- (void)detach;


#pragma mark Blocks
/// Add block to be executed on key-path setting of simple property or relationship.
- (void)addSettingObservationBlock:(MTKBlockChange)block;
/// Add block to be executed on key-path relationship insertion.
- (void)addInsertionObservationBlock:(MTKBlockInsert)block;
/// Append block to be executed on key-path relationship removal.
- (void)addRemovalObservationBlock:(MTKBlockRemove)block;
/// Add block to be executed on key-path relationship replacement.
- (void)addReplacementObservationBlock:(MTKBlockReplace)block;


@end
