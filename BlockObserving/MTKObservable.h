//
//  MTKObservable.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 4.11.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//



@protocol MTKObservable <NSObject>

/// If you declare this protocol, instances of this class have to call `[self removeOllObservations]` in their `-dealloc` method.
/// In future it may be possible to observe other objects, that conforms to this protocol.

@end
