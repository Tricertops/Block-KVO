//
//  MTKChangeBlockObserver.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKBlockObserver.h"



@interface MTKChangeBlockObserver : MTKBlockObserver

+ (MTKBlockObservationKind)kind;

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(id oldValue))beforeBlock
          afterBlock:(void(^)(id newValue))afterBlock;

- (void)observeBeforeChange:(NSDictionary *)change;
- (void)observeAfterChange:(NSDictionary *)change;

@end



@interface MTKBlockObserver (MTKChangeBlockObserver)

+ (id)changeBlockObserverWithObject:(NSObject *)object
                      keyPath:(NSString *)keyPath
                  beforeBlock:(void(^)(id oldValue))beforeBlock
                   afterBlock:(void(^)(id newValue))afterBlock;

@end
