//
// MKLMetal3.h
// MetalLib - Metal 3 Features (Consolidated)
//
// All Metal 3 optimizations and features in one place
//

#ifndef MKLMetal3_h
#define MKLMetal3_h

#include <stdbool.h>
#include "../Core/MKLCore.h"

#ifdef __OBJC__
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// GPU Capabilities
// ============================================================================

typedef struct MKLGPUCapabilities {
    // Storage modes
    bool supportsMemorylessTargets;
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
MKLAPI MKLGPUCapabilities MKLDetectGPUCapabilities(id<MTLDevice> device);
MKLAPI MTLStorageMode MKLGetOptimalDepthStorageMode(const MKLGPUCapabilities *caps);
MKLAPI MTLStorageMode MKLGetOptimalMSAAStorageMode(const MKLGPUCapabilities *caps);
#endif

MKLAPI void MKLPrintGPUCapabilities(const MKLGPUCapabilities *caps);

// ============================================================================
// Texture Optimization
// ============================================================================

typedef enum MKLTextureUsage {
    MKL_TEXTURE_GPU_ONLY = 0,
    MKL_TEXTURE_CPU_READ = 1,
    MKL_TEXTURE_CPU_WRITE = 2,
    MKL_TEXTURE_CPU_READ_WRITE = 3,
    MKL_TEXTURE_RENDER_TARGET = 4,
} MKLTextureUsage;

#ifdef __OBJC__
MKLAPI MTLStorageMode MKLGetOptimalTextureStorageMode(MKLTextureUsage usage, bool isAppleGPU);
MKLAPI MTLTextureUsage MKLGetOptimalTextureUsageFlags(MKLTextureUsage usage, bool isRenderTarget);
#endif

// ============================================================================
// Fast Resource Loading
// ============================================================================

typedef struct MKLFastResourceLoader MKLFastResourceLoader;

typedef enum MKLResourceLoadPriority {
    MKL_RESOURCE_PRIORITY_LOW = 0,
    MKL_RESOURCE_PRIORITY_NORMAL = 1,
    MKL_RESOURCE_PRIORITY_HIGH = 2,
} MKLResourceLoadPriority;

typedef void (*MKLResourceLoadCallback)(void *userData, bool success, const char *errorMessage);

typedef struct MKLResourceLoadStats {
    size_t totalLoadsQueued;
    size_t totalLoadsCompleted;
    size_t totalLoadsFailed;
    size_t totalBytesLoaded;
    size_t currentPendingLoads;
} MKLResourceLoadStats;

#ifdef __OBJC__
MKLAPI MKLFastResourceLoader *MKLCreateFastResourceLoader(id<MTLDevice> device);
MKLAPI bool MKLLoadBufferFromFileAsync(MKLFastResourceLoader *loader,
                                        const char *filePath,
                                        id<MTLBuffer> buffer,
                                        MKLResourceLoadPriority priority,
                                        MKLResourceLoadCallback callback,
                                        void *userData);
#endif

MKLAPI bool MKLIsFastResourceLoadingSupported(const MKLFastResourceLoader *loader);
MKLAPI void MKLWaitForLoadsToComplete(MKLFastResourceLoader *loader);
MKLAPI size_t MKLGetPendingLoadCount(const MKLFastResourceLoader *loader);
MKLAPI MKLResourceLoadStats MKLGetResourceLoadStats(const MKLFastResourceLoader *loader);
MKLAPI void MKLDestroyFastResourceLoader(MKLFastResourceLoader *loader);

// ============================================================================
// Argument Buffers
// ============================================================================

typedef struct MKLArgumentBuffer MKLArgumentBuffer;

#ifdef __OBJC__
MKLAPI MKLArgumentBuffer *MKLCreateArgumentBuffer(id<MTLDevice> device,
                                                   id<MTLFunction> function,
                                                   NSUInteger bufferIndex);
MKLAPI void MKLSetArgumentBufferTexture(MKLArgumentBuffer *argBuffer,
                                        id<MTLTexture> texture,
                                        NSUInteger index);
MKLAPI void MKLEncodeArgumentBuffer(MKLArgumentBuffer *argBuffer,
                                    id<MTLRenderCommandEncoder> encoder,
                                    NSUInteger bufferIndex);
#endif

MKLAPI void MKLDestroyArgumentBuffer(MKLArgumentBuffer *argBuffer);

// ============================================================================
// Indirect Command Buffers
// ============================================================================

typedef struct MKLIndirectCommandBuffer MKLIndirectCommandBuffer;

typedef enum MKLIndirectCommandType {
    MKL_INDIRECT_DRAW = 1 << 0,
    MKL_INDIRECT_DRAW_INDEXED = 1 << 1,
    MKL_INDIRECT_CONCURRENT = 1 << 2,
} MKLIndirectCommandType;

#ifdef __OBJC__
MKLAPI MKLIndirectCommandBuffer *MKLCreateIndirectCommandBuffer(id<MTLDevice> device,
                                                                 NSUInteger maxCommandCount,
                                                                 MKLIndirectCommandType commandTypes);
MKLAPI bool MKLIsIndirectCommandBufferSupported(id<MTLDevice> device);
MKLAPI void MKLEncodeIndirectCommandBuffer(MKLIndirectCommandBuffer *icb,
                                           id<MTLRenderCommandEncoder> encoder,
                                           NSRange range);
MKLAPI id<MTLIndirectRenderCommand> MKLGetIndirectRenderCommand(MKLIndirectCommandBuffer *icb,
                                                                 NSUInteger index);
#endif

MKLAPI void MKLDestroyIndirectCommandBuffer(MKLIndirectCommandBuffer *icb);

// ============================================================================
// Mesh Shaders
// ============================================================================

typedef struct MKLMeshShaderPipeline MKLMeshShaderPipeline;

#ifdef __OBJC__
MKLAPI MKLMeshShaderPipeline *MKLCreateMeshShaderPipeline(id<MTLDevice> device,
                                                           id<MTLLibrary> library,
                                                           const char *objectFunctionName,
                                                           const char *meshFunctionName,
                                                           const char *fragmentFunctionName,
                                                           MTLPixelFormat colorFormat,
                                                           MTLPixelFormat depthFormat);
MKLAPI bool MKLIsMeshShaderSupported(id<MTLDevice> device);
MKLAPI void MKLEncodeMeshShaderDraw(MKLMeshShaderPipeline *pipeline,
                                    id<MTLRenderCommandEncoder> encoder,
                                    NSUInteger threadgroupsPerGrid,
                                    NSUInteger threadsPerObjectThreadgroup,
                                    NSUInteger threadsPerMeshThreadgroup);
#endif

MKLAPI void MKLDestroyMeshShaderPipeline(MKLMeshShaderPipeline *pipeline);

// ============================================================================
// Sparse Textures
// ============================================================================

typedef struct MKLSparseTexture MKLSparseTexture;

typedef struct MKLTileRegion {
    unsigned int x, y, z;
    unsigned int width, height, depth;
} MKLTileRegion;

#ifdef __OBJC__
MKLAPI MKLSparseTexture *MKLCreateSparseTexture(id<MTLDevice> device,
                                                 MTLTextureDescriptor *descriptor);
MKLAPI bool MKLIsSparseTextureSupported(id<MTLDevice> device);
MKLAPI id<MTLTexture> MKLGetSparseTextureHandle(MKLSparseTexture *sparseTexture);
#endif

MKLAPI void MKLDestroySparseTexture(MKLSparseTexture *sparseTexture);

// ============================================================================
// Display Link
// ============================================================================

typedef struct MKLDisplayLink MKLDisplayLink;

typedef void (*MKLDisplayLinkCallback)(void *userData, double timestamp, double targetTimestamp);

#ifdef __OBJC__
MKLAPI MKLDisplayLink *MKLCreateDisplayLink(CAMetalLayer *layer,
                                             MKLDisplayLinkCallback callback,
                                             void *userData);
MKLAPI void MKLStartDisplayLink(MKLDisplayLink *displayLink);
MKLAPI void MKLStopDisplayLink(MKLDisplayLink *displayLink);
#endif

MKLAPI bool MKLIsDisplayLinkSupported(void);
MKLAPI void MKLDestroyDisplayLink(MKLDisplayLink *displayLink);

#ifdef __cplusplus
}
#endif

#endif /* MKLMetal3_h */

