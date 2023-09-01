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
@end

@interface M_MView : MTKView
@property(strong) MTK_Renderer *_delegate;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M_Renderer {
#ifdef __OBJC__
    MTK_Renderer *_delegate;
    M_MView *_view;
#endif
  void *_this; // C/C++ pointer to this struct _delegate
} M_Renderer;

void M_Renderer_init(M_Renderer *renderer, M_Window *window);

void M_Renderer_destroy(M_Renderer *renderer);

void M_Renderer_Clear(M_Renderer *renderer, M_Color color);

#ifdef __cplusplus
}
#endif