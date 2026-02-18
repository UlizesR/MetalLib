#ifndef GULI_GRAPHICS_H
#define GULI_GRAPHICS_H

#include "Core/guli_core.h"
#include "guli_defines.h"

/* Shared logic: clear inside active frame, or wrap in Begin/End when standalone */
#define GULI_CLEAR_COLOR_IMPL(BEGIN, CLEAR, END, HAS_ACTIVE) \
    static inline void GuliClearColor(GULI_COLOR color) {     \
        if (HAS_ACTIVE())                                     \
            CLEAR(color);                                     \
        else {                                                \
            BEGIN();                                          \
            CLEAR(color);                                     \
            END();                                            \
        }                                                     \
    }

#ifdef GULI_BACKEND_METAL
#include "Metal/guli_metal.h"
GULI_CLEAR_COLOR_IMPL(MetalBeginFrame, MetalClearColor, MetalEndFrame, MetalHasActiveFrame)
static inline void GuliBeginDraw(void) { MetalBeginFrame(); }
static inline void GuliEndDraw(void) { MetalEndFrame(); }
#endif

#ifdef GULI_BACKEND_OPENGL
#include "OpenGL/guli_gl.h"
GULI_CLEAR_COLOR_IMPL(GlBeginFrame, GlClearColor, GlEndFrame, GlHasActiveFrame)
static inline void GuliBeginDraw(void) { GlBeginFrame(); }
static inline void GuliEndDraw(void) { GlEndFrame(); }
#endif

#endif // GULI_GRAPHICS_H
