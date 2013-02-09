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
    
    STAssertTrue(initialDidRun, @"Failed to run initial observation");
    STAssertEqualObjects(initialOldValue, nil, @"Initial old value must be nil");
    STAssertEqualObjects(initialNewValue, self.simple, @"Initial new value must be current value");
    
    [self removeAllObservations];
    self.simple = nil;
}



- (void)testNonExistingKeypath {
    @try {
        [self observeProperty:@"invalid.keypath" withBlock:^(__weak typeof(self) self, MTKTestingObject *old, MTKTestingObject *new) {
            
        }];
        [self removeAllObservations];
        STFail(@"This should throw exception");
    }
    @catch (NSException *exception) {
        STAssertEqualObjects(exception.name, @"NSUnknownKeyException", @"Expected another exception");
    }
}



@end
