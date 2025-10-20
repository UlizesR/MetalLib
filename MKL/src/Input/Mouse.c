#include "Mouse.h"
#include <stdio.h>
#include <string.h>

#define MOUSE_BUTTON_COUNT 12

// Current and previous mouse button state (following raylib pattern)
static bool _gCurrentMouseButtonState[MOUSE_BUTTON_COUNT] = {false};
static bool _gPreviousMouseButtonState[MOUSE_BUTTON_COUNT] = {false};

// Mouse position and delta
static vector_float2 _gMousePosition = {0.0f, 0.0f};
static vector_float2 _gMouseDelta = {0.0f, 0.0f};

// Scroll wheel state
static float _gScrollWheelMove = 0.0f;

// Cursor mode
static MKLCursorMode _gCursorMode = MKL_CURSOR_NORMAL;

void MKLSetMouseButtonPressed(const MouseCodes button, const bool isPressed)
{
    // Bounds checking to prevent buffer overflow
    if (button >= MOUSE_BUTTON_COUNT)
    {
        fprintf(stderr, "MKL Warning: Invalid mouse button %d (max: %d)\n", button, MOUSE_BUTTON_COUNT - 1);
        return;
    }
    
    _gCurrentMouseButtonState[button] = isPressed;
}

void MKLUpdateMouseState(void)
{
    // Copy current state to previous state for next frame
    memcpy(_gPreviousMouseButtonState, _gCurrentMouseButtonState, sizeof(_gCurrentMouseButtonState));
    
    // Reset per-frame values
    _gMouseDelta = (vector_float2){0.0f, 0.0f};
    _gScrollWheelMove = 0.0f;
}

void MKLSetMousePosition(const float x, const float y)
{
    _gMousePosition.x = x;
    _gMousePosition.y = y;
}

void MKLSetMouseDelta(const float dx, const float dy)
{
    _gMouseDelta.x = dx;
    _gMouseDelta.y = dy;
}

bool MKLIsMouseButtonPressed(const MouseCodes button)
{
    // Bounds checking
    if (button >= MOUSE_BUTTON_COUNT)
    {
        return false;
    }
    
    // Button was just pressed if it's down now but wasn't down before
    return (_gPreviousMouseButtonState[button] == false) && (_gCurrentMouseButtonState[button] == true);
}

bool MKLIsMouseButtonDown(const MouseCodes button)
{
    // Bounds checking
    if (button >= MOUSE_BUTTON_COUNT)
    {
        return false;
    }
    
    return _gCurrentMouseButtonState[button];
}

bool MKLIsMouseButtonReleased(const MouseCodes button)
{
    // Bounds checking
    if (button >= MOUSE_BUTTON_COUNT)
    {
        return false;
    }
    
    // Button was just released if it was down before but isn't now
    return (_gPreviousMouseButtonState[button] == true) && (_gCurrentMouseButtonState[button] == false);
}

bool MKLIsMouseButtonUp(const MouseCodes button)
{
    // Bounds checking
    if (button >= MOUSE_BUTTON_COUNT)
    {
        return true; // Assume button is up if invalid
    }
    
    return !_gCurrentMouseButtonState[button];
}

float MKLGetMouseX(void)
{
    return _gMousePosition.x;
}

float MKLGetMouseY(void)
{
    return _gMousePosition.y;
}

vector_float2 MKLGetMousePosition(void)
{
    return _gMousePosition;
}

float MKLGetMouseDeltaX(void)
{
    return _gMouseDelta.x;
}

float MKLGetMouseDeltaY(void)
{
    return _gMouseDelta.y;
}

vector_float2 MKLGetMouseDelta(void)
{
    return _gMouseDelta;
}

void MKLScrollMouse(const float deltaY)
{
    _gScrollWheelMove += deltaY;
}

float MKLGetMouseWheelMove(void)
{
    return _gScrollWheelMove;
}

vector_float2 MKLGetMouseViewportPosition(const float viewportWidth, const float viewportHeight)
{
    const float x = (_gMousePosition.x - viewportWidth * 0.5f) / (viewportWidth * 0.5f);
    const float y = (_gMousePosition.y - viewportHeight * 0.5f) / (viewportHeight * 0.5f);
    return (vector_float2){x, y};
}

void MKLSetCursorMode(const MKLCursorMode mode)
{
    _gCursorMode = mode;
    
    // TODO: Implement actual cursor show/hide/lock behavior
    // This would require window handle to call NSCursor operations
}

MKLCursorMode MKLGetCursorMode(void)
{
    return _gCursorMode;
}
