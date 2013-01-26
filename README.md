Block KVO 2.0
=============

Overview
--------

**Key-Value observing made easier with blocks.**

This set of classes use the Objective-C KVO mechanism and allows you to use blocks as observation handlers.
Block KVO can be used and mixed with classic KVO without any problems.

You should be familiar with the concepts of [Key-Value Observing](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html) and [Key-Value Coding](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html#//apple_ref/doc/uid/10000107-SW1).

Library and example app in this project are for iOS, but you can use in OS X project too by importing the source files directly.

Requirements
-------------
  - **iOS 4 or newer**
  - using source files: **ARC enabled**
  - using library: **`-ObjC` and `-all_load` as _Other Linker Flags_ in Build Settings**


Features
--------
### Observe using block ###
Any object can observe _its own_ key-path using block handler. _Caller and receiver must be the same object and the key-path must be relative to the receiver._

```
[self observe:@"selectedProfile.username" withBlock:
 ^(__weak typeof(self) self, NSString *oldUsername, NSString *newUsername) {
     self.selectedUsernameLabel.text = newUsername;
 }];
```

Block arguments has no specific type (so they are `id`). You are supposed to specifiy the type by yourself as you want. Primitive values are wrapped by `NSNumber` or `NSValue` instances

### Equality check ###
**IMPORTANT: This is different from the standard KVO.**

Once the value of observed property changes, but the values are _equal_ (using `-isEqual:` method) the observation blocks are _not_ invoked. For example `self.title = self.title;` will _not_ trigger observation.

### No retain cycles inside the blocks ###
All observation blocks have first argument the receive/caller with name `self`. It overrides method argument `self`, but contains the same object. The only difference is `__weak` attribute. In the example code above, you can use `self` and will not cause retain cycle.

### Observe Using Selector ###
If the selector has one argument, only new value is passed. If it has 2, then old and new values are passed. Any other arguments are ignored.

### Observe more key-paths at once ###
There are methods that take an array of key-paths.

### One-way binding (mapping) ###
Map property to another property. Once the source key-path changes, destination si updated with the new value. Transform the value as you wish.

```
[self map:@"selectedProfile.isLogged" to:@"isLoggedLabel.text" transform:
 ^NSString * (NSNumber *isLoggedNumber) {
     return (isLoggedNumber.boolValue ? @"Logged In" : @"Not Logged In");
 }];
```

Also, these is convenience method for specifying replacement for null value.

```
[self map:@"selectedProfile.username" to:@"usernameLabel.text" null:@"Unknown"];
```

### Two-way binding (mapping) ###
Two-way binding can be achieved by using two one-way bindings. Don't worry about recursion, because observation is supressed if the values are equal. With this you can map `user.name` to `textField.text`, so it will always display the name and then map `textField.text` to `user.name` for the name to be updated once the user make changes.

### Observe NSNotifications using blocks ###
Improved observation of notifications using blocks. `NSNotificationCenter` provides some support for this, but here you don't need to worry about removing those blocks or retain cycles.

---

_MIT License, Copyright (c) 2012-2013 Martin Kiss_

`THE SOFTWARE IS PROVIDED "AS IS", and so on …`
