#include "Keyboard.h"
#include <stdio.h>
#include <string.h>

#define KEY_COUNT 256

// Current and previous keyboard state (following raylib pattern)
static bool _gCurrentKeyState[KEY_COUNT] = {false};
static bool _gPreviousKeyState[KEY_COUNT] = {false};

// Key press queue (following raylib pattern)
static unsigned short _gKeyPressedQueue[MKL_KEY_PRESS_QUEUE_SIZE] = {0};
static unsigned int _gKeyPressedQueueCount = 0;

// Exit key configuration
static unsigned short _gExitKey = MKL_KEY_ESCAPE;

void MKLSetKeyPressed(const unsigned short keyCode, const bool isPressed)
{
    // Bounds checking to prevent buffer overflow
    if (keyCode >= KEY_COUNT)
    {
        fprintf(stderr, "MKL Warning: Invalid key code %u (max: %d)\n", keyCode, KEY_COUNT - 1);
        return;
    }
    
    // Only add to queue on key press (not release)
    if (isPressed && !_gCurrentKeyState[keyCode])
    {
        // Add to key press queue if not full
        if (_gKeyPressedQueueCount < MKL_KEY_PRESS_QUEUE_SIZE)
        {
            _gKeyPressedQueue[_gKeyPressedQueueCount] = keyCode;
            _gKeyPressedQueueCount++;
        }
    }
    
    _gCurrentKeyState[keyCode] = isPressed;
}

void MKLUpdateKeyboardState(void)
{
    // Copy current state to previous state for next frame
    memcpy(_gPreviousKeyState, _gCurrentKeyState, sizeof(_gCurrentKeyState));
    
    // Clear the key press queue
    _gKeyPressedQueueCount = 0;
}

bool MKLIsKeyPressed(const unsigned short keyCode)
{
    // Bounds checking
    if (keyCode >= KEY_COUNT)
    {
        return false;
    }
    
    // Key was just pressed if it's down now but wasn't down before (following raylib)
    return (_gPreviousKeyState[keyCode] == false) && (_gCurrentKeyState[keyCode] == true);
}

bool MKLIsKeyDown(const unsigned short keyCode)
{
    // Bounds checking
    if (keyCode >= KEY_COUNT)
    {
        return false;
    }
    
    return _gCurrentKeyState[keyCode];
}

bool MKLIsKeyReleased(const unsigned short keyCode)
{
    // Bounds checking
    if (keyCode >= KEY_COUNT)
    {
        return false;
    }
    
    // Key was just released if it was down before but isn't now
    return (_gPreviousKeyState[keyCode] == true) && (_gCurrentKeyState[keyCode] == false);
}

bool MKLIsKeyUp(const unsigned short keyCode)
{
    // Bounds checking
    if (keyCode >= KEY_COUNT)
    {
        return true; // Assume key is up if invalid
    }
    
    return !_gCurrentKeyState[keyCode];
}

int MKLGetKeyPressed(void)
{
    int keyCode = 0;
    
    if (_gKeyPressedQueueCount > 0)
    {
        // Get key from the queue head
        keyCode = _gKeyPressedQueue[0];
        
        // Shift elements 1 step toward the head
        for (unsigned int i = 0; i < (_gKeyPressedQueueCount - 1); i++)
        {
            _gKeyPressedQueue[i] = _gKeyPressedQueue[i + 1];
        }
        
        // Reset last key in the queue
        _gKeyPressedQueue[_gKeyPressedQueueCount - 1] = 0;
        _gKeyPressedQueueCount--;
    }
    
    return keyCode;
}

void MKLSetExitKey(const unsigned short keyCode)
{
    _gExitKey = keyCode;
}

unsigned short MKLGetExitKey(void)
{
    return _gExitKey;
}
