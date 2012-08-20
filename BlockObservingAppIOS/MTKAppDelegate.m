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



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Block KVO";
    
    window.rootViewController = viewController;
    
    [self observe:@"window" withBlock:^(UIWindow *oldWindow, UIWindow *newWindow) {
        [newWindow makeKeyAndVisible];
    }];
    [self observe:@"window.rootViewController.title" withBlock:^(NSString *oldRootTitle, NSString *newRootTitle) {
        NSLog(@"Root view controller's title changed from '%@' to '%@'.", oldRootTitle, newRootTitle);
    }];
    
    self.window = window;
    return YES;
}



@end


