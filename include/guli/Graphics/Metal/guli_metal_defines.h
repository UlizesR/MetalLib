#ifndef GULI_METAL_DEFINES_H
#define GULI_METAL_DEFINES_H

#ifdef __OBJC__
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "guli_defines.h"

struct MetalState {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    CAMetalLayer* _layer;

    // Frame pacing / indexing
    GuliSemaphore _inflightSemaphore;
    NSUInteger _frameIndex;

    // Active per-frame objects (single-threaded submission model)
    id<MTLCommandBuffer> _cmd;
    id<MTLRenderCommandEncoder> _enc;
    id<CAMetalDrawable> _drawable;

    // Render target configuration
    MTLPixelFormat _colorFormat;
    MTLPixelFormat _depthFormat;
    NSUInteger _sampleCount;
    BOOL _useDepth;
    CGSize _drawableSize;  // pixels

    // Reusable per-frame onscreen pass descriptors
    MTLRenderPassDescriptor* _onscreenPassDesc[GULI_MAX_FRAMES_IN_FLIGHT];

    // Size-dependent attachments (created on resize)
    id<MTLTexture> _msaaColor;
    id<MTLTexture> _depth;

    // Clear pipeline (fullscreen draw with color uniform)
    id<MTLRenderPipelineState> _clearPipeline;
    id<MTLBuffer> _clearUniformBuffer;
};
#endif

#endif
