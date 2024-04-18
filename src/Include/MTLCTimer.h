#ifndef _MTLC_TIMER_H_
#define _MTLC_TIMER_H_

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// Initializes the timer for the application
void MTLCInitTimer();

// Returns the number of ticks since the last call to MTLCInitTimer()
unsigned int MTLCGetTicks();

// Given a target FPS, returns the number of ticks to wait until the next frame
// Returns time in milliseconds
unsigned int MTLCTicks(int fps);

float MTLCGetFPS();

#endif // _MTLC_TIMER_H_