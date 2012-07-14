//
//  MTKBlockObservationTypes.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NSInteger MTKBlockObservationKind;
enum {
    MTKBlockObservationKindChange = 0,
    MTKBlockObservationKindSetting = NSKeyValueChangeSetting,
    MTKBlockObservationKindInsertion = NSKeyValueChangeInsertion,
    MTKBlockObservationKindRemoval = NSKeyValueChangeRemoval,
    MTKBlockObservationKindReplacement = NSKeyValueChangeReplacement,
};
