#pragma once 

#ifdef __OBJC__
#import "KeyCodes.h"
#import <Foundation/Foundation.h>

@interface Keyboard : NSObject

+ (void)setKeyPressed:(UInt16)keyCode isOn:(BOOL)isOn;
+ (BOOL)isKeyPressed:(KeyCodes)keyCode;

@end

#endif // __OBJC__