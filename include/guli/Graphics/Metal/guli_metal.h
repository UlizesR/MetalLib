#ifndef GULI_METAL_H
#define GULI_METAL_H

#include "Core/guli_core.h"
#include "guli_defines.h"

GULIResult MetalInit(GuliState* state);

void MetalShutdown(GuliState* state);

// Frame submission
void MetalBeginFrame(void);

void MetalBeginPass(GULI_COLOR clearColor, double clearDepth);

void MetalEndPass(void);

void MetalEndFrame(void);

// Returns 1 if a frame is active (GuliBeginDraw was called), 0 otherwise
int MetalHasActiveFrame(void);

// Clear only (BeginPass + EndPass); requires active frame. Standalone: BeginFrame + ClearColor + EndFrame
void MetalClearColor(GULI_COLOR color);

#endif // GULI_METAL_H
