Block KVO 2.0
=============

Overview
--------

**Key-Value observing made easier with blocks.**

This set of classes use the Objective-C KVO mechanism and allows you to use blocks as observation handlers.
Block KVO can be used and mixed with classic KVO without any problems.

This branch is not properly tested, but it takes different approach and simplifies things even more.

Requirements
-------------
  - **iOS 4 and greater**
  - using source files: **ARC enabled**
  - using library: **`-ObjC` and `-all_load` as _Other Linker Flags_ in Build Settings**


Example
-------

  - In `init`, `viewDidLoad` or similar method:
  
```objc
[self observeProperty:@"view.backgroundColor"
            withBlock:^(__weak UIViewController *self, UIColor *oldColor, UIColor *newColor) {
    NSLog(@"Background color changed from %@ to %@", oldColor, newColor);
}];
```

```objc
[self map:@"profile.username" to:@"usernameLabel.text" transform:^NSString *(NSString *username) {
    return username ?: @"Loading...";
}];
```

  - In `dealloc` method:

```objc
[self removeAllObservations];
````


---------

**TODO:** Test relationship observations in real project.
