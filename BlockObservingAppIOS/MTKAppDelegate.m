//
//  MTKAppDelegate.m
//  BlockObservingAppIOS
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKAppDelegate.h"
#import "MTKObserving.h"



@implementation MTKAppDelegate

@synthesize window = _window;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Block KVO";
    
    window.rootViewController = viewController;
    
    [self observeProperty:@"window" withBlock:^(__weak id self, id old, id new) {
        NSLog(@"Window changed 1");
    }];
    
    [self observeProperty:@"window" withBlock:^(__weak id self, UIWindow *oldWindow, UIWindow *newWindow) {
        NSLog(@"Window changed 2");
        [newWindow makeKeyAndVisible];
    }];
    
    [self map:@"profile.username" to:@"usernameLabel.text" transform:^id(id value) {
        return value ?: @"Loading...";
    }];
    
    [self observeProperty:@"window.rootViewController.title" withBlock:^(__weak id self, NSString *oldTitle, NSString *newTitle) {
        NSLog(@"Root view controller's title changed from '%@' to '%@'.", oldTitle, newTitle);
    }];
    
    [self observeRelationship:@"profile.videos" changeBlock:^(id self, id old, id new) {
        // Reload table
    } insertionBlock:^(id self, id news, NSIndexSet *indexes) {
        // Insert rows
    } removalBlock:^(id self, id olds, NSIndexSet *indexes) {
        // Delete rows
    } replacementBlock:nil]; // Since we didn't specify this block, `changeBlock` will be called.
    
    self.window = window;
    self.text = @"Hello World!";
    return YES;
}



- (void)dealloc {
    [self removeAllObservations];
}



@end


