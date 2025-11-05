#ifndef _MKL_TIMER_H_
#define _MKL_TIMER_H_

#include "MKLCore.h"

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

/**
 * @brief Initializes the high-precision timer for the application.
 *
 * This function must be called before using any other timer functions.
 * It initializes the Mach timebase and starts the timer.
 */
MKLAPI void MKLInitTimer(void);

/**
 * @brief Returns the number of milliseconds elapsed since MKLInitTimer() was called.
 *
 * @return The number of milliseconds elapsed, or 0 if timer is not initialized.
 */
MKLAPI unsigned int MKLGetTicks(void);

/**
 * @brief Frame-rate limiting function that sleeps to maintain target FPS.
 *
 * @param fps Target frames per second (must be positive).
 * @return The actual elapsed time in milliseconds since the last call.
 */
MKLAPI unsigned int MKLTicks(int fps);

/**
 * @brief Returns the current average framerate.
 *
 * Calculates the average FPS based on the last 10 frame times.
 *
 * @return The average frames per second, or 0.0 if timer is not initialized.
 */
MKLAPI float MKLGetFPS(void);

/**
 * @brief Returns the current time in seconds (like raylib's GetTime()).
 *
 * Returns the elapsed time since MKLInitTimer() was called, in seconds.
 * This is equivalent to raylib's GetTime() function.
 *
 * @return The elapsed time in seconds, or 0.0 if timer is not initialized.
 */
MKLAPI float MKLGetTime(void);

#endif // _MKL_TIMER_H_
