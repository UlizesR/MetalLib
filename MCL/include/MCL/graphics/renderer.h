#ifndef _mcl_renderer_h_
#define _mcl_renderer_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"
#include "../../MCL/mcl_sys/gpu.h"
#include "scene.h"
#include <MCL/graphics/scene.h>

#ifdef __OBJC__
@interface MCL_NsTriangle : NSObject
@property(nonatomic, assign) id<MTLBuffer> vertexBuffer;
@end

@interface MTK_Renderer : NSObject <MTKViewDelegate>
@property(nonatomic, strong) id<MTLDevice> device;
@property(nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property(nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property(nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property(nonatomic, strong) MCL_NsScene *scene;
@property(nonatomic, strong) MCL_NsTriangle *mesh;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#define MCL_FPOINT2VECTOR_F2(point) ((vector_float2){point.x, point.y})

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