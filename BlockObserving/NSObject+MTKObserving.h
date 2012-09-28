//
//  NSObject+MTKObserving.h
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTKObserver.h"



@interface NSObject (MTKObserving)



- (void)observeProperty:(NSString *)keyPath
              withBlock:(void (^)(__weak id self,
                                  id old,
                                  id new))observationBlock;

- (void)map:(NSString *)sourceKeyPath
         to:(NSString *)destinationKeyPath
  transform:(id (^)(id value))transformationBlock;

- (void)observeRelationship:(NSString *)keyPath
                changeBlock:(void (^)(id self,
                                      id old,
                                      id new))changeBlock
             insertionBlock:(void (^)(id self,
                                      id news,
                                      NSIndexSet *indexes))insertionBlock
               removalBlock:(void (^)(id self,
                                      id olds,
                                      NSIndexSet *indexes))removalBlock
           replacementBlock:(void (^)(id self,
                                      id olds,
                                      id news,
                                      NSIndexSet *indexes))replacementBlock;

- (void)removeAllObservations;



@end
