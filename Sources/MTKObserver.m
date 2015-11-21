//
//  MTKObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 28.9.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKObserver.h"
#import "MTKDeallocator.h"



#pragma mark Private Interface

@interface MTKObserver ()

@property (nonatomic, readwrite, assign) id target;
@property (nonatomic, readwrite, copy) NSString *keyPath;
@property (nonatomic, readwrite, assign) id owner;


@property (nonatomic, readwrite, strong) NSMutableArray *afterSettingBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterInsertionBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterRemovalBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterReplacementBlocks;

@end









@implementation MTKObserver



#pragma mark Initialization

- (id)init {
    return [self initWithTarget:nil keyPath:nil owner:nil];
}

- (id)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath owner:(id)owner {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.owner = owner;
        
        [target mtk_addDeallocationCallback:^(id target) {
            [self detach];
        }];
        [owner mtk_addDeallocationCallback:^(id owner) {
            [self detach];
        }];
        
        self.afterSettingBlocks = [[NSMutableArray alloc] init];
        self.afterInsertionBlocks = [[NSMutableArray alloc] init];
        self.afterRemovalBlocks = [[NSMutableArray alloc] init];
        self.afterReplacementBlocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self detach];
}



#pragma Adding Blocks

- (void)addSettingObservationBlock:(MTKBlockChange)block {
    [self.afterSettingBlocks addObject:block];
    
    // Since we supress equal values in observation, to we must manually ensure the block is invoked.
    // In this only case the old and new values are equal (if the initial value is `nil`).
    id initialValue = [self.target valueForKeyPath:self.keyPath];
    block(self.target, nil, initialValue);
}

- (void)addInsertionObservationBlock:(MTKBlockInsert)block {
    [self.afterInsertionBlocks addObject:block];
}

- (void)addRemovalObservationBlock:(MTKBlockRemove)block {
    [self.afterRemovalBlocks addObject:block];
}

- (void)addReplacementObservationBlock:(MTKBlockReplace)block {
    [self.afterReplacementBlocks addObject:block];
}



#pragma mark Attaching

- (void)setAttached:(BOOL)attached {
    // In case there is some other value than YES or NO.
    if (attached != NO) {
        attached = YES;
    }
    // Do not catch exceptions, observing invalid key-path is considered programmer error.
    if (self->_attached != attached) {
        self->_attached = attached;
        if (attached) {
            [self.target addObserver:self
                          forKeyPath:self.keyPath
                             options:
             NSKeyValueObservingOptionInitial |
             NSKeyValueObservingOptionOld |
             NSKeyValueObservingOptionNew
                             context:nil];
        }
        else {
            [self.target removeObserver:self forKeyPath:self.keyPath];
        }
    }
}

- (void)attach {
    self.attached = YES;
}

- (void)detach {
    self.attached = NO;
}



#pragma mark Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (self.target == object && [self.keyPath isEqualToString:keyPath]) {
        
        BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
        NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        if (old == [NSNull null]) old = nil;
        
        id new = [change objectForKey:NSKeyValueChangeNewKey];
        if (new == [NSNull null]) new = nil;
        
        NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        if (isPrior) {
            // May be added in future.
        }
        else {
            switch (changeKind) {
                case NSKeyValueChangeSetting: [self executeAfterSettingBlocksOld:old new:new]; break;
                case NSKeyValueChangeInsertion: [self executeAfterInsertionBlocksNew:new indexes:indexes]; break;
                case NSKeyValueChangeRemoval: [self executeAfterRemovalBlocksOld:old indexes:indexes]; break;
                case NSKeyValueChangeReplacement: [self executeAfterReplacementBlocksOld:old new:new indexes:indexes]; break;
            }
        }
    }
}



#pragma mark Execute Blocks

- (void)executeAfterSettingBlocksOld:(id)old new:(id)new {
    // Here we check for equality. Two values are equal when they have equal pointers (e.g. nils) or they respond to -isEqual: with YES.
    if (old == new || (old && [new isEqual:old])) return;
    
    for (MTKBlockChange block in [self.afterSettingBlocks copy]) {
        block(self.target, old, new);
    }
}

- (void)executeAfterInsertionBlocksNew:(id)new indexes:(NSIndexSet *)indexes {
    // Prevent calling blocks when really nothing was inserted.
    if ([new respondsToSelector:@selector(count)] && [new count] == 0) return;
    
    for (MTKBlockInsert block in [self.afterInsertionBlocks copy]) {
        block(self.target, new, indexes);
    }
}

- (void)executeAfterRemovalBlocksOld:(id)old indexes:(NSIndexSet *)indexes {
    // Prevent calling blocks when really nothing was removed.
    if ([old respondsToSelector:@selector(count)] && [old count] == 0) return;
    
    for (MTKBlockRemove block in [self.afterRemovalBlocks copy]) {
        block(self.target, old, indexes);
    }
}

- (void)executeAfterReplacementBlocksOld:(id)old new:(id)new indexes:(NSIndexSet *)indexes {
    // Prevent calling blocks when really nothing was replaced.
    if ([old respondsToSelector:@selector(count)] && [old count] == 0) return;
    if ([new respondsToSelector:@selector(count)] && [new count] == 0) return;
    
    for (MTKBlockReplace block in [self.afterReplacementBlocks copy]) {
        block(self.target, old, new, indexes);
    }
}



@end
