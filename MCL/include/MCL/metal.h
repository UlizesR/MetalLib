#pragma once

#include "colors.h"
#include "defs.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MTK_Renderer : NSObject <MTKViewDelegate>
@property(strong) id<MTLDevice> _device;
@property(strong) id<MTLLibrary> _library;
@property(strong) id<MTLRenderPipelineState> _pipelineState;
@property(strong) id<MTLBuffer> _vertexBuffer;
@property(strong) id<MTLBuffer> _uniformBuffer;
@property(strong) id<MTLCommandQueue> _commandQueue;
@property(strong) id<MTLRenderCommandEncoder> _renderEncoder;
@property(strong) MTKView *_view;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M_Renderer {
    #ifdef __OBJC__
    MTK_Renderer *_renderer;
    MTKView *_mview;
    #endif
    void *_device;
    void *_delegate;
    void *_view;
} M_Renderer;

M_Renderer *M_Renderer_init(M_Window *window);

void M_Renderer_destroy(M_Renderer *renderer);

void M_Renderer_Clear(M_Renderer *renderer, M_Color color);

void drawLine(M_Renderer *renderer, MFPoint vertices[], M_Color color);

void drawTriangle(M_Renderer *renderer, MFPoint vertices[], M_Color color);

void drawQuad(M_Renderer *renderer, MFPoint vertices[], M_Color color);

void drawPolygon(M_Renderer *renderer, MFPoint vertices[], int n, M_Color color);

void drawCircle(M_Renderer *renderer, MFPoint center, float radius, M_Color color);

#ifdef __cplusplus
}
#endif