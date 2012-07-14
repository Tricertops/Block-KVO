//
//  MTKChangeBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKChangeBlockObserver.h"









@implementation MTKChangeBlockObserver



+ (MTKBlockObservationKind)kind {
    return MTKBlockObservationKindChange;
}



- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void (^)(id))beforeBlock
          afterBlock:(void (^)(id))afterBlock {
    return [super initWithObject:object
                         keyPath:keyPath
                     beforeBlock:beforeBlock
                      afterBlock:afterBlock];
}



- (void)observeBeforeChange:(NSDictionary *)change {
    void (^beforeBlock)(id) = self.beforeBlock;
    beforeBlock([self.object valueForKeyPath:self.keyPath]);
}

- (void)observeAfterChange:(NSDictionary *)change {
    void (^afterBlock)(id) = self.afterBlock;
    afterBlock([self.object valueForKeyPath:self.keyPath]);
}



@end









@implementation MTKBlockObserver (MTKChangeBlockObserver)



+ (id)changeBlockObserverWithObject:(NSObject *)object
                      keyPath:(NSString *)keyPath
                  beforeBlock:(void(^)(id))beforeBlock
                   afterBlock:(void(^)(id))afterBlock {
    return [[MTKChangeBlockObserver alloc] initWithObject:object
                                                  keyPath:keyPath
                                              beforeBlock:beforeBlock
                                               afterBlock:afterBlock];
}



@end


