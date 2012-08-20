//
//  MTKReplacementBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKReplacementBlockObserver.h"



@implementation MTKReplacementBlockObserver



+ (MTKBlockObservationKind)kind {
    return MTKBlockObservationKindReplacement;
}

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
          afterBlock:(void(^)(id, id, NSIndexSet *))afterBlock {
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
    id newValues = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValues == [NSNull null]) newValues = nil;
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    
    void (^afterBlock)(id, id, NSIndexSet *) = self.afterBlock;
    afterBlock(oldValues, newValues, indexes);
}

- (BOOL)shouldObserveChangeKind:(NSKeyValueChange)changeKind {
    return (changeKind == NSKeyValueChangeReplacement);
}



@end









@implementation MTKBlockObserver (MTKReplacementBlockObserver)



+ (id)replacementBlockObserverWithObject:(NSObject *)object
                                 keyPath:(NSString *)keyPath
                             beforeBlock:(void(^)(id, NSIndexSet *))beforeBlock
                              afterBlock:(void(^)(id, id, NSIndexSet *))afterBlock {
    return [[MTKReplacementBlockObserver alloc] initWithObject:object
                                                       keyPath:keyPath
                                                   beforeBlock:beforeBlock
                                                    afterBlock:afterBlock];
}



@end


