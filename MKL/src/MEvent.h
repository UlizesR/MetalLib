#ifndef _M_EVENT_H_
#define _M_EVENT_H_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#include "MDefs.h"

typedef enum {
    //Keypad Special Chars
    M_SPCAE_KEY = 0x31,
    M_RETURN_KEY = 0x24,
    M_ENTER_KEY = 0x4C,
    M_ESCAPE_KEY = 0x35,
    M_SHIFT_KEY = 0x38,
    M_COMMAND_KEY = 0x37,

    //Keypad DPad Keys
    M_LEFT_ARROW_KEY = 0x7B,
    M_RIGHT_ARROW_KEY = 0x7C,
    M_DOWN_ARROW_KEY = 0x7D,
    M_UP_ARROW_KEY = 0x7E,

    //Keypad Alphabet
    M_A_KEY = 0x00,
    M_B_KEY = 0x0B,
    M_C_KEY = 0x08,
    M_D_KEY = 0x02,
    M_E_KEY = 0x0E,
    M_F_KEY = 0x03,
    M_G_KEY = 0x05,
    M_H_KEY = 0x04,
    M_I_KEY = 0x22,
    M_J_KEY = 0x26,
    M_K_KEY = 0x28,
    M_L_KEY = 0x25,
    M_M_KEY = 0x2E,
    M_N_KEY = 0x2D,
    M_O_KEY = 0x1F,
    M_P_KEY = 0x23,
    M_Q_KEY = 0x0C,
    M_R_KEY = 0x0F,
    M_S_KEY = 0x01,
    M_T_KEY = 0x11,
    M_U_KEY = 0x20,
    M_V_KEY = 0x09,
    M_W_KEY = 0x0D,
    M_X_KEY = 0x07,
    M_Y_KEY = 0x10,
    M_Z_KEY = 0x06,

    //Keypad Top Numbers
    M_ZERO_KEY = 0x1D,
    M_ONE_KEY = 0x12,
    M_TWO_KEY = 0x13,
    M_THREE_KEY = 0x14,
    M_FOUR_KEY = 0x15,
    M_FIVE_KEY = 0x17,
    M_SIX_KEY = 0x16,
    M_SEVEN_KEY = 0x1A,
    M_EIGHT_KEY = 0x1C,
    M_NINE_KEY = 0x19,

    //Keypad Numbers
    M_KEYPAD_ZERO_KEY = 0x52,
    M_KEYPAD_ONE_KEY = 0x53,
    M_KEYPAD_TWO_KEY = 0x54,
    M_KEYPAD_THREE_KEY = 0x55,
    M_KEYPAD_FOUR_KEY = 0x56,
    M_KEYPAD_FIVE_KEY = 0x57,
    M_KEYPAD_SIX_KEY = 0x58,
    M_KEYPAD_SEVEN_KEY = 0x59,
    M_KEYPAD_EIGHT_KEY = 0x5B,
    M_KEYPAD_NINE_KEY = 0x5C,
} MKeyCode;

typedef enum {
    M_NO_EVENT = 0,
    M_KEYBOARD_EVENT = 1,
    M_MOUSE_EVENT = 2,
} MEventType;

typedef enum {
    M_KEY_DOWN = 1,
    M_KEY_UP = 2,
} MKeyboardEventType;

typedef enum {
    M_MOUSE_DOWN,
    M_MOUSE_UP,
    M_MOUSE_MOVE,
    M_MOUSE_SCROLL,
} MMouseEventType;

typedef struct MEvent
{
    MEventType type;
    union {
        struct {
            MKeyboardEventType type;
            MKeyCode keyCode;
        } keyboardEvent;
        struct {
            MMouseEventType type;
            int x, y;
            int deltaX, deltaY;
        } mouseEvent;
    };
#ifdef __OBJC__
    NSEvent* _event;
#endif
} MEvent;


MAPI void MGetPollEvents(MEvent* event);

MAPI MKeyCode MGetKeyCode(MEvent* event);

#endif // _M_EVENT_H_