//
//  MTKObserving.h
//  MTK Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

/// Contains the public interface
#import "NSObject+MTKObserving.h"   // Methods
#import "MTKObservingMacros.h"      // Macros

/// Internal Implementation
#import "MTKObserver.h"



/// Utilities
// For the cool `@keypath` syntax
#import "keypath.h"
// To avoid retain cycles
#import "scope.h"
