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
    
    [self observeProperty:@keypath(self.simple) withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
        initialDidRun = YES;
        initialOldValue = old;
        initialNewValue = new;
    }];
    
    XCTAssertTrue(initialDidRun, @"Failed to run initial observation");
    XCTAssertEqualObjects(initialOldValue, nil, @"Initial old value must be nil");
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
    [self observeProperty:@keypath(self.simple) withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
        if(new != nil) {
            return;
        }
        
        observeAfterRemoveDidRun = YES;
    }];
    
    [self removeObservationsOfObject:self forKeyPath:@keypath(self.simple)];
    self.simple = nil;
    
    XCTAssertTrue(!observeAfterRemoveDidRun, @"Failed to remove observation for keypath");
    
    [self removeAllObservations];
}

- (void)testAutomaticRemoveOnDealloc {
    MTKTestingObject *object = [MTKTestingObject new];
    [self observeObject:object property:@keypath(object, title) withBlock:^(id self, id object, id old, id new) {}];
    XCTAssertNoThrow({ object = nil; });
}

@end
