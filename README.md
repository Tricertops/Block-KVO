Block Observing
=============


Overview
--------
**Key-Value Observing made easier with blocks.**

This is an **extension to Key-Value Observation** mechanism and allows you to use **blocks as observation handlers**.
Block Observing can be used and mixed with classic KVO without any problems.

You should be familiar with the concepts of [Key-Value Observing](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html) and [Key-Value Coding](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html#//apple_ref/doc/uid/10000107-SW1).

Library and example app in this project are for iOS, but you can use in OS X project too by importing the source files directly.


Integration
-----------
1. **Drag** the project into your project (as a child or sibling).
2. Add `Block Observing` to _**Target Dependencies**_ in _Build Phases_.
3. Add `libBlockObserving.a` to _**Link Binary With Libraries**_ in _Build Phases_.
4. Add **`-ObjC` and `-all_load`** as _Other Linker Flags_ in _Build Settings_.
5. Make sure you have _Header Search Paths_ in _Build Settings_ set up (e.g. `Libraries/**`).
6. Import `MTKObserving.h` to your files (usually in `Prefix.pch`).

> **CocoaPods** central repositary will no longer be updated. Use this:
> `pod 'Block-KVO', :git => 'https://github.com/Tricertops/Block-KVO.git'`

Features
--------


### Observe using block ###
Any object can observe _its own_ key-path using block handler. _Caller and receiver must be the same object and the key-path must be relative to the receiver._

```objc
[self observeProperty:@keypath(self.profile.username) withBlock:
 ^(__weak typeof(self) self, NSString *oldUsername, NSString *newUsername) {
     self.usernameLabel.text = newUsername;
 }];
```

Block arguments has no specific type (so they are `id`). You are supposed to specifiy the type by yourself as you want. Primitive values are wrapped by `NSNumber` or `NSValue` instances


### Quick macros

The above code example using provided macro:

```objc
MTKObservePropertySelf(profile.username, NSString *, {
    self.usernameLabel.text = new;
});
```


### Equality check ###
**IMPORTANT: This is different from the standard KVO.**

Once the value of observed property changes, but the values are _equal_ (using `-isEqual:` method) the observation blocks are _not_ invoked. For example `self.title = self.title;` will _not_ trigger observation.


### No retain cycles inside the blocks ###
All observation blocks have first argument the receive/caller with name `self`. It overrides method argument `self`, but contains the same object. The only difference is `__weak` attribute. In the example code above, you can use `self` and will not cause retain cycle.


### Observe Using Selector ###
If you want to get out of the current scope, you can just provide selector instead of block.

```objc
[self observeProperty:@keypath(self.profile.username) withSelector:@selector(didChangeUsernameFrom:to:)];
```


### Observe more key-paths at once ###
There are methods that take an array of key-paths and one block (or selector).


### One-way binding (mapping) ###
Map property to another property. Once the source key-path changes, destination is updated with the new value. Transform the value as you wish.

```objc
[self map:@keypath(self.profile.isLogged) to:@keypath(self.isLoggedLabel.text) transform:
 ^NSString *(NSNumber *isLogged) {
     return (isLogged.boolValue ? @"Logged In" : @"Not Logged In");
 }];
```

Also, there is convenience method for specifying replacement for null value.

```objc
[self map:@keypath(self.profile.username) to:@(self.usernameLabel.text) null:@"Unknown"];
```


### Two-way binding (mapping) ###
Two-way binding can be achieved by using two one-way bindings. Don't worry about recursion, because observation is supressed if the values are equal.

```objc
[self map:@keypath(self.task.isDone) to:@keypath(self.doneButton.selected) null:nil];
[self map:@keypath(self.doneButton.selected) to:@keypath(self.task.isDone) null:nil];
```


### Observe NSNotifications using blocks ###
Improved observation of notifications using blocks. `NSNotificationCenter` provides some support for this, but here you don't need to worry about removing those blocks or retain cycles.


### Remove Observations
Removing is now automatic.

---

_The MIT License_  
_Copyright © 2012 – 2016 Martin Kiss_
