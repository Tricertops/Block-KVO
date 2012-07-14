//
//  MTKAppDelegate.m
//  BlockObservingAppIOS
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKAppDelegate.h"

#import "MTKBlockObserving.h"



@implementation MTKAppDelegate

@synthesize window = _window;
@synthesize object = _object;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    MTKTestingObject *first = [[MTKTestingObject alloc] init];
    [self observeChanges:@"object.name" beforeBlock:^(NSString *oldName) {
        NSLog(@"Will change name from '%@'", oldName);
    } afterBlock:^(NSString *name) {
        NSLog(@"Did change name to '%@'", name);
    }];
    
    MTKTestingObject *second = [[MTKTestingObject alloc] init];
    second.name = @"Bro";
    first.bro = second;
    second = nil;
    
    first.name = @"Martin";
    first.name = @"Marcel";
    
    self.object = first;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)update:(NSTimer *)timer {
    [self.object setName:[NSString stringWithFormat:@"Me %i", timer.timeInterval]];
    self.object = nil;
}

@end



@implementation MTKTestingObject

@synthesize name = _name;
@synthesize bro = _bro;

- (void)dealloc {
    NSLog(@"DEALLOC: %@", self->_name);
}

@end


