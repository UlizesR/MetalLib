#pragma once

#ifdef __OBJC__
#import <MacTypes.h>
#import <Foundation/Foundation.h>


typedef NS_ENUM(UInt16, KeyCodes) 
{
    // Special Chars
    MKL_KEY_SPACE = 0x31,
    MKL_KEY_RETURN = 0x24,
    MKL_KEY_ENTER = 0x4C,
    MKL_KEY_ESCAPE = 0x35,
    MKL_KEY_SHIFT = 0x38,
    MKL_KEY_COMMAND = 0x37,

    // Directional Keys
    MKL_KEY_UP = 0x7E,
    MKL_KEY_DOWN = 0x7D,
    MKL_KEY_LEFT = 0x7B,
    MKL_KEY_RIGHT = 0x7C,

    // Alphabet
    MKL_KEY_A = 0x00,
    MKL_KEY_B = 0x0B,
    MKL_KEY_C = 0x08,
    MKL_KEY_D = 0x02,
    MKL_KEY_E = 0x0E,
    MKL_KEY_F = 0x03,
    MKL_KEY_G = 0x05,
    MKL_KEY_H = 0x04,
    MKL_KEY_I = 0x22,
    MKL_KEY_J = 0x26,
    MKL_KEY_K = 0x28,
    MKL_KEY_L = 0x25,
    MKL_KEY_M = 0x2E,
    MKL_KEY_N = 0x2D,
    MKL_KEY_O = 0x1F,
    MKL_KEY_P = 0x23,
    MKL_KEY_Q = 0x0C,
    MKL_KEY_R = 0x0F,
    MKL_KEY_S = 0x01,
    MKL_KEY_T = 0x11,
    MKL_KEY_U = 0x20,
    MKL_KEY_V = 0x09,
    MKL_KEY_W = 0x0D,
    MKL_KEY_X = 0x07,
    MKL_KEY_Y = 0x10,
    MKL_KEY_Z = 0x06,

    // Numbers
    MKL_KEY_0 = 0x1D,
    MKL_KEY_1 = 0x12,
    MKL_KEY_2 = 0x13,
    MKL_KEY_3 = 0x14,
    MKL_KEY_4 = 0x15,
    MKL_KEY_5 = 0x17,
    MKL_KEY_6 = 0x16,
    MKL_KEY_7 = 0x1A,
    MKL_KEY_8 = 0x1C,
    MKL_KEY_9 = 0x19,

    // Keypad Numbers
    MKL_KEY_KP_0 = 0x52,
    MKL_KEY_KP_1 = 0x53,
    MKL_KEY_KP_2 = 0x54,
    MKL_KEY_KP_3 = 0x55,
    MKL_KEY_KP_4 = 0x56,
    MKL_KEY_KP_5 = 0x57,
    MKL_KEY_KP_6 = 0x58,
    MKL_KEY_KP_7 = 0x59,
    MKL_KEY_KP_8 = 0x5B,
    MKL_KEY_KP_9 = 0x5C,
};
#endif // __OBJC__