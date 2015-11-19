//
//  MTKDeallocExecutor.m
//  Block Key-Value Observing
//
//  Created by Yanjun Zhuang on 18/11/15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import "MTKDeallocBlockExecutor.h"

@implementation MTKDeallocBlockExecutor
+ (instancetype)executorWithDellocBlock:(void (^)())deallocBlock
{
    MTKDeallocBlockExecutor *executor = [[self alloc] init];
    executor.deallocBlock = deallocBlock;
    return executor;
}

- (void)dealloc
{
    if (self.deallocBlock) {
        self.deallocBlock();
        self.deallocBlock = nil;
    }
}
@end
