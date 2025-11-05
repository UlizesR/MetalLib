#include "MKLTimer.h"
#include <mach/mach_time.h>
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

// Static timebase information - cached to avoid repeated kernel calls
static mach_timebase_info_data_t _gTimebaseInfo;
static uint64_t _gStartTime = 0;
static bool _gInitialized = false;

void MKLInitTimer(void)
{
    if (_gInitialized)
    {
        return;
    }

    _gStartTime = mach_absolute_time();

    kern_return_t result = mach_timebase_info(&_gTimebaseInfo);
    if (result == KERN_SUCCESS)
    {
        _gInitialized = true;
    }
    else
    {
        fprintf(stderr, "MKL Error: Unable to initialize timer - mach_timebase_info failed with code %d\n", result);
    }
}

unsigned int MKLGetTicks(void)
{
    if (!_gInitialized)
    {
        fprintf(stderr, "MKL Warning: MKLGetTicks() called before MKLInitTimer()\n");
        return 0;
    }

    const uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - _gStartTime;

    // Convert elapsed time to milliseconds using cached timebase info
    elapsed_time *= _gTimebaseInfo.numer;
    elapsed_time /= _gTimebaseInfo.denom;

    return (unsigned int)(elapsed_time / 1000000ULL); // Convert nanoseconds to milliseconds
}

unsigned int MKLTicks(int fps)
{
    if (!_gInitialized)
    {
        fprintf(stderr, "MKL Warning: MKLTicks() called before MKLInitTimer()\n");
        return 0;
    }

    if (fps <= 0)
    {
        fprintf(stderr, "MKL Warning: Invalid FPS value (%d), must be positive\n", fps);
        return 0;
    }

    static uint64_t previous_time = 0;
    const uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - previous_time;

    // Convert elapsed time to milliseconds using cached timebase info
    elapsed_time *= _gTimebaseInfo.numer;
    elapsed_time /= _gTimebaseInfo.denom;
    const unsigned int elapsed_ms = (unsigned int)(elapsed_time / 1000000ULL);

    // Calculate the target frame time in milliseconds
    const unsigned int target_frame_time = 1000U / (unsigned int)fps;

    // Update the previous time
    previous_time = current_time;

    // Sleep only if the frame time is greater than the elapsed time
    if (target_frame_time > elapsed_ms)
    {
        usleep((target_frame_time - elapsed_ms) * 1000U); // Sleep in microseconds
    }

    return elapsed_ms;
}

#define MAX_FPS_SAMPLES 10

static unsigned int _gFpsSamples[MAX_FPS_SAMPLES] = {0}; // Array to store FPS samples
static unsigned int _gFpsSampleIndex = 0; // Index to track the current sample position
static unsigned int _gFrameCount = 0;
static unsigned int _gLastFrameTime = 0;

float MKLGetFPS(void)
{
    if (!_gInitialized)
    {
        fprintf(stderr, "MKL Warning: MKLGetFPS() called before MKLInitTimer()\n");
        return 0.0f;
    }

    // Calculate elapsed time since the last frame
    const unsigned int current_time = MKLGetTicks();
    const unsigned int elapsed_time = current_time - _gLastFrameTime;
    _gLastFrameTime = current_time;

    // Avoid division by zero
    if (elapsed_time == 0)
    {
        return 0.0f;
    }

    // Calculate the instantaneous framerate and store it in the array
    const float instantaneous_fps = 1000.0f / (float)elapsed_time;
    _gFpsSamples[_gFpsSampleIndex] = (unsigned int)instantaneous_fps;
    _gFpsSampleIndex = (_gFpsSampleIndex + 1) % MAX_FPS_SAMPLES;

    // Calculate the average framerate based on the last samples
    if (_gFrameCount < MAX_FPS_SAMPLES)
    {
        _gFrameCount++;
    }

    unsigned int sum_fps = 0;
    for (unsigned int i = 0; i < _gFrameCount; i++)
    {
        sum_fps += _gFpsSamples[i];
    }

    const float average_fps = (float)sum_fps / (float)_gFrameCount;
    return average_fps;
}

float MKLGetTime(void)
{
    if (!_gInitialized)
    {
        fprintf(stderr, "MKL Warning: MKLGetTime() called before MKLInitTimer()\n");
        return 0.0f;
    }

    const uint64_t current_time = mach_absolute_time();
    uint64_t elapsed_time = current_time - _gStartTime;

    // Convert elapsed time to seconds using cached timebase info
    elapsed_time *= _gTimebaseInfo.numer;
    elapsed_time /= _gTimebaseInfo.denom;

    return (float)(elapsed_time / 1000000000.0); // Convert nanoseconds to seconds
}
