//
//  Main.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 25.1.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "Main.h"



int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Main class]));
    }
}



@implementation Main

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.property = [[Example alloc] init];
    
    [self exampleObservePropertyWithBlock];
    [self exampleObservePropertyWithSelector];
    [self exampleMap];
    [self exampleKeypathMacro];
    
    return YES;
}



- (void)exampleObservePropertyWithBlock {
    NSLog(@"\n\nExample `observeProperty:withBlock:`");
    /// IMPORTANT: Always call these methods on SELF!
    [self observeProperty:@"property.title"
                withBlock:
     /// Specify the types as appropriate. You can use the `typeof(self) self` trick to avoid writing whole class name.
     ^(typeof(self) self, NSString *oldTitle, NSString *title) {
         
         /// You can safely use `self` here. No retain cycle, because it is re-declaed with `__weak` attribute.
         NSLog(@"%@: Title did change from '%@' to '%@'", self, oldTitle, title);
         
     }];
    
    /// This should log to debugger...
    self.property.title = @"Hello World!";
    /// ... but this should not!
    self.property.title = @"Hello World!";
    /// This lib prevents calling observation methods if the values are equal.
}



- (void)exampleObservePropertyWithSelector {
    NSLog(@"\n\nExample `observeProperty:withSelector:`");
    /// IMPORTANT: Always call these methods on SELF!
    [self observeProperty:@"property.progress" withSelector:@selector(progressDidChangeFrom:to:)];
    
    /// This should log to debugger.
    self.property.progress = 0.75;
}
/// Specify the types as appropriate.
- (void)progressDidChangeFrom:(NSNumber *)oldProgress to:(NSNumber *)progress {
    NSLog(@"%@: Progress did change from %.2f to %.2f", self, oldProgress.floatValue, progress.floatValue);
}



- (void)exampleMap {
    NSLog(@"\n\nExample `map:to:transform:`");
    /// IMPORTANT: Always call these methods on SELF!
    [self map:@"property.progress"
           to:@"property.title"
    transform:
     /// Specify the types as appropriate. You can use the `typeof(self) self` trick to avoid writing whole class name.
     ^NSString *(NSNumber *value) {
         return [NSString stringWithFormat:@"In progress: %.f %%", value.floatValue * 100];
     }];
    
    /// This will change the title to "In progress: 99 %". (Assuming previous examples were called you should see logs.)
    self.property.progress = 0.99;
}



- (void)exampleKeypathMacro {
    NSLog(@"\n\nExample `@keypath()`");
    /// You may want to use this macro for safe keypaths. They are validated during compilation and support autocompletion and refactoring.
    Example *example = [self valueForKeyPath:  @keypath(self.property)  ];
    
    NSLog(@"Key: %@", @keypath(self.property));
    NSLog(@"Key Path: %@", @keypath(self.property.title));
    NSLog(@"Key of other object: %@", @keypath(example.progress));
    NSLog(@"Key of other object by class: %@", @keypathClass(Example, progress));
    
    /// Just try to compile this line:
    //	id wrong = [self valueForKeyPath:  @keypath(self.notAProperty.title)  ];
    
    /// This great macro is from Extended Objective-C Library: https://github.com/jspahrsummers/libextobjc
}



@end
