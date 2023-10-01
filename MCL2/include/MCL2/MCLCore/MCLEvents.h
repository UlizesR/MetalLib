/*
    File:  MCLEvents.h
    About:
        The events header file for MCL.
        Containts the event types and functions for the MCL events.
*/

#ifndef _mcl_events_h_
#define _mcl_events_h_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  MCL_NOEVENT = 0,
  MCL_KEYBOARDEVENT,
  MCL_MOUSEEVENT,
  MCL_SCROLLEVENT,
} MCL_EventType;

typedef enum {
  MCL_NOSCROLL = 0,
  MCL_SCROLL_UP,
  MCL_SCROLL_DOWN,
} MCL_ScrollDirection;

typedef enum {
  // letter keys
  MCL_NOKEY = -1,
  MCL_KEY_A = 0,
  MCL_KEY_B = 11,
  MCL_KEY_C = 8,
  MCL_KEY_D = 2,
  MCL_KEY_E = 14,
  MCL_KEY_F = 3,
  MCL_KEY_G = 5,
  MCL_KEY_H = 4,
  MCL_KEY_I = 34,
  MCL_KEY_J = 38,
  MCL_KEY_K = 40,
  MCL_KEY_L = 37,
  MCL_KEY_M = 46,
  MCL_KEY_N = 45,
  MCL_KEY_O = 31,
  MCL_KEY_P = 35,
  MCL_KEY_Q = 12,
  MCL_KEY_R = 15,
  MCL_KEY_S = 1,
  MCL_KEY_T = 17,
  MCL_KEY_U = 32,
  MCL_KEY_V = 9,
  MCL_KEY_W = 13,
  MCL_KEY_X = 7,
  MCL_KEY_Y = 16,
  MCL_KEY_Z = 6,
  // number keys
  MCL_KEY_0 = 29,
  MCL_KEY_1 = 18,
  MCL_KEY_2 = 19,
  MCL_KEY_3 = 20,
  MCL_KEY_4 = 21,
  MCL_KEY_5 = 23,
  MCL_KEY_6 = 22,
  MCL_KEY_7 = 26,
  MCL_KEY_8 = 28,
  MCL_KEY_9 = 25,
  // function keys
  MCL_KEY_RETURN = 36,
  MCL_KEY_ESCAPE = 53,
  MCL_KEY_BACKSPACE = 51,
  MCL_KEY_TAB = 48,
  MCL_KEY_SPACE = 49,
  MCL_KEY_CAPSLOCK = 57,
  MCL_KEY_CTRL = 59,
  MCL_KEY_SHIFT = 56,
  MCL_KEY_ALT = 58,
  // arrow keys
  MCL_KEY_ARROW_UP = 126,
  MCL_KEY_ARROW_DOWN = 125,
  MCL_KEY_ARROW_LEFT = 123,
  MCL_KEY_ARROW_RIGHT = 124,

} MCL_KeyCode;

typedef enum {
  MCL_NOBUTTON = 0,
  MCL_BUTTON_LEFT,
  MCL_BUTTON_MIDDLE,
  MCL_BUTTON_RIGHT,
} MCL_MouseButton;

typedef struct {
  MCL_EventType type;
  // For keyboard events
  MCL_KeyCode keycode;
  // For mouse events
  int x;
  int y;
  MCL_MouseButton button;
  // For scroll events
  MCL_ScrollDirection direction;
} MCL_Event;

/*!
    Polls the event queue for events
    @param event: the event to poll
    @return: 0 on success, -1 on failure
*/
void MCL_PollEvents(MCL_Event *event);

#ifdef __cplusplus
}
#endif

#endif // _mcl_events_h_