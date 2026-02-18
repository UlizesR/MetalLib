#ifndef GULI_METAL_H
#define GULI_METAL_H

#include "Core/guli_core.h"
#include "guli_defines.h"

GULIResult MetalInit(GuliState* state);

void MetalShutdown(GuliState* state);

// Frame submission (BeginDraw/EndDraw handle pass internally)
void MetalBeginDraw(void);

void MetalEndDraw(void);

void MetalDrawFullscreen(void);

// Returns 1 if between MetalBeginDraw and MetalEndDraw, 0 otherwise
int MetalHasActiveFrame(void);

// Clear color; only valid between MetalBeginDraw and MetalEndDraw
void MetalClearColor(GULI_COLOR color);

#endif // GULI_METAL_H
