//
//  MTKBlockObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTKBlockObservationTypes.h"



@interface MTKBlockObserver : NSObject

+ (NSUInteger)livingBlockObservers;
+ (MTKBlockObservationKind)kind; //abstract

@property (nonatomic, readonly, assign) NSObject *object;
@property (nonatomic, readonly, copy) id keyPath;
@property (nonatomic, readonly, copy) id beforeBlock;
@property (nonatomic, readonly, copy) id afterBlock;
@property (nonatomic, readwrite) BOOL attached;
@property (nonatomic, readwrite) BOOL active;

- (id)init;
- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(id)beforeBlock
          afterBlock:(id)afterBlock;
- (void)dealloc;

- (MTKBlockObservationKind)kind;
- (BOOL)shouldObserveChangeKind:(NSKeyValueChange)changeKind;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;
- (void)observeBeforeChange:(NSDictionary *)change; //abstract
- (void)observeAfterChange:(NSDictionary *)change; //abstract

- (void)attach; //start observing
- (void)detach; //end observing

- (void)activate; //calls blocks
- (void)deactivate; //dont call blocks

@end
