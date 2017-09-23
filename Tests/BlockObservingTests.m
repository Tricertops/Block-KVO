//
//  BlockObservingTests.m
//  Tests
//
//  Created by Martin Kiss on 9.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "BlockObservingTests.h"
#import "MTKObserving.h"
#import "MTKTestingObject.h"


@interface BlockObservingTests ()
@property (nonatomic, readwrite, strong) NSString *simple;
@property (nonatomic, readwrite, strong) MTKTestingObject *nested;
@end


@implementation BlockObservingTests



- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}



- (void)testInitialObservation {
    [self removeAllObservations];
    self.simple = @"testing initial observation";
    
    __block BOOL initialDidRun = NO;
    __block MTKTestingObject *initialOldValue = nil;
    __block MTKTestingObject *initialNewValue = nil;
    
    [self observeProperty:@"simple" withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
        initialDidRun = YES;
        initialOldValue = old;
        initialNewValue = new;
    }];
    
    XCTAssertTrue(initialDidRun, @"Failed to run initial observation");
    XCTAssertEqual(initialOldValue, initialNewValue, @"Initial old value must be identical to new value");
    XCTAssertEqualObjects(initialNewValue, self.simple, @"Initial new value must be current value");
    
    [self removeAllObservations];
    self.simple = nil;
}



- (void)testNonExistingKeypath {
    @try {
        [self observeProperty:@"invalid.keypath" withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
            
        }];
        [self removeAllObservations];
        XCTFail(@"This should throw exception");
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, @"NSUnknownKeyException", @"Expected another exception");
    }
}

- (void)testRemoveAllObservationsForKeyPath {
    [self removeAllObservations];
    self.simple = @"testing remove observer for key path";
    
    __block BOOL observeAfterRemoveDidRun = NO;
    [self observeProperty:@"simple" withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
        if(new != nil) {
            return;
        }
        
        observeAfterRemoveDidRun = YES;
    }];
    
    [self removeObservationsOfObject:self forKeyPath:@"simple"];
    self.simple = nil;
    
    XCTAssertTrue(!observeAfterRemoveDidRun, @"Failed to remove observation for keypath");
    
    [self removeAllObservations];
}

- (void)testAutomaticRemoveOnDealloc {
    MTKTestingObject *object = [MTKTestingObject new];
    [self observeObject:object property:@"title" withBlock:^(id self, id object, id old, id new) {}];
    __weak NSSet *observations = [object valueForKey:@"mtk_keyPathBlockObservers"][@"title"];
    
    XCTAssertEqual(observations.count, 1);
    XCTAssertNoThrow({ object = nil; });
    XCTAssertEqual(observations.count, 0);
}

- (void)testAutomaticRemovalOfOnOwnerDealloc {
    // https://github.com/Tricertops/Block-KVO/issues/43
    
    MTKTestingObject *object = [MTKTestingObject new];
    NSSet *observations = nil;
    
    @autoreleasepool {
        MTKTestingObject *observer1 = [MTKTestingObject new];
        [observer1 observeObject:object property:@"title" withBlock:^(id self, id object, id oldValue, id newValue) {}];
        observations = [object valueForKey:@"mtk_keyPathBlockObservers"][@"title"];
        XCTAssertEqual(observations.count, 1);
        observer1 = nil;
    }
    XCTAssertEqual(observations.count, 0);
    
    MTKTestingObject *observer2 = [MTKTestingObject new];
    [observer2 observeObject:object property:@"title" withBlock:^(id self, id object, id oldValue, id newValue) {}];
    
    XCTAssertEqual(observations.count, 1);
}

- (void)testAutomaticRemovalOfOnObjectDealloc {
    // Basically, the inverse of -testAutomaticRemovalOfOnOwnerDealloc
    
    __weak NSSet *observations = nil;
    @autoreleasepool {
        MTKTestingObject *observer1 = [MTKTestingObject new];
        observer1.title = @"observer";
        
        @autoreleasepool {
            MTKTestingObject *object = [MTKTestingObject new];
            object.title = @"object";
            [observer1 observeObject:object property:@"title" withBlock:^(id self, id object, id oldValue, id newValue) {}];
            observations = [object valueForKey:@"mtk_keyPathBlockObservers"][@"title"];
            XCTAssertEqual(observations.count, 1);
            object = nil;
        }
        XCTAssertEqual(observations, nil); // releasing object should release its observation set
    }
    // outer autorelease pool should release observer1, which should not crash (duh!)
}

@end
