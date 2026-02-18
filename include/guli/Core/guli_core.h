#ifndef GULI_CORE_H
#define GULI_CORE_H

#include "guli_window_backend.h"
#include "guli_error.h"

#define GULI_API __attribute__((visibility("default")))

#define GULI_VERSION_MAJOR 0
#define GULI_VERSION_MINOR 1
#define GULI_VERSION_PATCH 0
#define GULI_VERSION_STRING "0.1.0"

#define GULI_VERSION_CHECK(major, minor, patch) \
    (GULI_VERSION_MAJOR > (major) || \
     (GULI_VERSION_MAJOR == (major) && GULI_VERSION_MINOR > (minor)) || \
     (GULI_VERSION_MAJOR == (major) && GULI_VERSION_MINOR == (minor) && GULI_VERSION_PATCH >= (patch)))

// Check Platform and set appropriate graphics backend
#if defined(GULI_FORCE_OPENGL)
#define GULI_BACKEND_OPENGL
#elif defined(__APPLE__)
#define GULI_BACKEND_METAL
#elif defined(__linux__) || defined(_WIN32)
#define GULI_BACKEND_OPENGL
#else
#error "Unsupported platform"
#endif

#ifdef GULI_BACKEND_METAL
struct MetalState;  /* forward declaration; full def in guli_metal_defines.h (ObjC only) */
#include "Graphics/Metal/guli_metal_defines.h"
#endif
#ifdef GULI_BACKEND_OPENGL
struct GLState;  /* forward declaration; full def in guli_gl_defines.h */
#include "Graphics/OpenGL/guli_gl_defines.h"
#endif

typedef struct
{
    GuliWindow* window;
    GuliError error;
#ifdef GULI_BACKEND_METAL
    struct MetalState* metal_s;
#endif
#ifdef GULI_BACKEND_OPENGL
    struct GLState* gl_s;
#endif
} GuliState;

// Global state
extern GuliState G_State;

/* Window and event API (use G_State.window internally, no window parameter) */
static inline int GuliGetKey(GuliKey key)
{
    return GuliBackendGetKey(G_State.window, key);
}

static inline int GuliGetMouseButton(GuliMouseButton button)
{
    return GuliBackendGetMouseButton(G_State.window, button);
}

static inline void GuliGetCursorPos(double* xpos, double* ypos)
{
    GuliBackendGetCursorPos(G_State.window, xpos, ypos);
}

static inline void GuliSetInputMode(GuliInputMode mode, int value)
{
    GuliBackendSetInputMode(G_State.window, mode, value);
}

static inline int GuliWindowShouldClose(void)
{
    return GuliBackendWindowShouldClose(G_State.window);
}

static inline void GuliSetWindowShouldClose(int value)
{
    GuliBackendSetWindowShouldClose(G_State.window, value);
}

static inline void GuliGetFramebufferSize(int* width, int* height)
{
    GuliBackendGetFramebufferSize(G_State.window, width, height);
}

static inline void GuliGetWindowSize(int* width, int* height)
{
    GuliBackendGetWindowSize(G_State.window, width, height);
}

static inline void GuliSetWindowTitle(const char* title)
{
    GuliBackendSetWindowTitle(G_State.window, title);
}

static inline void GuliSetKeyCallback(void (*callback)(GuliWindow* window, int key, int scancode, int action, int mods))
{
    GuliBackendSetKeyCallback(G_State.window, callback);
}

static inline void GuliWindowDestroy(void)
{
    GuliBackendWindowDestroy(G_State.window);
}

GULI_API short GuliInit(uint32_t width, uint32_t height, const char* title);

GULI_API void GuliShutdown(void);

#endif // GULI_CORE_H
