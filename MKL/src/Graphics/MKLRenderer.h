#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#include <stdint.h>

#include "../MKLWindow.h"
#include "../Core/MKLCore.h"
#include "Objects/MKLEntity.h"

#include "MKLColors.h"
#include "MKLTypes.h"

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

@interface MTKView (TrackingArea)

- (void)addCustomTrackingArea;

@end

/**
 * @brief Triple-buffered uniform buffer for efficient CPU/GPU synchronization.
 */
@interface MklUniformBuffer : NSObject

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) id<MTLBuffer> buffer;
@property (nonatomic, readonly) NSUInteger bufferSize;
@property (nonatomic) NSUInteger currentIndex;

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device size:(NSUInteger)size;
- (void *)currentBufferPointer;
- (NSUInteger)currentBufferOffset;
- (void)advanceFrame;

@end

/**
 * @brief Efficient buffer pool with reusable buffers.
 */
@interface MklBufferPool : NSObject

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<MTLBuffer>> *> *bufferPools;
@property (nonatomic, strong) NSMutableArray<id<MTLBuffer>> *usedBuffers;
@property (nonatomic) NSUInteger frameCount;

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device;
- (id<MTLBuffer>)getBufferWithBytes:(const void *)bytes length:(NSUInteger)length;
- (id<MTLBuffer>)getReuseableBufferWithLength:(NSUInteger)length;
- (void)resetFrame;

@end
#endif

typedef struct MKLRenderer
{
    MKLWindow *window;
    MKLUniforms uniforms;
    MKLCamera camera;
    
    // Render state caching
    bool _cullingEnabled;
    bool _depthTestEnabled;
#ifdef __OBJC__
    // Device and command queue
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    
    // View and layer
    MTKView *_view;
    CAMetalLayer *_metalLayer;
    MTLClearColor _clearColor;
    
    // Buffer management
    MklBufferPool *_bufferPool;
    MklUniformBuffer *_uniformBuffer;
    MTKMeshBufferAllocator *_bufferAllocator;
    
    // Pipeline state objects
    id<MTLLibrary> _library;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    MTLVertexDescriptor *_vertexDescriptor;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLRenderPipelineState> _instancedPipelineState; // For instanced rendering
    id<MTLDepthStencilState> _depthStencilState;
    
    // Depth texture for depth testing
    id<MTLTexture> _depthTexture;
    
    // Triple buffering synchronization
    dispatch_semaphore_t _inFlightSemaphore;
    NSUInteger _currentBufferIndex;
    
    // Custom shader support
    void *_customShader; // MKLShader* (forward declaration to avoid circular dependency)
    
    // Per-frame drawing state
    id<CAMetalDrawable> _drawable;
    id<MTLCommandBuffer> _commandBuffer;
    id<MTLRenderCommandEncoder> _renderEncoder;
#endif
} MKLRenderer;

MKLAPI MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKLAPI void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKLAPI void MKLBeginDrawing(MKLRenderer *renderer);

MKLAPI void MKLEndDrawing(MKLRenderer *renderer);

MKLAPI void MKLDestroyRenderer(MKLRenderer *renderer);

// ========== Renderer Query Functions ==========
MKLAPI int MKLGetRenderWidth(MKLRenderer *renderer);
MKLAPI int MKLGetRenderHeight(MKLRenderer *renderer);
MKLAPI vector_float2 MKLGetRenderSize(MKLRenderer *renderer);

#endif // _MKL_VIEW_H_
