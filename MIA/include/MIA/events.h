// mac_events.h
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    M_NOEVENT = 0,
    M_KEYBOARDEVENT,
    M_MOUSEEVENT,
    M_SCROLLEVENT,
} M_EventType;

typedef enum {
    M_NOSCROLL = 0,
    M_SCROLL_UP,
    M_SCROLL_DOWN,
} M_ScrollDirection;

typedef enum {
    // letter keys
    M_NOKEY = -1,
    M_KEY_A = 0,
    M_KEY_B = 11,
    M_KEY_C = 8,
    M_KEY_D = 2,
    M_KEY_E = 14,
    M_KEY_F = 3,
    M_KEY_G = 5,
    M_KEY_H = 4,
    M_KEY_I = 34,
    M_KEY_J = 38,
    M_KEY_K = 40,
    M_KEY_L = 37,
    M_KEY_M = 46,
    M_KEY_N = 45,
    M_KEY_O = 31,
    M_KEY_P = 35,
    M_KEY_Q = 12,
    M_KEY_R = 15,
    M_KEY_S = 1,
    M_KEY_T = 17,
    M_KEY_U = 32,
    M_KEY_V = 9,
    M_KEY_W = 13,
    M_KEY_X = 7,
    M_KEY_Y = 16,
    M_KEY_Z = 6,
    // number keys
    M_KEY_0 = 29,
    M_KEY_1 = 18,
    M_KEY_2 = 19,
    M_KEY_3 = 20,
    M_KEY_4 = 21,
    M_KEY_5 = 23,
    M_KEY_6 = 22,
    M_KEY_7 = 26,
    M_KEY_8 = 28,
    M_KEY_9 = 25,
    // function keys
    M_KEY_RETURN = 36,
    M_KEY_ESCAPE = 53,
    M_KEY_BACKSPACE = 51,
    M_KEY_TAB = 48,
    M_KEY_SPACE = 49,
    M_KEY_CAPSLOCK = 57,
    M_KEY_CTRL = 59,
    M_KEY_SHIFT = 56,
    M_KEY_ALT = 58,
    // arrow keys
    M_KEY_ARROW_UP = 126,
    M_KEY_ARROW_DOWN = 125,
    M_KEY_ARROW_LEFT = 123,
    M_KEY_ARROW_RIGHT = 124,

} M_KeyCode;

typedef enum {
    M_NOBUTTON = 0,
    M_BUTTON_LEFT,
    M_BUTTON_MIDDLE,
    M_BUTTON_RIGHT,
} M_MouseButton;

typedef struct {
    M_EventType type;
    // For keyboard events
    M_KeyCode keycode;
    // For mouse events
    int x;
    int y;
    M_MouseButton button;
    // For scroll events
    M_ScrollDirection direction;
} M_Event;

/*!
    Polls the event queue for events
    @param event: the event to poll
    @return: 0 on success, -1 on failure
*/
int M_PollEvent(M_Event* event);

#ifdef __cplusplus
}
#endif