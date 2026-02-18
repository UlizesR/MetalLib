#ifndef GULI_GL_H
#define GULI_GL_H

#include "Core/guli_core.h"
#include "guli_defines.h"

GULIResult GlInit(GuliState* state);

void GlShutdown(GuliState* state);

void GlBeginDraw(void);

void GlEndDraw(void);

void GlClearColor(GULI_COLOR color);

int GlHasActiveFrame(void);

void GlDrawFullscreen(void);

#endif /* GULI_GL_H */
