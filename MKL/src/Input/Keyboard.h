#ifndef _MKL_KEYBOARD_H_
#define _MKL_KEYBOARD_H_

#include "KeyCodes.h"
#include <stdbool.h>

#include "../Core/MKLCore.h"

/**
 * @brief Maximum number of keys in the press queue
 */
#define MKL_KEY_PRESS_QUEUE_SIZE 16

/**
 * @brief Sets the pressed state of a keyboard key (internal use).
 * @param keyCode The key code to update
 * @param isPressed true if key is pressed, false if released
 */
void MKLSetKeyPressed(const unsigned short keyCode, const bool isPressed);

/**
 * @brief Updates keyboard state for the next frame (internal use).
 * 
 * This should be called once per frame to update previous state.
 */
void MKLUpdateKeyboardState(void);

/**
 * @brief Checks if a key was just pressed (transitioned from up to down).
 * 
 * This returns true only on the first frame the key was pressed.
 * Use IsKeyDown for continuous key holding.
 * 
 * @param keyCode The key code to check
 * @return true if the key was just pressed this frame, false otherwise
 */
MKLAPI bool MKLIsKeyPressed(const unsigned short keyCode);

/**
 * @brief Checks if a key is currently being held down.
 * 
 * This returns true every frame while the key is held down.
 * Use IsKeyPressed for single-frame key presses.
 * 
 * @param keyCode The key code to check
 * @return true if the key is currently down, false otherwise
 */
MKLAPI bool MKLIsKeyDown(const unsigned short keyCode);

/**
 * @brief Checks if a key was just released (transitioned from down to up).
 * 
 * @param keyCode The key code to check
 * @return true if the key was just released this frame, false otherwise
 */
MKLAPI bool MKLIsKeyReleased(const unsigned short keyCode);

/**
 * @brief Checks if a key is currently up (not pressed).
 * 
 * @param keyCode The key code to check
 * @return true if the key is up, false otherwise
 */
MKLAPI bool MKLIsKeyUp(const unsigned short keyCode);

/**
 * @brief Gets the next key from the key press queue.
 * 
 * Returns the next key code from the press queue, or 0 if queue is empty.
 * Call this multiple times in a loop to get all queued key presses.
 * 
 * @return Key code from queue, or 0 if empty
 */
MKLAPI int MKLGetKeyPressed(void);

/**
 * @brief Sets a custom key to exit the application.
 * 
 * @param keyCode The key code that should exit the app (default: MKL_KEY_ESCAPE)
 */
MKLAPI void MKLSetExitKey(const unsigned short keyCode);

/**
 * @brief Gets the current exit key.
 * 
 * @return The current exit key code
 */
MKLAPI unsigned short MKLGetExitKey(void);

#endif // _MKL_KEYBOARD_H_
