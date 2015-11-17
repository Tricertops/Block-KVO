//
//  MTKObservingMacros.h
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 9.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//



/*************************************************************************************     MTKObservePropertySelf     */
/**
 Shorthand to create simple observation of one property.
 
 @param KEYPATH Is autocompleted and validated by compilator. (e.g. `view.frame`)
 @param TYPE Is anything that can stand before argument name in block declaration. (e.g. NSValue *)
 @param CODE Is code block encapsulated in `{}`. It is block implementation with these 3 variables:
    @param self This prevents retain cycles, since the block is owned by self.
    @param old Previous property value casted using TYPE.
    @param new Current property value casted using TYPE.
 
 Usage example:
 @code
 
    MTKChangeSelf(title, NSString *, {
        NSLog(@"%@ title changed from %@ to %@", self, old, new);
    });
 
 @endcode
 */
#define MTKObservePropertySelf(KEYPATH, TYPE, CODE...) \
[self observeProperty:@(((void)(NO && ((void)self.KEYPATH, NO)), # KEYPATH)) withBlock:^(typeof(self) self, TYPE old, TYPE new) CODE ];



/************************************************************************************************     MTKSelector     */
/**
 Allows you to use selector invocation instead of block in above macros.
 
 Usage example:
 @code
 
    MTKChangeSelf(title, NSString *, MTKSelector(didChangeTitle));
    MTKChangeSelf(title, NSString *, MTKSelector(didChangeTitleTo:new));
    MTKChangeSelf(title, NSString *, MTKSelector(didChangeTitleFrom:old to:new));
 
 @endcode
 */
#define MTKSelector(SELECTOR) \
{ [self SELECTOR]; }
