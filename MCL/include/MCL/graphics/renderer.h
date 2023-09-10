#ifndef _mcl_renderer_h_
#define _mcl_renderer_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"
#include "../../MCL/mcl_sys/gpu.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef struct MCL_FPoint
{
    float x, y;
} MCL_FPoint;

// The Surface which is used to draw on
// This is just going to be a MTKView
typedef struct MCL_Surface
{
    int x, y, w, h;
    void *layer;
    void *_this;
} MCL_Surface;

typedef struct MCL_Renderer
{
    MCL_VDevice *device;
    MCL_Window *window;
    void *context;
    MCL_Surface *surface;
    void *_this;
} MCL_Renderer;

void MCL_CreateRenderer(MCL_Window *window, MCL_Renderer *renderer);

void MCL_SetRendererSurface(MCL_Renderer *renderer, MCL_Surface *surface, int x, int y, int w, int h);

void MCL_ClearRenderer(MCL_Renderer *renderer, MCL_Color color);


#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _mcl_renderer_h_