#ifndef _MKL_RENDERER_H_
#define _MKL_RENDERER_H_

#include <stdint.h>

#include "../MKLWindow.h"
#include "../Core/MKLCore.h"
#include "Objects/MKLEntity.h"

#include "MKLColors.h"
#include "MKLTypes.h"

// ============================================================================
// Metal 3 GPU Capabilities (core detection, consolidated from MKLMetal3)
// ============================================================================

typedef struct MKLGPUCapabilities {
    // Feature-table–aligned capabilities
    bool supportsMemorylessTargets;   // Apple2+ (Metal4) per feature tables
    unsigned maxMSAASamples;          // Mac2 = 4 per feature tables; Apple families may support 8
    bool supportsFastResourceLoading;
    bool supportsMeshShaders;
    bool supportsRaytracing;
    bool supportsNonuniformThreadgroups;
    bool supportsReadWriteTextures;
    bool supportsTileShaders;
    
    // GPU info
    int primaryFamily;
    const char *familyName;
    const char *deviceName;
    bool isAppleSilicon;
    bool isiOS;
    bool isMac;
} MKLGPUCapabilities;

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

    // GPU capabilities (C struct, works in both Obj-C and C)
    void *_gpuCapabilities; // MKLGPUCapabilities* (forward declaration)

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
    MTLVertexDescriptor *_vertexDescriptorEnhanced;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLRenderPipelineState> _instancedPipelineState; // For instanced rendering
    id<MTLRenderPipelineState> _pipelineStateEnhanced; // Enhanced pipeline with lighting
    id<MTLRenderPipelineState> _pipelineStateLit;      // Lighting only (no texture)
    id<MTLRenderPipelineState> _pipelineStateTextured; // Texture only (no lighting)
    id<MTLDepthStencilState> _depthStencilState;

    // Depth texture for depth testing
    id<MTLTexture> _depthTexture;

    // MSAA (Multi-Sample Anti-Aliasing) support
    id<MTLTexture> _msaaColorTexture;
    id<MTLTexture> _msaaDepthTexture;
    NSUInteger _msaaSampleCount;

    // Triple buffering synchronization
    dispatch_semaphore_t _inFlightSemaphore;
    NSUInteger _currentBufferIndex;

    // Custom shader support
    void *_customShader; // MKLShader* (forward declaration to avoid circular dependency)

    // Enhanced rendering support (lighting and textures)
    id<MTLBuffer> _lightBuffer;
    id<MTLBuffer> _lightingUniformsBuffer;
    id<MTLBuffer> _materialBuffer;
    bool _enhancedRenderingEnabled;
    id<MTLSamplerState> _defaultSampler;

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

// ========== Enhanced Rendering Control ==========
MKLAPI void MKLEnableEnhancedRendering(MKLRenderer *renderer, bool enable);
MKLAPI bool MKLIsEnhancedRenderingEnabled(MKLRenderer *renderer);

// ========== Metal 3 Features ==========

/**
 * @brief Get GPU capabilities for this renderer
 * @param renderer The renderer
 * @return Pointer to GPU capabilities (valid for renderer lifetime)
 */
MKLAPI const void *MKLGetGPUCapabilities(MKLRenderer *renderer);

/**
 * @brief Check if memoryless depth buffers are enabled
 * @param renderer The renderer
 * @return true if using memoryless storage (Apple Silicon optimization)
 */
MKLAPI bool MKLIsUsingMemorylessDepth(MKLRenderer *renderer);

/**
 * @brief Check if Metal 3 fast resource loading is available
 * @param renderer The renderer
 * @return true if fast loading is supported on this GPU
 */
MKLAPI bool MKLSupportsFastResourceLoading(MKLRenderer *renderer);

/**
 * @brief Check if mesh shaders are supported
 * @param renderer The renderer
 * @return true if mesh shaders are available
 */
MKLAPI bool MKLSupportsMeshShaders(MKLRenderer *renderer);

// ========== Performance Control ==========
/**
 * @brief Set the target frames per second (FPS) limit
 * @param renderer The renderer
 * @param fps Target FPS (0 = unlimited, bypasses VSync)
 *
 * Examples:
 *   MKLSetTargetFPS(renderer, 60);  // Cap at 60 FPS (default)
 *   MKLSetTargetFPS(renderer, 120); // Cap at 120 FPS
 *   MKLSetTargetFPS(renderer, 0);   // Unlimited FPS (for benchmarking)
 */
MKLAPI void MKLSetTargetFPS(MKLRenderer *renderer, int fps);

/**
 * @brief Get the current target FPS setting
 * @param renderer The renderer
 * @return Current FPS target (0 = unlimited)
 */
MKLAPI int MKLGetTargetFPS(MKLRenderer *renderer);

/**
 * @brief Set MSAA (Multi-Sample Anti-Aliasing) sample count
 * @param renderer The renderer
 * @param samples Sample count (1, 2, 4, or 8)
 *
 * Higher sample counts provide smoother edges but cost more GPU memory and performance:
 * - 1: No MSAA (fastest, sharp edges)
 * - 2: 2x MSAA (minimal cost, noticeable improvement)
 * - 4: 4x MSAA (recommended, excellent quality/performance balance)
 * - 8: 8x MSAA (best quality, significant cost)
 *
 * @note Must be called before first frame for proper initialization
 * @note Invalid sample counts will be clamped to nearest valid value
 */
MKLAPI void MKLSetMSAASamples(MKLRenderer *renderer, int samples);

/**
 * @brief Get current MSAA sample count
 * @param renderer The renderer
 * @return Current MSAA sample count (1, 2, 4, or 8)
 */
MKLAPI int MKLGetMSAASamples(MKLRenderer *renderer);

// Metal 3 GPU capability function (consolidated from MKLMetal3)
MKLAPI void MKLPrintGPUCapabilities(const MKLGPUCapabilities *caps);

#endif // _MKL_RENDERER_H_
