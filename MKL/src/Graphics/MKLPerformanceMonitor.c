//
// MKLPerformanceMonitor.c
// MetalLib - Performance Monitoring Implementation
//

#include "MKLPerformanceMonitor.h"
#include "../Core/MKLTimer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SAMPLE_WINDOW 60

struct MKLPerformanceMonitor {
    double lastFrameTime;
    double frameStartTime;
    unsigned long frameCount;
    double totalTime;
    
    // Rolling window for accurate average
    double frameTimes[SAMPLE_WINDOW];
    int frameTimeIndex;
    
    float minFrameTime;
    float maxFrameTime;
    float currentFPS;
};

MKLPerformanceMonitor *MKLCreatePerformanceMonitor(void) {
    MKLPerformanceMonitor *monitor = (MKLPerformanceMonitor *)calloc(1, sizeof(MKLPerformanceMonitor));
    if (!monitor) {
        return NULL;
    }
    
    monitor->lastFrameTime = MKLGetTime();
    monitor->minFrameTime = 999999.0f;
    monitor->maxFrameTime = 0.0f;
    
    return monitor;
}

void MKLPerformanceMonitorBeginFrame(MKLPerformanceMonitor *monitor) {
    if (!monitor) return;
    monitor->frameStartTime = MKLGetTime();
}

void MKLPerformanceMonitorEndFrame(MKLPerformanceMonitor *monitor) {
    if (!monitor) return;
    
    double currentTime = MKLGetTime();
    double frameTime = currentTime - monitor->lastFrameTime;
    monitor->lastFrameTime = currentTime;
    
    // Update rolling window
    monitor->frameTimes[monitor->frameTimeIndex] = frameTime;
    monitor->frameTimeIndex = (monitor->frameTimeIndex + 1) % SAMPLE_WINDOW;
    
    // Update stats
    float frameTimeMS = (float)(frameTime * 1000.0);
    if (frameTimeMS < monitor->minFrameTime) monitor->minFrameTime = frameTimeMS;
    if (frameTimeMS > monitor->maxFrameTime) monitor->maxFrameTime = frameTimeMS;
    
    monitor->currentFPS = frameTime > 0.0 ? (float)(1.0 / frameTime) : 0.0f;
    monitor->frameCount++;
    monitor->totalTime += frameTime;
}

MKLPerformanceStats MKLGetPerformanceStats(MKLPerformanceMonitor *monitor) {
    MKLPerformanceStats stats = {0};
    if (!monitor) return stats;
    
    // Calculate average from rolling window
    double sum = 0.0;
    int count = monitor->frameCount < SAMPLE_WINDOW ? (int)monitor->frameCount : SAMPLE_WINDOW;
    for (int i = 0; i < count; i++) {
        sum += monitor->frameTimes[i];
    }
    double avgFrameTime = count > 0 ? sum / count : 0.0;
    
    stats.currentFPS = monitor->currentFPS;
    stats.averageFPS = avgFrameTime > 0.0 ? (float)(1.0 / avgFrameTime) : 0.0f;
    stats.frameTimeMS = (float)(avgFrameTime * 1000.0);
    stats.minFrameTimeMS = monitor->minFrameTime;
    stats.maxFrameTimeMS = monitor->maxFrameTime;
    stats.frameCount = monitor->frameCount;
    stats.totalTime = monitor->totalTime;
    
    return stats;
}

void MKLPrintPerformanceStats(MKLPerformanceMonitor *monitor) {
    if (!monitor) return;
    
    MKLPerformanceStats stats = MKLGetPerformanceStats(monitor);
    
    printf("\n╔═══════════════════════════════════════════════════════╗\n");
    printf("║           PERFORMANCE STATISTICS                     ║\n");
    printf("╠═══════════════════════════════════════════════════════╣\n");
    printf("║ Current FPS:  %6.1f fps                             ║\n", stats.currentFPS);
    printf("║ Average FPS:  %6.1f fps                             ║\n", stats.averageFPS);
    printf("║ Frame Time:   %6.2f ms (avg)                        ║\n", stats.frameTimeMS);
    printf("║ Min/Max:      %6.2f / %.2f ms                       ║\n", stats.minFrameTimeMS, stats.maxFrameTimeMS);
    printf("║ Total Frames: %lu                                    ║\n", stats.frameCount);
    printf("║ Total Time:   %.2f seconds                          ║\n", stats.totalTime);
    printf("╚═══════════════════════════════════════════════════════╝\n\n");
}

void MKLResetPerformanceStats(MKLPerformanceMonitor *monitor) {
    if (!monitor) return;
    
    monitor->frameCount = 0;
    monitor->totalTime = 0.0;
    monitor->minFrameTime = 999999.0f;
    monitor->maxFrameTime = 0.0f;
    monitor->frameTimeIndex = 0;
    memset(monitor->frameTimes, 0, sizeof(monitor->frameTimes));
}

void MKLDestroyPerformanceMonitor(MKLPerformanceMonitor *monitor) {
    if (!monitor) return;
    free(monitor);
}

