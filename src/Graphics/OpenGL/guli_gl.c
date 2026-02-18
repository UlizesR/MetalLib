#include "Graphics/OpenGL/guli_gl.h"

#include <glad/glad.h>
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <stdlib.h>

#if defined(__APPLE__)
#define GL_SEM_WAIT(gl) dispatch_semaphore_wait((gl)->inflight_semaphore, DISPATCH_TIME_FOREVER)
#define GL_SEM_POST(gl) dispatch_semaphore_signal((gl)->inflight_semaphore)
#else
#define GL_SEM_WAIT(gl) sem_wait(&(gl)->inflight_semaphore)
#define GL_SEM_POST(gl) sem_post(&(gl)->inflight_semaphore)
#endif

GULIResult GlInit(GuliState* state)
{
    if (!state)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to initialize OpenGL: state is NULL");
        return GULI_ERROR_FAILED;
    }
    if (!state->window)
    {
        GuliSetError(&state->error, GULI_ERROR_FAILED, "Failed to initialize OpenGL: window is NULL");
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to initialize OpenGL: window is NULL");
        return GULI_ERROR_FAILED;
    }

    glfwMakeContextCurrent(state->window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        GuliSetError(&state->error, GULI_ERROR_FAILED, "Failed to initialize GLAD");
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to initialize GLAD");
        return GULI_ERROR_FAILED;
    }

    glfwSwapInterval(1);

    state->gl_s = calloc(1, sizeof(struct GLState));
    if (!state->gl_s)
    {
        GuliSetError(&state->error, GULI_ERROR_FAILED, "Failed to allocate GL state");
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to allocate GL state");
        return GULI_ERROR_FAILED;
    }

#if defined(__APPLE__)
    state->gl_s->inflight_semaphore = dispatch_semaphore_create(GULI_MAX_FRAMES_IN_FLIGHT);
    if (!state->gl_s->inflight_semaphore)
#else
    if (sem_init(&state->gl_s->inflight_semaphore, 0, GULI_MAX_FRAMES_IN_FLIGHT) != 0)
#endif
    {
        free(state->gl_s);
        state->gl_s = NULL;
        GuliSetError(&state->error, GULI_ERROR_FAILED, "Failed to create frame semaphore");
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to create frame semaphore");
        return GULI_ERROR_FAILED;
    }

    state->gl_s->has_active_frame = 0;
    state->gl_s->frame_index = 0;
    GuliSetError(&state->error, GULI_ERROR_SUCCESS, NULL);
    return GULI_ERROR_SUCCESS;
}

void GlShutdown(GuliState* state)
{
    if (!state)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to shutdown OpenGL: state is NULL");
        return;
    }
    if (!state->gl_s)
    {
        GULI_FAIL_RETURN(state, GULI_ERROR_FAILED, "Failed to shutdown OpenGL: gl_s is NULL");
    }

#if defined(__APPLE__)
    state->gl_s->inflight_semaphore = NULL;
#else
    sem_destroy(&state->gl_s->inflight_semaphore);
#endif
    free(state->gl_s);
    state->gl_s = NULL;

    GuliSetError(&state->error, GULI_ERROR_SUCCESS, "OpenGL shutdown successfully");
}

void GlBeginFrame(void)
{
    struct GLState* gl = G_State.gl_s;
    if (!gl) return;

    GL_SEM_WAIT(gl);

    gl->has_active_frame = 1;
    gl->frame_index = (gl->frame_index + 1) % GULI_MAX_FRAMES_IN_FLIGHT;

    int w = 0, h = 0;
    GuliGetFramebufferSize(&w, &h);
    if (w > 0 && h > 0)
        glViewport(0, 0, w, h);
}

void GlClearColor(GULI_COLOR color)
{
    struct GLState* gl = G_State.gl_s;
    if (!gl) return;

    glClearColor(color[0], color[1], color[2], color[3]);
    glClear(GL_COLOR_BUFFER_BIT);
}

void GlEndFrame(void)
{
    struct GLState* gl = G_State.gl_s;
    if (!gl) return;

    gl->has_active_frame = 0;
    glfwSwapBuffers(G_State.window);
    GL_SEM_POST(gl);
}

int GlHasActiveFrame(void)
{
    struct GLState* gl = G_State.gl_s;
    return (gl && gl->has_active_frame) ? 1 : 0;
}
