#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#include <objc/objc.h>
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
    id<MTLCommandBuffer> _commandBuffer;
    id<MTLRenderCommandEncoder> _renderEncoder;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    id<MTLLibrary> _library;
    id<MTLBuffer> _vertexBuffer;
    MTLVertexDescriptor *_vertexDescriptor;
    id<CAMetalDrawable> _drawable;
    id<MTLRenderPipelineState> _pipelineState;
    CAMetalLayer *_metalLayer;
    MTLClearColor _clearColor;
    MTKView *_view;
#endif
} MKLRenderer;

MKLAPI MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKLAPI void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKLAPI void MKLBeginDrawing(MKLRenderer *renderer);

MKLAPI void MKLEndDrawing(MKLRenderer *renderer);

MKLAPI void MKLDestroyRenderer(MKLRenderer *renderer);

#endif // _MKL_VIEW_H_