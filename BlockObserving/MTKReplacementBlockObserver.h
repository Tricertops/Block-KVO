//
//  MTKReplacementBlockObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKBlockObserver.h"



@interface MTKReplacementBlockObserver : MTKBlockObserver

+ (MTKBlockObservationKind)kind;

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(id oldValues,
                              NSIndexSet *indexes))beforeBlock
          afterBlock:(void(^)(id oldValues,
                              id newValues,
                              NSIndexSet *indexes))afterBlock;

- (void)observeBeforeChange:(NSDictionary *)change;
- (void)observeAfterChange:(NSDictionary *)change;

@end



@interface MTKBlockObserver (MTKReplacementBlockObserver)

+ (id)replacementBlockObserverWithObject:(NSObject *)object
                                 keyPath:(NSString *)keyPath
                             beforeBlock:(void(^)(id oldValues,
                                                  NSIndexSet *indexes))beforeBlock
                              afterBlock:(void(^)(id oldValues,
                                                  id newValues,
                                                  NSIndexSet *indexes))afterBlock;
@end
