#ifndef _MTLC_EVENTS_H_
#define _MTLC_EVENTS_H_

#include <simd/simd.h>
#include <stdbool.h>

typedef enum
{
    // Special Chars
    MTLC_KEY_SPACE = 0x31,
    MTLC_KEY_RETURN = 0x24,
    MTLC_KEY_ENTER = 0x4C,
    MTLC_KEY_ESCAPE = 0x35,
    MTLC_KEY_SHIFT = 0x38,
    MTLC_KEY_COMMAND = 0x37,

    // Directional Keys
    MTLC_KEY_LEFT = 0x7B,
    MTLC_KEY_RIGHT = 0x7C,
    MTLC_KEY_DOWN = 0x7D,
    MTLC_KEY_UP = 0x7E,

    // Alphabet
    MTLC_KEY_A = 0x00,
    MTLC_KEY_B = 0x0B,
    MTLC_KEY_C = 0x08,
    MTLC_KEY_D = 0x02,
    MTLC_KEY_E = 0x0E,
    MTLC_KEY_F = 0x03,
    MTLC_KEY_G = 0x05,
    MTLC_KEY_H = 0x04,
    MTLC_KEY_I = 0x22,
    MTLC_KEY_J = 0x26,
    MTLC_KEY_K = 0x28,
    MTLC_KEY_L = 0x25,
    MTLC_KEY_M = 0x2E,
    MTLC_KEY_N = 0x2D,
    MTLC_KEY_O = 0x1F,
    MTLC_KEY_P = 0x23,
    MTLC_KEY_Q = 0x0C,
    MTLC_KEY_R = 0x0F,
    MTLC_KEY_S = 0x01,
    MTLC_KEY_T = 0x11,
    MTLC_KEY_U = 0x20,
    MTLC_KEY_V = 0x09,
    MTLC_KEY_W = 0x0D,
    MTLC_KEY_X = 0x07,
    MTLC_KEY_Y = 0x10,
    MTLC_KEY_Z = 0x06,

    // Numbers
    MTLC_KEY_0 = 0x1D,
    MTLC_KEY_1 = 0x12,
    MTLC_KEY_2 = 0x13,
    MTLC_KEY_3 = 0x14,
    MTLC_KEY_4 = 0x15,
    MTLC_KEY_5 = 0x17,
    MTLC_KEY_6 = 0x16,
    MTLC_KEY_7 = 0x1A,
    MTLC_KEY_8 = 0x1C,
    MTLC_KEY_9 = 0x19,

    // Keypad Numbers
    MTLC_KEY_KP_0 = 0x52,
    MTLC_KEY_KP_1 = 0x53,
    MTLC_KEY_KP_2 = 0x54,
    MTLC_KEY_KP_3 = 0x55,
    MTLC_KEY_KP_4 = 0x56,
    MTLC_KEY_KP_5 = 0x57,
    MTLC_KEY_KP_6 = 0x58,
    MTLC_KEY_KP_7 = 0x59,
    MTLC_KEY_KP_8 = 0x5B,
    MTLC_KEY_KP_9 = 0x5C,

} MTLCKeyCodes;

typedef enum {
    MouseCodeLeft = 0,  // Trackpad click
    MouseCodeRight = 1,
    MouseCodeCenter = 2,
} MouseCodes;

void MTLCSetMouseButtonPressed(MouseCodes button, bool isOn);
bool MTLCIsMouseButtonPressed(MouseCodes button);
bool MTLCWasMouseButtonPressed(int button);
bool MTLCIsMouseButtonHeldDown(int button);

void MTLCSetOverallMousePosition(float x, float y);
void MTLCSetMousePositionChangeWithOverallPosition(vector_float2 oPos, vector_float2 dPos);
vector_float2 MTLCGetMouseWindowPosition();
vector_float2 MTLCGetMouseViewportPosition(float viewportWidth, float viewportHeight);

void MTLCScrollMouse(float deltaY);
float MTLCGetMouseDWheel();

float MTLCGetMouseDY();
float MTLCGetMouseDX();

void MTLCSetKeyPressed(unsigned short keyCode, bool isOn);
bool MTLCIsKeyPressed(unsigned short keyCode);
bool MTLCWasKeyPressed(int key);

void MTLCGetPollEvents(void);

#endif // _MTLC_EVENTS_H_