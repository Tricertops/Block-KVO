//
//  MTKDeallocator.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 21.11.15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import "MTKDeallocator.h"
#import <objc/runtime.h>



@interface MTKDeallocator : NSObject

@property (readonly, unsafe_unretained) NSObject *owner;
@property (readonly) NSMutableArray<MTKDeallocatorCallback> *callbacks;

@end



@implementation MTKDeallocator


- (instancetype)initWithOwner:(NSObject*)owner {
    self = [super init];
    if (self) {
        self->_owner = nil;
        self->_callbacks = [NSMutableArray new];
    }
    return self;
}


- (void)addCallback:(MTKDeallocatorCallback)block {
    if (block)
        [self->_callbacks addObject:block];
}


- (void)invokeCallbacks {
    __unsafe_unretained NSObject *owner = self->_owner;
    for (MTKDeallocatorCallback block in self->_callbacks)
        block(owner);
}


- (void)dealloc {
    [self invokeCallbacks];
}


@end



@implementation NSObject (MTKDeallocator)


static const void * MTKDeallocatorAssociationKey = &MTKDeallocatorAssociationKey;


- (void)mtk_addDeallocationCallback:(MTKDeallocatorCallback)block {
    @synchronized(self) {
        @autoreleasepool {
            MTKDeallocator *deallocator = objc_getAssociatedObject(self, MTKDeallocatorAssociationKey);
            if ( ! deallocator) {
                deallocator = [[MTKDeallocator alloc] initWithOwner:self];
                objc_setAssociatedObject(self, MTKDeallocatorAssociationKey, deallocator, OBJC_ASSOCIATION_RETAIN);
            }
            [self.class swizzleDeallocIfNeeded];
            [deallocator addCallback:block];
        }
    }
}


+ (BOOL)swizzleDeallocIfNeeded {
    static NSMutableSet *swizzledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    @synchronized(self) {
        if ([swizzledClasses containsObject:self]) return NO;
        
        SEL deallocSelector = NSSelectorFromString(@"dealloc");
        Method dealloc = class_getInstanceMethod(self, deallocSelector);
        
        void (*oldImplementation)(id, SEL) = (typeof(oldImplementation))method_getImplementation(dealloc);
        void(^newDeallocBlock)(id) = ^(__unsafe_unretained NSObject *self_deallocating) {
            
            // New dealloc implementation:
            MTKDeallocator *decomposer = objc_getAssociatedObject(self_deallocating, MTKDeallocatorAssociationKey);
            [decomposer invokeCallbacks];
            
            // Calling existing implementation.
            oldImplementation(self_deallocating, deallocSelector);
        };
        IMP newImplementation = imp_implementationWithBlock(newDeallocBlock);
        
        class_replaceMethod(self, deallocSelector, newImplementation, method_getTypeEncoding(dealloc));
        
        [swizzledClasses addObject:self];
        
        return YES;
    }
}



@end


