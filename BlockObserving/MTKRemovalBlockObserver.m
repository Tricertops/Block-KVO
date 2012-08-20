//
//  MTKRemovalBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKRemovalBlockObserver.h"



@implementation MTKRemovalBlockObserver



+ (MTKBlockObservationKind)kind {
    return MTKBlockObservationKindRemoval;
}

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
          afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    return [super initWithObject:object
                         keyPath:keyPath
                     beforeBlock:beforeBlock
                      afterBlock:afterBlock];
}

- (void)observeBeforeChange:(NSDictionary *)change {
    id oldValues = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValues == [NSNull null]) oldValues = nil;
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    
    void (^beforeBlock)(id, NSIndexSet *) = self.beforeBlock;
    beforeBlock(oldValues, indexes);
}

- (void)observeAfterChange:(NSDictionary *)change {
    id oldValues = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValues == [NSNull null]) oldValues = nil;
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    
    void (^afterBlock)(id, NSIndexSet *) = self.afterBlock;
    afterBlock(oldValues, indexes);
}

- (BOOL)shouldObserveChangeKind:(NSKeyValueChange)changeKind {
    return (changeKind == NSKeyValueChangeRemoval);
}



@end









@implementation MTKBlockObserver (MTKRemovalBlockObserver)



+ (id)removalBlockObserverWithObject:(NSObject *)object
                             keyPath:(NSString *)keyPath
                         beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
                          afterBlock:(void(^)(id, NSIndexSet *))afterBlock {
    return [[MTKRemovalBlockObserver alloc] initWithObject:object
                                                   keyPath:keyPath
                                               beforeBlock:beforeBlock
                                                afterBlock:afterBlock];
}



@end


