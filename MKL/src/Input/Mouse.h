#ifndef _MKL_MOUSE_H_
#define _MKL_MOUSE_H_

#include "../Core/MKLCore.h"

#include <simd/conversion.h>
#include <stdbool.h>
#include <simd/vector.h>

/**
 * @brief Mouse button codes.
 */
typedef enum {
    MouseCodeLeft = 0,      ///< Left mouse button / Trackpad click
    MouseCodeRight = 1,     ///< Right mouse button
    MouseCodeCenter = 2,    ///< Center mouse button
} MouseCodes;

/**
 * @brief Cursor modes for the mouse.
 */
typedef enum {
    MKL_CURSOR_NORMAL = 0,      ///< Normal cursor behavior
    MKL_CURSOR_HIDDEN = 1,      ///< Cursor is hidden
    MKL_CURSOR_DISABLED = 2,    ///< Cursor is disabled and locked
} MKLCursorMode;

/**
 * @brief Sets the pressed state of a mouse button (internal use).
 * @param button The mouse button
 * @param isPressed true if button is pressed, false if released
 */
void MKLSetMouseButtonPressed(const MouseCodes button, const bool isPressed);

/**
 * @brief Updates mouse state for the next frame (internal use).
 */
void MKLUpdateMouseState(void);

/**
 * @brief Sets the overall mouse position (internal use).
 * @param x X coordinate
 * @param y Y coordinate
 */
void MKLSetMousePosition(const float x, const float y);

/**
 * @brief Sets mouse position delta (internal use).
 * @param dx X delta
 * @param dy Y delta
 */
void MKLSetMouseDelta(const float dx, const float dy);

/**
 * @brief Checks if a mouse button was just pressed (transitioned from up to down).
 *
 * @param button The mouse button to check
 * @return true if the button was just pressed this frame, false otherwise
 */
MKLAPI bool MKLIsMouseButtonPressed(const MouseCodes button);

/**
 * @brief Checks if a mouse button is currently being held down.
 *
 * @param button The mouse button to check
 * @return true if the button is down, false otherwise
 */
MKLAPI bool MKLIsMouseButtonDown(const MouseCodes button);

/**
 * @brief Checks if a mouse button was just released.
 *
 * @param button The mouse button to check
 * @return true if the button was just released this frame, false otherwise
 */
MKLAPI bool MKLIsMouseButtonReleased(const MouseCodes button);

/**
 * @brief Checks if a mouse button is currently up (not pressed).
 *
 * @param button The mouse button to check
 * @return true if the button is up, false otherwise
 */
MKLAPI bool MKLIsMouseButtonUp(const MouseCodes button);

/**
 * @brief Gets the mouse X position in window coordinates.
 *
 * @return X coordinate
 */
MKLAPI float MKLGetMouseX(void);

/**
 * @brief Gets the mouse Y position in window coordinates.
 *
 * @return Y coordinate
 */
MKLAPI float MKLGetMouseY(void);

/**
 * @brief Gets the mouse position in window coordinates.
 *
 * @return Mouse position as vector
 */
MKLAPI vector_float2 MKLGetMousePosition(void);

/**
 * @brief Gets the mouse X delta since last frame.
 *
 * @return X delta
 */
MKLAPI float MKLGetMouseDeltaX(void);

/**
 * @brief Gets the mouse Y delta since last frame.
 *
 * @return Y delta
 */
MKLAPI float MKLGetMouseDeltaY(void);

/**
 * @brief Gets the mouse delta since last frame.
 *
 * @return Mouse delta as vector
 */
MKLAPI vector_float2 MKLGetMouseDelta(void);

/**
 * @brief Updates the scroll wheel position.
 * @param deltaY Scroll delta in Y direction
 */
MKLAPI void MKLScrollMouse(const float deltaY);

/**
 * @brief Gets the mouse wheel movement this frame.
 *
 * @return Mouse wheel delta
 */
MKLAPI float MKLGetMouseWheelMove(void);

/**
 * @brief Gets the normalized mouse position in viewport coordinates.
 * @param viewportWidth Viewport width
 * @param viewportHeight Viewport height
 * @return Normalized position (-1 to 1 range)
 */
MKLAPI vector_float2 MKLGetMouseViewportPosition(const float viewportWidth, const float viewportHeight);

/**
 * @brief Sets the cursor mode.
 *
 * @param mode The cursor mode to set
 */
MKLAPI void MKLSetCursorMode(const MKLCursorMode mode);

/**
 * @brief Gets the current cursor mode.
 *
 * @return The current cursor mode
 */
MKLAPI MKLCursorMode MKLGetCursorMode(void);

#endif // _MKL_MOUSE_H_
