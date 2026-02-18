#ifndef GULI_GRAPHICS_H
#define GULI_GRAPHICS_H

#include "Core/guli_core.h"
#include "guli_defines.h"

#ifdef GULI_BACKEND_METAL
#include "Metal/guli_metal.h"
static inline void GuliClearColor(GULI_COLOR color)
{
    MetalClearColor(color);
}
#elif defined(GULI_BACKEND_OPENGL)
static inline void GuliClearColor(GULI_COLOR color)
{
    (void)color;
    /* TODO: OpenGL implementation */
}
#else
#error "No graphics backend defined"
#endif

#endif // GULI_GRAPHICS_H