#include "MKLTimer.h"
#include <mach/mach_time.h>
#include <stdio.h>
#include <unistd.h>

static uint64_t _gStartTime;
static int _gInitialized = 0;

void MKLInitTimer()
{
    if (!_gInitialized)
    {
        _gStartTime = mach_absolute_time();
        mach_timebase_info_data_t timebase_info;
        if (mach_timebase_info(&timebase_info) == KERN_SUCCESS)
        {
            _gInitialized = 1;
        }
        else
        {
            fprintf(stderr, "Error: Unable to get timebase info.\n");
        }
    }
}

unsigned int MKLGetTicks()
{
    if (!_gInitialized)
    {
        return 0;
    }

    uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - _gStartTime;

    // Convert elapsed time to milliseconds
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    elapsed_time *= timebase_info.numer;
    elapsed_time /= timebase_info.denom;

    return (unsigned int)(elapsed_time / 1000000); // Convert to milliseconds
}

unsigned int MKLTicks(int fps)
{
    if (!_gInitialized)
    {
        return 0;
    }

    static uint64_t previous_time = 0;
    uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - previous_time;

    // Convert elapsed time to milliseconds
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    elapsed_time *= timebase_info.numer;
    elapsed_time /= timebase_info.denom;
    unsigned int elapsed_ms = (unsigned int)(elapsed_time / 1000000);

    // Calculate the target frame time in milliseconds
    unsigned int target_frame_time = 1000 / fps;

    // Update the previous time
    previous_time = current_time;

    // Sleep only if the frame time is greater than the elapsed time
    if (target_frame_time > elapsed_ms)
    {
        usleep((target_frame_time - elapsed_ms) * 1000); // Sleep in microseconds
    }

    return elapsed_ms;
}