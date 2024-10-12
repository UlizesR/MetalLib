#ifndef _MKL_TIMER_H_
#define _MKL_TIMER_H_

#include "MKLCore.h"

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// Initializes the timer for the application
void MKLInitTimer();

// Returns the number of ticks since the last call to MKLInitTimer()
MKLAPI unsigned int MKLGetTicks();

// Given a target FPS, returns the number of ticks to wait until the next frame
// Returns time in milliseconds
MKLAPI unsigned int MKLTicks(int fps);

MKLAPI float MKLGetFPS();
#endif // _MKL_TIMER_H_