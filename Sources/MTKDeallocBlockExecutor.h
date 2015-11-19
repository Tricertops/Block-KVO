//
//  MTKDeallocBlockExecutor.h
//  Block Key-Value Observing
//
//  Created by Yanjun Zhuang on 18/11/15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTKDeallocBlockExecutor : NSObject
@property (nonatomic, copy) void (^deallocBlock)();

+ (instancetype)executorWithDellocBlock:(void (^)())deallocBlock;
@end
