#import "Keyboard.h"

static const unsigned short KEY_COUNT = 256;
static bool keys[KEY_COUNT];

void MKLSetKeyPressed(unsigned short keyCode, bool isOn)
{
    keys[keyCode] = isOn;
}

bool MKLIsKeyPressed(unsigned short keyCode)
{
    return keys[keyCode];
}