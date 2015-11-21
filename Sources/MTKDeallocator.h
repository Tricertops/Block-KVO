//
//  MTKDeallocator.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 21.11.15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef void(^MTKDeallocatorCallback)(id receiver);



@interface NSObject (MTKDeallocator)

- (void)mtk_addDeallocationCallback:(MTKDeallocatorCallback)block;

@end


