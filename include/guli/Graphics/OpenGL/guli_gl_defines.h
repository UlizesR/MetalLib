#ifndef GULI_GL_DEFINES_H
#define GULI_GL_DEFINES_H

#include "guli_defines.h"

#if defined(__APPLE__)
#include <dispatch/dispatch.h>
typedef dispatch_semaphore_t GuliSemaphore;
#else
#include <semaphore.h>
typedef sem_t GuliSemaphore;
#endif

struct GLState {
    int has_active_frame;
    unsigned int frame_index;
    GuliSemaphore inflight_semaphore;
};

#endif /* GULI_GL_DEFINES_H */
