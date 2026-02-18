#ifndef GULI_METAL_H
#define GULI_METAL_H

#include "Core/guli_core.h"
#include "guli_defines.h"

void MetalInit(GuliState* state);

void MetalShutdown(GuliState* state);

void MetalClearColor(GULI_COLOR color);

// Shader and Library Management
#endif // GULI_METAL_H