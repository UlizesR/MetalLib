//
// MKLMetal3.m
// MetalLib - Metal 3 Features (Consolidated Implementation)
//
// All Metal 3 optimizations and advanced features:
// - GPU capability detection
// - Memoryless depth buffers
// - Fast resource loading (MTLIOCommandQueue)
// - Argument buffers
// - Indirect command buffers
// - Mesh shaders
// - Sparse textures
// - Display link
// - Texture storage optimization
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import "MKLMetal3.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdatomic.h>

// ============================================================================
// MARK: - GPU Capability Detection
// ============================================================================

MKLGPUCapabilities MKLDetectGPUCapabilities(id<MTLDevice> device) {
    MKLGPUCapabilities caps = {0};

    if (!device) {
        return caps;
    }

    caps.deviceName = [device.name UTF8String];

    // Detect platform
    #if TARGET_OS_IOS
    caps.isiOS = true;
    caps.isMac = false;
    #elif TARGET_OS_OSX
    caps.isiOS = false;
    caps.isMac = true;
    #endif

    // Detect GPU family (newest to oldest)
    if ([device supportsFamily:MTLGPUFamilyApple9]) {
        caps.primaryFamily = MTLGPUFamilyApple9;
        caps.familyName = "Apple9 (A17/M3)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyApple8]) {
        caps.primaryFamily = MTLGPUFamilyApple8;
        caps.familyName = "Apple8 (A16/M2)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyApple7]) {
        caps.primaryFamily = MTLGPUFamilyApple7;
        caps.familyName = "Apple7 (A15/M1)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyApple6]) {
        caps.primaryFamily = MTLGPUFamilyApple6;
        caps.familyName = "Apple6 (A14)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyApple5]) {
        caps.primaryFamily = MTLGPUFamilyApple5;
        caps.familyName = "Apple5 (A13)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyMac2]) {
        caps.primaryFamily = MTLGPUFamilyMac2;
        caps.familyName = "Mac2 (Apple Silicon)";
        caps.isAppleSilicon = true;
    } else if ([device supportsFamily:MTLGPUFamilyApple4]) {
        caps.primaryFamily = MTLGPUFamilyApple4;
        caps.familyName = "Apple4 (A12)";
        caps.isAppleSilicon = false;
    } else if ([device supportsFamily:MTLGPUFamilyApple3]) {
        caps.primaryFamily = MTLGPUFamilyApple3;
        caps.familyName = "Apple3 (A11)";
        caps.isAppleSilicon = false;
    } else if ([device supportsFamily:MTLGPUFamilyApple2]) {
        caps.primaryFamily = MTLGPUFamilyApple2;
        caps.familyName = "Apple2 (A10)";
        caps.isAppleSilicon = false;
    } else if ([device supportsFamily:MTLGPUFamilyApple1]) {
        caps.primaryFamily = MTLGPUFamilyApple1;
        caps.familyName = "Apple1 (A7-A9)";
        caps.isAppleSilicon = false;
    } else {
        caps.primaryFamily = MTLGPUFamilyCommon1;
        caps.familyName = "Common1";
        caps.isAppleSilicon = false;
    }

    // Feature detection
    caps.supportsMemorylessTargets = [device supportsFamily:MTLGPUFamilyApple1];
    caps.supportsFastResourceLoading = [device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2];
    caps.supportsMeshShaders = [device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2];
    caps.supportsRaytracing = [device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2];
    caps.supportsNonuniformThreadgroups = [device supportsFamily:MTLGPUFamilyApple6] || [device supportsFamily:MTLGPUFamilyMac2];
    caps.supportsReadWriteTextures = [device supportsFamily:MTLGPUFamilyApple3];
    caps.supportsTileShaders = [device supportsFamily:MTLGPUFamilyApple4];

    return caps;
}

void MKLPrintGPUCapabilities(const MKLGPUCapabilities *caps) {
    printf("\n═══════════════════════════════════════════════════════════════\n");
    printf("                     GPU CAPABILITIES                          \n");
    printf("═══════════════════════════════════════════════════════════════\n");
    printf("Device: %s\n", caps->deviceName ? caps->deviceName : "Unknown");
    printf("GPU Family: %s\n", caps->familyName ? caps->familyName : "Unknown");
    printf("Platform: %s\n", caps->isiOS ? "iOS" : (caps->isMac ? "macOS" : "Unknown"));
    printf("Apple Silicon: %s\n", caps->isAppleSilicon ? "Yes" : "No");
    printf("\n--- Storage Optimizations ---\n");
    printf("Memoryless Targets: %s\n", caps->supportsMemorylessTargets ? "✅ YES" : "❌ NO");
    printf("\n--- Metal 3 Features ---\n");
    printf("Fast Resource Loading: %s\n", caps->supportsFastResourceLoading ? "✅ YES" : "❌ NO");
    printf("Mesh Shaders: %s\n", caps->supportsMeshShaders ? "✅ YES" : "❌ NO");
    printf("Raytracing: %s\n", caps->supportsRaytracing ? "✅ YES" : "❌ NO");
    printf("\n--- Advanced Features ---\n");
    printf("Non-uniform Threadgroups: %s\n", caps->supportsNonuniformThreadgroups ? "✅ YES" : "❌ NO");
    printf("Read-Write Textures: %s\n", caps->supportsReadWriteTextures ? "✅ YES" : "❌ NO");
    printf("Tile Shaders: %s\n", caps->supportsTileShaders ? "✅ YES" : "❌ NO");
    printf("═══════════════════════════════════════════════════════════════\n\n");
}

MTLStorageMode MKLGetOptimalDepthStorageMode(const MKLGPUCapabilities *caps) {
    return caps->supportsMemorylessTargets ? MTLStorageModeMemoryless : MTLStorageModePrivate;
}

MTLStorageMode MKLGetOptimalMSAAStorageMode(const MKLGPUCapabilities *caps) {
    return caps->supportsMemorylessTargets ? MTLStorageModeMemoryless : MTLStorageModePrivate;
}

// ============================================================================
// MARK: - Texture Storage Optimization
// ============================================================================

MTLStorageMode MKLGetOptimalTextureStorageMode(MKLTextureUsage usage, bool isAppleGPU __attribute__((unused))) {
    switch (usage) {
        case MKL_TEXTURE_GPU_ONLY:
        case MKL_TEXTURE_RENDER_TARGET:
            return MTLStorageModePrivate;
        case MKL_TEXTURE_CPU_READ:
        case MKL_TEXTURE_CPU_WRITE:
        case MKL_TEXTURE_CPU_READ_WRITE:
            return MTLStorageModeShared;
        default:
            return MTLStorageModePrivate;
    }
}

MTLTextureUsage MKLGetOptimalTextureUsageFlags(MKLTextureUsage usage, bool isRenderTarget) {
    MTLTextureUsage flags = MTLTextureUsageShaderRead;
    if (isRenderTarget || usage == MKL_TEXTURE_RENDER_TARGET) {
        flags |= MTLTextureUsageRenderTarget;
    }
    if (usage == MKL_TEXTURE_CPU_WRITE || usage == MKL_TEXTURE_CPU_READ_WRITE) {
        flags |= MTLTextureUsageShaderWrite;
    }
    return flags;
}

// ============================================================================
// MARK: - Fast Resource Loading (Metal 3)
// ============================================================================

typedef struct LoadOperation {
    MKLResourceLoadCallback callback;
    void *userData;
    size_t byteSize;
} LoadOperation;

struct MKLFastResourceLoader {
    id<MTLDevice> device;
    id<MTLIOCommandQueue> ioQueue;
    dispatch_queue_t callbackQueue;
    _Atomic size_t pendingCount;
    _Atomic size_t totalLoadsQueued;
    _Atomic size_t totalLoadsCompleted;
    _Atomic size_t totalLoadsFailed;
    _Atomic size_t totalBytesLoaded;
    bool isSupported;
};

MKLFastResourceLoader *MKLCreateFastResourceLoader(id<MTLDevice> device) {
    if (!device) {
        return NULL;
    }

    MKLGPUCapabilities caps = MKLDetectGPUCapabilities(device);
    if (!caps.supportsFastResourceLoading) {
        return NULL;
    }

    MKLFastResourceLoader *loader = (MKLFastResourceLoader *)calloc(1, sizeof(MKLFastResourceLoader));
    if (!loader) {
        return NULL;
    }

    loader->device = device;
    loader->callbackQueue = dispatch_queue_create("com.metallib.fastresourceloading", DISPATCH_QUEUE_SERIAL);

    if (@available(macOS 13.0, iOS 16.0, *)) {
        MTLIOCommandQueueDescriptor *desc = [MTLIOCommandQueueDescriptor new];
        desc.type = MTLIOCommandQueueTypeConcurrent;
        desc.priority = MTLIOPriorityNormal;
        desc.maxCommandBufferCount = 64;

        NSError *error = nil;
        loader->ioQueue = [device newIOCommandQueueWithDescriptor:desc error:&error];

        if (!loader->ioQueue || error) {
            free(loader);
            return NULL;
        }

        loader->isSupported = true;
        printf("✓ Metal 3 Fast Resource Loading initialized\n");
    } else {
        free(loader);
        return NULL;
    }

    return loader;
}

bool MKLIsFastResourceLoadingSupported(const MKLFastResourceLoader *loader) {
    return loader && loader->isSupported;
}

void MKLDestroyFastResourceLoader(MKLFastResourceLoader *loader) {
    if (!loader) return;
    MKLWaitForLoadsToComplete(loader);
    loader->ioQueue = nil;
    loader->device = nil;
    loader->callbackQueue = nil;
    free(loader);
}

bool MKLLoadBufferFromFileAsync(MKLFastResourceLoader *loader,
                                 const char *filePath,
                                 id<MTLBuffer> buffer,
                                 MKLResourceLoadPriority priority __attribute__((unused)),
                                 MKLResourceLoadCallback callback,
                                 void *userData) {
    if (!loader || !loader->isSupported || !filePath || !buffer) {
        if (callback) callback(userData, false, "Invalid parameters");
        return false;
    }

    NSURL *fileURL = [NSURL fileURLWithPath:@(filePath)];
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&error];

    if (error || !attributes || buffer.length < [attributes fileSize]) {
        if (callback) callback(userData, false, "File error");
        return false;
    }

    if (@available(macOS 13.0, iOS 16.0, *)) {
        id<MTLIOFileHandle> fileHandle = [loader->device newIOFileHandleWithURL:fileURL error:&error];
        if (!fileHandle) {
            if (callback) callback(userData, false, "Failed to open file");
            loader->totalLoadsFailed++;
            return false;
        }

        id<MTLIOCommandBuffer> ioCommandBuffer = [loader->ioQueue commandBuffer];
        [ioCommandBuffer loadBuffer:buffer offset:0 size:(size_t)[attributes fileSize]
                       sourceHandle:fileHandle sourceHandleOffset:0];

        loader->pendingCount++;
        loader->totalLoadsQueued++;

        __block MKLFastResourceLoader *blockLoader = loader;
        __block MKLResourceLoadCallback blockCallback = callback;
        __block void *blockUserData = userData;
        __block size_t blockSize = (size_t)[attributes fileSize];

        [ioCommandBuffer addCompletedHandler:^(id<MTLIOCommandBuffer> cb) {
            blockLoader->pendingCount--;
            if (cb.error) {
                blockLoader->totalLoadsFailed++;
                if (blockCallback) {
                    dispatch_async(blockLoader->callbackQueue, ^{
                        blockCallback(blockUserData, false, [[cb.error localizedDescription] UTF8String]);
                    });
                }
            } else {
                blockLoader->totalLoadsCompleted++;
                blockLoader->totalBytesLoaded += blockSize;
                if (blockCallback) {
                    dispatch_async(blockLoader->callbackQueue, ^{
                        blockCallback(blockUserData, true, NULL);
                    });
                }
            }
        }];

        [ioCommandBuffer commit];
        return true;
    }

    if (callback) callback(userData, false, "Metal 3 not available");
    return false;
}

void MKLWaitForLoadsToComplete(MKLFastResourceLoader *loader) {
    if (!loader) return;
    while (loader->pendingCount > 0) {
        usleep(1000);
    }
}

size_t MKLGetPendingLoadCount(const MKLFastResourceLoader *loader) {
    return loader ? atomic_load(&loader->pendingCount) : 0;
}

MKLResourceLoadStats MKLGetResourceLoadStats(const MKLFastResourceLoader *loader) {
    MKLResourceLoadStats stats = {0};
    if (loader) {
        stats.totalLoadsQueued = loader->totalLoadsQueued;
        stats.totalLoadsCompleted = loader->totalLoadsCompleted;
        stats.totalLoadsFailed = loader->totalLoadsFailed;
        stats.totalBytesLoaded = loader->totalBytesLoaded;
        stats.currentPendingLoads = loader->pendingCount;
    }
    return stats;
}

// ============================================================================
// MARK: - Argument Buffers
// ============================================================================

struct MKLArgumentBuffer {
    id<MTLDevice> device;
    id<MTLBuffer> argumentBuffer;
    id<MTLArgumentEncoder> argumentEncoder;
    NSUInteger bufferIndex;
};

MKLArgumentBuffer *MKLCreateArgumentBuffer(id<MTLDevice> device,
                                           id<MTLFunction> function,
                                           NSUInteger bufferIndex) {
    if (!device || !function) return NULL;

    MKLArgumentBuffer *argBuffer = (MKLArgumentBuffer *)calloc(1, sizeof(MKLArgumentBuffer));
    if (!argBuffer) return NULL;

    argBuffer->device = device;
    argBuffer->bufferIndex = bufferIndex;
    argBuffer->argumentEncoder = [function newArgumentEncoderWithBufferIndex:bufferIndex];

    if (!argBuffer->argumentEncoder) {
        free(argBuffer);
        return NULL;
    }

    NSUInteger encodedLength = argBuffer->argumentEncoder.encodedLength;
    argBuffer->argumentBuffer = [device newBufferWithLength:encodedLength
                                                    options:MTLResourceStorageModeShared];

    if (!argBuffer->argumentBuffer) {
        free(argBuffer);
        return NULL;
    }

    [argBuffer->argumentEncoder setArgumentBuffer:argBuffer->argumentBuffer offset:0];
    return argBuffer;
}

void MKLSetArgumentBufferTexture(MKLArgumentBuffer *argBuffer, id<MTLTexture> texture, NSUInteger index) {
    if (argBuffer && argBuffer->argumentEncoder) {
        [argBuffer->argumentEncoder setTexture:texture atIndex:index];
    }
}

void MKLSetArgumentBufferBuffer(MKLArgumentBuffer *argBuffer, id<MTLBuffer> buffer, NSUInteger offset, NSUInteger index) {
    if (argBuffer && argBuffer->argumentEncoder) {
        [argBuffer->argumentEncoder setBuffer:buffer offset:offset atIndex:index];
    }
}

void MKLSetArgumentBufferSampler(MKLArgumentBuffer *argBuffer, id<MTLSamplerState> sampler, NSUInteger index) {
    if (argBuffer && argBuffer->argumentEncoder) {
        [argBuffer->argumentEncoder setSamplerState:sampler atIndex:index];
    }
}

void MKLEncodeArgumentBuffer(MKLArgumentBuffer *argBuffer, id<MTLRenderCommandEncoder> encoder, NSUInteger bufferIndex) {
    if (!argBuffer || !encoder) return;

    [encoder setFragmentBuffer:argBuffer->argumentBuffer offset:0 atIndex:bufferIndex];

    if (@available(macOS 13.0, iOS 16.0, *)) {
        [encoder useResource:argBuffer->argumentBuffer usage:MTLResourceUsageRead stages:MTLRenderStageFragment];
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [encoder useResource:argBuffer->argumentBuffer usage:MTLResourceUsageRead];
        #pragma clang diagnostic pop
    }
}

void MKLDestroyArgumentBuffer(MKLArgumentBuffer *argBuffer) {
    if (!argBuffer) return;
    argBuffer->argumentBuffer = nil;
    argBuffer->argumentEncoder = nil;
    argBuffer->device = nil;
    free(argBuffer);
}

// ============================================================================
// MARK: - Indirect Command Buffers
// ============================================================================

struct MKLIndirectCommandBuffer {
    id<MTLDevice> device;
    id<MTLIndirectCommandBuffer> commandBuffer;
    NSUInteger maxCommandCount;
};

MKLIndirectCommandBuffer *MKLCreateIndirectCommandBuffer(id<MTLDevice> device,
                                                          NSUInteger maxCommandCount,
                                                          MKLIndirectCommandType commandTypes) {
    if (!device || !MKLIsIndirectCommandBufferSupported(device)) {
        return NULL;
    }

    MKLIndirectCommandBuffer *icb = (MKLIndirectCommandBuffer *)calloc(1, sizeof(MKLIndirectCommandBuffer));
    if (!icb) return NULL;

    icb->device = device;
    icb->maxCommandCount = maxCommandCount;

    MTLIndirectCommandBufferDescriptor *desc = [[MTLIndirectCommandBufferDescriptor alloc] init];
    if (commandTypes & MKL_INDIRECT_DRAW) {
        desc.commandTypes = MTLIndirectCommandTypeDraw;
    }
    if (commandTypes & MKL_INDIRECT_DRAW_INDEXED) {
        desc.commandTypes = MTLIndirectCommandTypeDrawIndexed;
    }
    desc.inheritBuffers = NO;
    desc.inheritPipelineState = NO;
    desc.maxVertexBufferBindCount = 25;
    desc.maxFragmentBufferBindCount = 25;

    icb->commandBuffer = [device newIndirectCommandBufferWithDescriptor:desc
                                                         maxCommandCount:maxCommandCount
                                                                 options:0];

    if (!icb->commandBuffer) {
        free(icb);
        return NULL;
    }

    return icb;
}

bool MKLIsIndirectCommandBufferSupported(id<MTLDevice> device) {
    return device && ([device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2]);
}

void MKLEncodeIndirectCommandBuffer(MKLIndirectCommandBuffer *icb, id<MTLRenderCommandEncoder> encoder, NSRange range) {
    if (icb && icb->commandBuffer && encoder) {
        [encoder executeCommandsInBuffer:icb->commandBuffer withRange:range];
    }
}

id<MTLIndirectRenderCommand> MKLGetIndirectRenderCommand(MKLIndirectCommandBuffer *icb, NSUInteger index) {
    if (icb && icb->commandBuffer && index < icb->maxCommandCount) {
        return [icb->commandBuffer indirectRenderCommandAtIndex:index];
    }
    return nil;
}

void MKLDestroyIndirectCommandBuffer(MKLIndirectCommandBuffer *icb) {
    if (!icb) return;
    icb->commandBuffer = nil;
    icb->device = nil;
    free(icb);
}

// ============================================================================
// MARK: - Mesh Shaders (Metal 3)
// ============================================================================

struct MKLMeshShaderPipeline {
    id<MTLDevice> device;
    id<MTLRenderPipelineState> pipelineState;
};

MKLMeshShaderPipeline *MKLCreateMeshShaderPipeline(id<MTLDevice> device,
                                                    id<MTLLibrary> library,
                                                    const char *objectFunctionName,
                                                    const char *meshFunctionName,
                                                    const char *fragmentFunctionName,
                                                    MTLPixelFormat colorFormat,
                                                    MTLPixelFormat depthFormat) {
    if (!device || !library || !MKLIsMeshShaderSupported(device)) {
        return NULL;
    }

    if (@available(macOS 13.0, iOS 16.0, *)) {
        MKLMeshShaderPipeline *pipeline = (MKLMeshShaderPipeline *)calloc(1, sizeof(MKLMeshShaderPipeline));
        if (!pipeline) return NULL;

        pipeline->device = device;

        id<MTLFunction> objectFunc = objectFunctionName ? [library newFunctionWithName:@(objectFunctionName)] : nil;
        id<MTLFunction> meshFunc = meshFunctionName ? [library newFunctionWithName:@(meshFunctionName)] : nil;
        id<MTLFunction> fragFunc = fragmentFunctionName ? [library newFunctionWithName:@(fragmentFunctionName)] : nil;

        if (!meshFunc) {
            free(pipeline);
            return NULL;
        }

        MTLMeshRenderPipelineDescriptor *descriptor = [[MTLMeshRenderPipelineDescriptor alloc] init];
        descriptor.objectFunction = objectFunc;
        descriptor.meshFunction = meshFunc;
        descriptor.fragmentFunction = fragFunc;
        descriptor.colorAttachments[0].pixelFormat = colorFormat;
        descriptor.depthAttachmentPixelFormat = depthFormat;
        descriptor.rasterSampleCount = 1;

        NSError *error = nil;
        pipeline->pipelineState = [device newRenderPipelineStateWithMeshDescriptor:descriptor
                                                                            options:MTLPipelineOptionNone
                                                                         reflection:nil
                                                                              error:&error];

        if (!pipeline->pipelineState) {
            free(pipeline);
            return NULL;
        }

        return pipeline;
    }

    return NULL;
}

bool MKLIsMeshShaderSupported(id<MTLDevice> device) {
    return device && ([device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2]);
}

void MKLEncodeMeshShaderDraw(MKLMeshShaderPipeline *pipeline,
                              id<MTLRenderCommandEncoder> encoder,
                              NSUInteger threadgroupsPerGrid,
                              NSUInteger threadsPerObjectThreadgroup,
                              NSUInteger threadsPerMeshThreadgroup) {
    if (!pipeline || !encoder) return;

    if (@available(macOS 13.0, iOS 16.0, *)) {
        [encoder setRenderPipelineState:pipeline->pipelineState];
        [encoder drawMeshThreadgroups:MTLSizeMake(threadgroupsPerGrid, 1, 1)
                 threadsPerObjectThreadgroup:MTLSizeMake(threadsPerObjectThreadgroup, 1, 1)
                   threadsPerMeshThreadgroup:MTLSizeMake(threadsPerMeshThreadgroup, 1, 1)];
    }
}

void MKLDestroyMeshShaderPipeline(MKLMeshShaderPipeline *pipeline) {
    if (!pipeline) return;
    pipeline->pipelineState = nil;
    pipeline->device = nil;
    free(pipeline);
}

// ============================================================================
// MARK: - Sparse Textures
// ============================================================================

struct MKLSparseTexture {
    id<MTLDevice> device;
    id<MTLTexture> texture;
    id<MTLHeap> tileHeap;
    MTLSize tileSize;
};

MKLSparseTexture *MKLCreateSparseTexture(id<MTLDevice> device, MTLTextureDescriptor *descriptor) {
    if (!device || !descriptor || !MKLIsSparseTextureSupported(device)) {
        return NULL;
    }

    MKLSparseTexture *sparseTexture = (MKLSparseTexture *)calloc(1, sizeof(MKLSparseTexture));
    if (!sparseTexture) return NULL;

    sparseTexture->device = device;
    descriptor.storageMode = MTLStorageModePrivate;
    descriptor.usage |= MTLTextureUsageShaderRead;

    sparseTexture->texture = [device newTextureWithDescriptor:descriptor];
    if (!sparseTexture->texture) {
        free(sparseTexture);
        return NULL;
    }

    sparseTexture->tileSize = MTLSizeMake(256, 256, 1);
    return sparseTexture;
}

bool MKLIsSparseTextureSupported(id<MTLDevice> device) {
    return device && ([device supportsFamily:MTLGPUFamilyApple7] || [device supportsFamily:MTLGPUFamilyMac2]);
}

id<MTLTexture> MKLGetSparseTextureHandle(MKLSparseTexture *sparseTexture) {
    return sparseTexture ? sparseTexture->texture : nil;
}

void MKLDestroySparseTexture(MKLSparseTexture *sparseTexture) {
    if (!sparseTexture) return;
    sparseTexture->texture = nil;
    sparseTexture->tileHeap = nil;
    sparseTexture->device = nil;
    free(sparseTexture);
}

// ============================================================================
// MARK: - Display Link (Metal 3)
// ============================================================================

@interface MKLDisplayLinkDelegate : NSObject <CAMetalDisplayLinkDelegate>
@property (nonatomic, assign) MKLDisplayLinkCallback callback;
@property (nonatomic, assign) void *userData;
@end

@implementation MKLDisplayLinkDelegate
- (void)metalDisplayLink:(CAMetalDisplayLink *)link needsUpdate:(CAMetalDisplayLinkUpdate *)update {
    if (self.callback) {
        self.callback(self.userData, CACurrentMediaTime(), update.targetTimestamp);
    }
}
@end

struct MKLDisplayLink {
    CAMetalDisplayLink *displayLink;
    MKLDisplayLinkDelegate *delegate;
    bool isPaused;
};

MKLDisplayLink *MKLCreateDisplayLink(CAMetalLayer *layer, MKLDisplayLinkCallback callback, void *userData) {
    if (!layer || !callback || !MKLIsDisplayLinkSupported()) {
        return NULL;
    }

    if (@available(macOS 14.0, iOS 17.0, *)) {
        MKLDisplayLink *displayLink = (MKLDisplayLink *)calloc(1, sizeof(MKLDisplayLink));
        if (!displayLink) return NULL;

        displayLink->delegate = [[MKLDisplayLinkDelegate alloc] init];
        displayLink->delegate.callback = callback;
        displayLink->delegate.userData = userData;
        displayLink->displayLink = [[CAMetalDisplayLink alloc] initWithMetalLayer:layer];

        if (!displayLink->displayLink) {
            free(displayLink);
            return NULL;
        }

        [displayLink->displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        displayLink->displayLink.delegate = displayLink->delegate;
        displayLink->isPaused = true;

        return displayLink;
    }

    return NULL;
}

bool MKLIsDisplayLinkSupported(void) {
    if (@available(macOS 14.0, iOS 17.0, *)) {
        return true;
    }
    return false;
}

void MKLStartDisplayLink(MKLDisplayLink *displayLink) {
    if (displayLink && displayLink->displayLink) {
        if (@available(macOS 14.0, iOS 17.0, *)) {
            displayLink->displayLink.paused = NO;
            displayLink->isPaused = false;
        }
    }
}

void MKLStopDisplayLink(MKLDisplayLink *displayLink) {
    if (displayLink && displayLink->displayLink) {
        if (@available(macOS 14.0, iOS 17.0, *)) {
            displayLink->displayLink.paused = YES;
            displayLink->isPaused = true;
        }
    }
}

void MKLDestroyDisplayLink(MKLDisplayLink *displayLink) {
    if (!displayLink) return;
    if (displayLink->displayLink) {
        [displayLink->displayLink invalidate];
        displayLink->displayLink = nil;
    }
    displayLink->delegate = nil;
    free(displayLink);
}
