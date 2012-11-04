//
//  MTKObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 28.9.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKObserver.h"



@interface MTKObserver ()

@property (nonatomic, readwrite, strong) id target;
@property (nonatomic, readwrite, strong) NSString *keyPath;

@property (nonatomic, readwrite, strong) NSMutableArray *afterSettingBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterInsertionBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterRemovalBlocks;
@property (nonatomic, readwrite, strong) NSMutableArray *afterReplacementBlocks;

@end









@implementation MTKObserver



- (id)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        
        self.afterSettingBlocks = [[NSMutableArray alloc] init];
        self.afterSettingBlocks = [[NSMutableArray alloc] init];
        self.afterRemovalBlocks = [[NSMutableArray alloc] init];
        self.afterReplacementBlocks = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)addSettingObservationBlock:(MTKObservationChangeBlock)block {
    [self.afterSettingBlocks addObject:[block copy]];
}

- (void)addInsertionObservationBlock:(MTKObservationInsertionBlock)block {
    [self.afterInsertionBlocks addObject:block];
}

- (void)addRemovalObservationBlock:(MTKObservationRemovalBlock)block {
    [self.afterRemovalBlocks addObject:block];
}

- (void)addReplacementObservationBlock:(MTKObservationReplacementBlock)block {
    [self.afterReplacementBlocks addObject:block];
}

- (void)setAttached:(BOOL)attached {
    // In case there is some other value than YES or NO.
    if (attached != NO) {
        attached = YES;
    }
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

- (void)executeAfterSettingBlocksOld:(id)old new:(id)new {
    for (MTKObservationChangeBlock block in self.afterSettingBlocks) {
        block(self.target, old, new);
    }
}

- (void)executeAfterInsertionBlocksNew:(id)new indexes:(NSIndexSet *)indexes {
    for (MTKObservationInsertionBlock block in self.afterInsertionBlocks) {
        block(self.target, new, indexes);
    }
}

- (void)executeAfterRemovalBlocksOld:(id)old indexes:(NSIndexSet *)indexes {
    for (MTKObservationRemovalBlock block in self.afterRemovalBlocks) {
        block(self.target, old, indexes);
    }
}

- (void)executeAfterReplacementBlocksOld:(id)old new:(id)new indexes:(NSIndexSet *)indexes {
    for (MTKObservationReplacementBlock block in self.afterReplacementBlocks) {
        block(self.target, old, new, indexes);
    }
}



@end
