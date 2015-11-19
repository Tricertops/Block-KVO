//
//  NSObject+MTKDeallocBlock.m
//  Block Key-Value Observing
//
//  Created by Yanjun Zhuang on 18/11/15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import "NSObject+MTKDeallocBlock.h"
#import <objc/runtime.h>
#import "MTKDeallocBlockExecutor.h"

@implementation NSObject (MTKDeallocBlock)
- (id)mtk_addDeallocBlock:(void (^)())deallocBlock
{
    static char associationKey;
    if (deallocBlock == nil) {
        return nil;
    }
    
    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, &associationKey);
    if (deallocBlocks == nil) {
        deallocBlocks = [NSMutableArray array];
        objc_setAssociatedObject(self, &associationKey, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    // Check if the block is already existed
    for (MTKDeallocBlockExecutor *executor in deallocBlocks) {
        if (executor.deallocBlock == deallocBlock) {
            return nil;
        }
    }
    
    MTKDeallocBlockExecutor *executor = [MTKDeallocBlockExecutor executorWithDellocBlock:deallocBlock];
    [deallocBlocks addObject:executor];
    return executor;
}
@end
