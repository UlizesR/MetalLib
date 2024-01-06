#import "Keyboard.h"

static const NSInteger KEY_COUNT = 256;
static BOOL keys[KEY_COUNT];

@implementation Keyboard

+ (void)setKeyPressed:(UInt16)keyCode isOn:(BOOL)isOn 
{
    keys[keyCode] = isOn;
}

+ (BOOL)isKeyPressed:(KeyCodes)keyCode 
{
    return keys[keyCode];
}

@end