#ifndef _MKL_INPUT_H_
#define _MKL_INPUT_H_

#include "../Core/MKLCore.h"
#include <stdbool.h>

/**
 * @brief Polls and processes input events from the operating system.
 * 
 * This function should be called once per frame in the main loop.
 * It processes keyboard, mouse, and other input events.
 * This follows the GLFW pollEvents pattern.
 */
MKLAPI void MKLPollEvents(void);

/**
 * @brief Waits for events with a timeout.
 * 
 * Blocks until an event is received or timeout expires.
 * Following GLFW's WaitEventsTimeout pattern.
 * 
 * @param timeout Timeout in seconds
 */
MKLAPI void MKLWaitEventsTimeout(const double timeout);

/**
 * @brief Updates input state for the next frame.
 * 
 * This should be called at the end of each frame to update
 * previous state for next frame's input queries.
 * Following raylib's pattern for state management.
 */
MKLAPI void MKLUpdateInputState(void);

#endif /* _MKL_INPUT_H_ */

