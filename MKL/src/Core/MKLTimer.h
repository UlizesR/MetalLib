#ifndef _MKL_TIMER_H_
#define _MKL_TIMER_H_

#include <sys/time.h>

#include "Core/MKLCore.h"

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

typedef struct MKLTimer 
{
#ifdef __OBJC__
    NSDate *startTime;          // start date
    NSDate *endTime;            // end date
#endif

} MKLTimer;

static int _gFPS;

MKLAPI void MKLSetFPS(int fps);

MKLAPI void MKLStartTimer(MKLTimer *timer);

MKLAPI void MKLStopTimer(MKLTimer *timer);

MKLAPI double MKLGetTimeSec(MKLTimer *timer);

MKLAPI double MKLGetTimeMSec(MKLTimer *timer);

MKLAPI int MKLGetFPS(MKLTimer *timer);

MKLAPI int MKLGetTicksPerSecond(MKLTimer *timer);

#endif // _MKL_TIMER_H_