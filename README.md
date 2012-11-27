Block KVO 2.0
=============

Overview
--------

**Key-Value observing made easier with blocks.**

This set of classes use the Objective-C KVO mechanism and allows you to use blocks as observation handlers.
Block KVO can be used and mixed with classic KVO without any problems.


Requirements
-------------
  - **iOS 4 or newer**
  - using source files: **ARC enabled**
  - using library: **`-ObjC` and `-all_load` as _Other Linker Flags_ in Build Settings**


Features
--------
### Observe Using Block ###
Any object can observe _its own_ key-path using block handler. Caller and receiver must be the same object and key-path must be relative to the receiver.

```
[self observe:@"selectedProfile.username" withBlock:
 ^(__weak typeof(self) self, NSString *oldUsername, NSString *newUsername) {
     self.selectedUsernameLabel.text = newUsername;
 }];
```

Block arguments has no specific type (so they are `id`). You are supposed to specifiy the type by yourself as you want. Primitive values are wrapped by NSNumber or NSValue instances

### No Retain Cycles Inside Blocks
All observation blocks have first argument the receive/caller with name `self`. It overrides method argument `self`, but contains the same object. The only difference is `__weak` attribute. In the example code above, you can use `self` and will not cause retain cycle.

### Observe Using Selector ###
If the selector has one argument, only new value is passed. If it has 2, then old and new values are passed. Any other arguments are ignored.

### Observe More Key-Paths at Once (Block or Selector) ###


### One-Way Binding (Mapping) ###
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

---