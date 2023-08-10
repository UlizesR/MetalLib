// mac_events.h
#ifndef mac_events_h_
#define mac_events_h_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MAC_NOEVENT = 0,
    MAC_KEYBOARDEVENT,
    MAC_MOUSEEVENT,
    MAC_SCROLLEVENT,
} MAC_EventType;

typedef enum {
    MAC_NOSCROLL = 0,
    MAC_SCROLL_UP,
    MAC_SCROLL_DOWN,
} MAC_ScrollDirection;

typedef enum {
    // letter keys
    MAC_NOKEY = -1,
    MAC_KEY_A = 0,
    MAC_KEY_B = 11,
    MAC_KEY_C = 8,
    MAC_KEY_D = 2,
    MAC_KEY_E = 14,
    MAC_KEY_F = 3,
    MAC_KEY_G = 5,
    MAC_KEY_H = 4,
    MAC_KEY_I = 34,
    MAC_KEY_J = 38,
    MAC_KEY_K = 40,
    MAC_KEY_L = 37,
    MAC_KEY_M = 46,
    MAC_KEY_N = 45,
    MAC_KEY_O = 31,
    MAC_KEY_P = 35,
    MAC_KEY_Q = 12,
    MAC_KEY_R = 15,
    MAC_KEY_S = 1,
    MAC_KEY_T = 17,
    MAC_KEY_U = 32,
    MAC_KEY_V = 9,
    MAC_KEY_W = 13,
    MAC_KEY_X = 7,
    MAC_KEY_Y = 16,
    MAC_KEY_Z = 6,
    // number keys
    MAC_KEY_0 = 29,
    MAC_KEY_1 = 18,
    MAC_KEY_2 = 19,
    MAC_KEY_3 = 20,
    MAC_KEY_4 = 21,
    MAC_KEY_5 = 23,
    MAC_KEY_6 = 22,
    MAC_KEY_7 = 26,
    MAC_KEY_8 = 28,
    MAC_KEY_9 = 25,
    // function keys
    MAC_KEY_RETURN = 36,
    MAC_KEY_ESCAPE = 53,
    MAC_KEY_BACKSPACE = 51,
    MAC_KEY_TAB = 48,
    MAC_KEY_SPACE = 49,
    MAC_KEY_CAPSLOCK = 57,
    MAC_KEY_CTRL = 59,
    MAC_KEY_SHIFT = 56,
    MAC_KEY_ALT = 58,
    // arrow keys
    MAC_KEY_ARROW_UP = 126,
    MAC_KEY_ARROW_DOWN = 125,
    MAC_KEY_ARROW_LEFT = 123,
    MAC_KEY_ARROW_RIGHT = 124,

} MAC_KeyCode;

typedef enum {
    MAC_NOBUTTON = 0,
    MAC_BUTTON_LEFT,
    MAC_BUTTON_MIDDLE,
    MAC_BUTTON_RIGHT,
} MAC_MouseButton;

typedef struct {
    MAC_EventType type;
    // For keyboard events
    MAC_KeyCode keycode;
    // For mouse events
    int x;
    int y;
    MAC_MouseButton button;
    // For scroll events
    MAC_ScrollDirection direction;
} MAC_Event;

/*!
    Polls the event queue for events
    @param event: the event to poll
    @return: 0 on success, -1 on failure
*/
int MAC_PollEvent(MAC_Event* event);

#ifdef __cplusplus
}
#endif

#endif // mac_events_h_