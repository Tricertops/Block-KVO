//
//  MTKObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 28.9.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MTKObserver : NSObject

@property (nonatomic, readwrite, assign) BOOL attached;
- (void)attach;
- (void)detach;

- (id)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath;

- (void)addSettingObservationBlock:(void (^)(__weak id self, id old, id new))block;
- (void)addInsertionObservationBlock:(void (^)(__weak id self, id new, NSIndexSet *indexes))block;
- (void)addRemovalObservationBlock:(void (^)(__weak id self, id old, NSIndexSet *indexes))block;
- (void)addReplacementObservationBlock:(void (^)(__weak id self, id old, id new, NSIndexSet *indexes))block;

@end
