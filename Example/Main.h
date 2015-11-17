//
//  Main.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 25.1.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

/// Block-KVO: Import main header.
#import "MTKObserving.h"
#import "Example.h"



@interface Main : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Example *property;

@end
