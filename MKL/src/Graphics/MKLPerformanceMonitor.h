//
// MKLPerformanceMonitor.h
// MetalLib - Performance Monitoring
//

#ifndef MKLPerformanceMonitor_h
#define MKLPerformanceMonitor_h

#include <stdbool.h>
#include "../Core/MKLCore.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MKLPerformanceStats {
    float currentFPS;
    float averageFPS;
    float frameTimeMS;
    float minFrameTimeMS;
    float maxFrameTimeMS;
    unsigned long frameCount;
    double totalTime;
} MKLPerformanceStats;

typedef struct MKLPerformanceMonitor MKLPerformanceMonitor;

MKLAPI MKLPerformanceMonitor *MKLCreatePerformanceMonitor(void);
MKLAPI void MKLPerformanceMonitorBeginFrame(MKLPerformanceMonitor *monitor);
MKLAPI void MKLPerformanceMonitorEndFrame(MKLPerformanceMonitor *monitor);
MKLAPI MKLPerformanceStats MKLGetPerformanceStats(MKLPerformanceMonitor *monitor);
MKLAPI void MKLPrintPerformanceStats(MKLPerformanceMonitor *monitor);
MKLAPI void MKLResetPerformanceStats(MKLPerformanceMonitor *monitor);
MKLAPI void MKLDestroyPerformanceMonitor(MKLPerformanceMonitor *monitor);

#ifdef __cplusplus
}
#endif

#endif /* MKLPerformanceMonitor_h */

