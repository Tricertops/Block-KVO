//
//  MTKInsertionBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKInsertionBlockObserver.h"



@implementation MTKInsertionBlockObserver



+ (MTKBlockObservationKind)kind {
    return MTKBlockObservationKindInsertion;
}

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(NSIndexSet *))beforeBlock
          afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    return [super initWithObject:object
                         keyPath:keyPath
                     beforeBlock:beforeBlock
                      afterBlock:afterBlock];
}

- (void)observeBeforeChange:(NSDictionary *)change {
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    
    void (^beforeBlock)(NSIndexSet *) = self.beforeBlock;
    beforeBlock(indexes);
}

- (void)observeAfterChange:(NSDictionary *)change {
    id newValues = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValues == [NSNull null]) newValues = nil;
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    
    void (^afterBlock)(id, NSIndexSet *) = self.afterBlock;
    afterBlock(newValues, indexes);
}



@end









@implementation MTKBlockObserver (MTKInsertionBlockObserver)



+ (id)insertionBlockObserverWithObject:(NSObject *)object
                             keyPath:(NSString *)keyPath
                         beforeBlock:(void(^)(NSIndexSet *))beforeBlock
                          afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    return [[MTKInsertionBlockObserver alloc] initWithObject:object
                                                     keyPath:keyPath
                                                 beforeBlock:beforeBlock
                                                  afterBlock:afterBlock];
}



@end


