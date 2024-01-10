#import "Core/MKLTimer.h"

#import <math.h>
#import <Cocoa/Cocoa.h>


void MKLSetFPS(int fps)
{
    _gFPS = fps;
}

void MKLStartTimer(MKLTimer *timer)
{
    timer->startTime = [NSDate date];
}

void MKLStopTimer(MKLTimer *timer)
{   
    timer->endTime = [NSDate date];
}

double MKLGetTimeSec(MKLTimer *timer)
{
    NSTimeInterval timeInterval = [timer->endTime timeIntervalSinceDate:timer->startTime];
    return timeInterval;
}

double MKLGetTimeMSec(MKLTimer *timer)
{
    NSTimeInterval timeInterval = [timer->endTime timeIntervalSinceDate:timer->startTime];
    double timeInMilliseconds = timeInterval * 1000;
    timeInMilliseconds = round(timeInMilliseconds * 100.0) / 100.0;  // Round to two decimal places
    return timeInMilliseconds;
}

int MKLGetFPS(MKLTimer *timer)
{
    double mtime = MKLGetTimeMSec(timer);

    int fps = ceil(1000.0 / mtime);

    return fps;
}

int MKLGetTicksPerSecond(MKLTimer *timer)
{
    double mtime = MKLGetTimeSec(timer);  // Get elapsed time in seconds
    int ticks = ceil(1.0f / mtime);  // Calculate ticks per second

    return ticks;
}