#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#include <stdint.h>

#include "../MKLWindow.h"
#include "../MKLCore.h"
#include "../MKLColors.h"

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

#endif 

typedef struct MKLRenderer
{
    MKLWindow *window;
#ifdef __OBJC__
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    NSAutoreleasePool *_pool;
    MTKView *_view;
    CAMetalLayer *_metalLayer;
    MTLClearColor _clearColor;
    // library variables
    id<MTLLibrary> _library;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    MTLVertexDescriptor *_vertexDescriptor;
    id<MTLRenderPipelineState> _pipelineState;
    // drawing variables
    id<CAMetalDrawable> _drawable;
    id<MTLCommandBuffer> _commandBuffer;
    id<MTLBuffer> _vertexBuffer;
    id<MTLRenderCommandEncoder> _renderEncoder;
#endif
} MKLRenderer;

MKLAPI MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKLAPI void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKLAPI void MKLBeginDrawing(MKLRenderer *renderer);

MKLAPI void MKLEndDrawing(MKLRenderer *renderer);

MKLAPI void MKLDestroyRenderer(MKLRenderer *renderer);

#endif // _MKL_VIEW_H_