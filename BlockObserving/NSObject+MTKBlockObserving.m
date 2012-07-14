//
//  NSObject+MTKBlockObserving.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "NSObject+MTKBlockObserving.h"

#import <objc/runtime.h>



@interface NSObject (MTKBlockObserving_Private)

@end






@implementation NSObject (MTKBlockObserving)



- (NSSet *)mtk_blockObservers {
    static void *_mtk_blockObservers_associationKey;
    NSMutableSet *blockObservers = objc_getAssociatedObject(self, _mtk_blockObservers_associationKey);
    if ( ! blockObservers) {
        blockObservers = [[NSMutableSet alloc] init];
        objc_setAssociatedObject(self, _mtk_blockObservers_associationKey, blockObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return blockObservers;
}



@end
