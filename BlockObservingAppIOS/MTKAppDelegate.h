//
//  MTKAppDelegate.h
//  BlockObservingAppIOS
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//



@interface MTKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite, strong) id object;

@end



@interface MTKTestingObject : NSObject

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, weak) MTKTestingObject *bro;

@end