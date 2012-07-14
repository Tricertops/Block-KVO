//
//  MTKInsertionBlockObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKBlockObserver.h"



@interface MTKInsertionBlockObserver : MTKBlockObserver

+ (MTKBlockObservationKind)kind;

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(NSIndexSet *indexes))beforeBlock
          afterBlock:(void(^)(id newValues,
                              NSIndexSet *indexes))afterBlock;

- (void)observeBeforeChange:(NSDictionary *)change;
- (void)observeAfterChange:(NSDictionary *)change;

@end



@interface MTKBlockObserver (MTKInsertionBlockObserver)

+ (id)insertionBlockObserverWithObject:(NSObject *)object
                               keyPath:(NSString *)keyPath
                           beforeBlock:(void(^)(NSIndexSet *indexes))beforeBlock
                            afterBlock:(void(^)(id newValues,
                                                NSIndexSet *indexes))afterBlock;
@end
