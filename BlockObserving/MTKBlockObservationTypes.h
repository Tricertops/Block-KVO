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
    MTKBlockObservationKindDidChange = 0,
    MTKBlockObservationKindWillChange = 1,
    
    MTKBlockObservationKindDidInsert = 2,
    MTKBlockObservationKindWillInsert = 3,
    
    MTKBlockObservationKindDidRemove = 4,
    MTKBlockObservationKindWillRemove = 5,
    
    MTKBlockObservationKindDidReplace = 6,
    MTKBlockObservationKindWillReplace = 7,
    
    MTKBlockObservationKindAnything = 8,
};
