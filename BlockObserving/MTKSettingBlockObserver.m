//
//  MTKSettingBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKSettingBlockObserver.h"









@implementation MTKSettingBlockObserver



+ (MTKBlockObservationKind)kind {
    return MTKBlockObservationKindSetting;
}



- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(void(^)(id))beforeBlock
          afterBlock:(void(^)(id, id))afterBlock {
    return [super initWithObject:object
                         keyPath:keyPath
                     beforeBlock:beforeBlock
                      afterBlock:afterBlock];
}



- (void)observeBeforeChange:(NSDictionary *)change {
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValue == [NSNull null]) oldValue = nil;
    
    void (^beforeBlock)(id) = self.beforeBlock;
    beforeBlock(oldValue);
}

- (void)observeAfterChange:(NSDictionary *)change {
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValue == [NSNull null]) oldValue = nil;
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) newValue = nil;
    
    void (^afterBlock)(id, id) = self.afterBlock;
    afterBlock(oldValue, newValue);
}

- (BOOL)shouldObserveChangeKind:(NSKeyValueChange)changeKind {
    return (changeKind == NSKeyValueChangeSetting);
}



@end









@implementation MTKBlockObserver (MTKSettingBlockObserver)



+ (id)settingBlockObserverWithObject:(NSObject *)object
                             keyPath:(NSString *)keyPath
                         beforeBlock:(void(^)(id))beforeBlock
                          afterBlock:(void(^)(id, id))afterBlock {
    return [[MTKSettingBlockObserver alloc] initWithObject:object
                                                   keyPath:keyPath
                                               beforeBlock:beforeBlock
                                                afterBlock:afterBlock];
}



@end


