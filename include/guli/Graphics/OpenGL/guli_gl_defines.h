#ifndef GULI_GL_DEFINES_H
#define GULI_GL_DEFINES_H

#include "guli_defines.h"

#if defined(__APPLE__)
#define GL_SEM_WAIT(gl) dispatch_semaphore_wait((gl)->inflight_semaphore, DISPATCH_TIME_FOREVER)
#define GL_SEM_POST(gl) dispatch_semaphore_signal((gl)->inflight_semaphore)
#else
#define GL_SEM_WAIT(gl) sem_wait(&(gl)->inflight_semaphore)
#define GL_SEM_POST(gl) sem_post(&(gl)->inflight_semaphore)
#endif

struct GLState {
    int has_active_frame;
    unsigned int frame_index;
    GuliSemaphore inflight_semaphore;
    unsigned int fullscreen_vao;  /* VAO for gl_VertexID fullscreen triangle (core profile) */
};

#endif /* GULI_GL_DEFINES_H */
