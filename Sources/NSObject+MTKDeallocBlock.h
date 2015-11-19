//
//  NSObject+MTKDeallocBlock.h
//  Block Key-Value Observing
//
//  Created by Yanjun Zhuang on 18/11/15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MTKDeallocBlock)
- (id)mtk_addDeallocBlock:(void (^)())deallocBlock;
@end
