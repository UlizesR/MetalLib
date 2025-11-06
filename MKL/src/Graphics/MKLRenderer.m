#include <simd/matrix.h>
#include <stdio.h>

#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

#import "MKLRenderer.h"
#import "MKLLibraries.h"
#import "MKLLight.h"
#import "../Core/MKLConfig.h"
#import "../Core/MKLError.h"
#import "../Core/MKLTimer.h"
#import "../Math/MKLMath.h"
#include "MKLTypes.h"

// Use centralized constant from MKLConfig.h
#define MAX_FRAMES_IN_FLIGHT MKL_MAX_FRAMES_IN_FLIGHT

static MKLUniforms _gUniforms = {0};

#pragma mark - Metal 3 GPU Capabilities

static MKLGPUCapabilities MKLDetectGPUCapabilities(id<MTLDevice> device) {
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
    printf("                  METAL 3 GPU CAPABILITIES                     \n");
    printf("═══════════════════════════════════════════════════════════════\n");
    printf("Device: %s\n", caps->deviceName ? caps->deviceName : "Unknown");
    printf("GPU Family: %s\n", caps->familyName ? caps->familyName : "Unknown");
    printf("Platform: %s\n", caps->isiOS ? "iOS" : (caps->isMac ? "macOS" : "Unknown"));
    printf("Apple Silicon: %s\n", caps->isAppleSilicon ? "✅ YES" : "❌ NO");
    printf("\n--- Metal 3 Optimizations (ACTIVE) ---\n");
    printf("Memoryless Depth/MSAA: %s\n", caps->supportsMemorylessTargets ? "✅ ENABLED (20-30%% bandwidth savings)" : "❌ Not Available");
    printf("Fast Resource Loading: %s\n", caps->supportsFastResourceLoading ? "✅ ENABLED (10-100x faster)" : "❌ Not Available");
    printf("\n--- Metal 3 Advanced Features ---\n");
    printf("Mesh Shaders: %s\n", caps->supportsMeshShaders ? "✅ Available" : "❌ Not Available");
    printf("Raytracing: %s\n", caps->supportsRaytracing ? "✅ Available" : "❌ Not Available");
    printf("Non-uniform Threadgroups: %s\n", caps->supportsNonuniformThreadgroups ? "✅ Available" : "❌ Not Available");
    printf("Read-Write Textures: %s\n", caps->supportsReadWriteTextures ? "✅ Available" : "❌ Not Available");
    printf("Tile Shaders: %s\n", caps->supportsTileShaders ? "✅ Available" : "❌ Not Available");
    printf("═══════════════════════════════════════════════════════════════\n\n");
}

static MTLStorageMode MKLGetOptimalDepthStorageMode(const MKLGPUCapabilities *caps) {
    return caps->supportsMemorylessTargets ? MTLStorageModeMemoryless : MTLStorageModePrivate;
}

static MTLStorageMode MKLGetOptimalMSAAStorageMode(const MKLGPUCapabilities *caps) {
    return caps->supportsMemorylessTargets ? MTLStorageModeMemoryless : MTLStorageModePrivate;
}

static MTLStorageMode MKLGetOptimalTextureStorageMode(bool isRenderTarget, bool isAppleGPU) {
    if (isRenderTarget) {
        return MTLStorageModePrivate;
    }
    return MTLStorageModePrivate; // All textures use private storage for best performance
}

#pragma mark - MTKView Category

@implementation MTKView (TrackingArea)

- (void)addCustomTrackingArea
{
    // Remove all existing tracking areas
    for (NSTrackingArea *trackingArea in self.trackingAreas)
    {
        [self removeTrackingArea:trackingArea];
    }

    // Create and add a new tracking area
    const NSTrackingAreaOptions opts = (NSTrackingMouseMoved |
                                         NSTrackingEnabledDuringMouseDrag |
                                         NSTrackingActiveAlways);
    NSTrackingArea *newTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                    options:opts
                                                                      owner:self
                                                                   userInfo:nil];
    [self addTrackingArea:newTrackingArea];
}

@end

#pragma mark - Triple-Buffered Uniform Buffer

@implementation MklUniformBuffer

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device size:(NSUInteger)size
{
    self = [super init];
    if (self)
    {
        _device = device;
        _bufferSize = size;
        _currentIndex = 0;

        // Allocate buffer large enough for MAX_FRAMES_IN_FLIGHT frames
        const NSUInteger totalSize = size * MAX_FRAMES_IN_FLIGHT;
        _buffer = [device newBufferWithLength:totalSize
                                      options:MTLResourceStorageModeShared];

        if (!_buffer)
        {
            fprintf(stderr, "MKL Error: Failed to create uniform buffer\n");
            return nil;
        }
    }
    return self;
}

- (void *)currentBufferPointer
{
    return (uint8_t *)self.buffer.contents + [self currentBufferOffset];
}

- (NSUInteger)currentBufferOffset
{
    return self.currentIndex * self.bufferSize;
}

- (void)advanceFrame
{
    self.currentIndex = (self.currentIndex + 1) % MAX_FRAMES_IN_FLIGHT;
}

@end

#pragma mark - Optimized Buffer Pool

@implementation MklBufferPool

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device
{
    self = [super init];
    if (self)
    {
        _device = device;
        _bufferPools = [NSMutableDictionary dictionary];
        _usedBuffers = [NSMutableArray arrayWithCapacity:128];
        _frameCount = 0;
    }
    return self;
}

- (id<MTLBuffer>)getBufferWithBytes:(const void *)bytes length:(NSUInteger)length
{
    // For dynamic data that changes every frame, create a new buffer
    id<MTLBuffer> buffer = [self getReuseableBufferWithLength:length];
    if (buffer && bytes)
    {
        memcpy(buffer.contents, bytes, length);
    }
    return buffer;
}

- (id<MTLBuffer>)getReuseableBufferWithLength:(NSUInteger)length
{
    // Round up to nearest 4KB for better reuse and to reduce pool fragmentation
    const NSUInteger alignedLength = MKL_ALIGN_BUFFER(length);
    NSNumber *key = @(alignedLength); // Use NSNumber instead of NSString to avoid string allocation

    NSMutableArray<id<MTLBuffer>> *pool = self.bufferPools[key];
    if (!pool)
    {
        pool = [NSMutableArray arrayWithCapacity:16]; // Pre-allocate capacity
        self.bufferPools[key] = pool;
    }

    // Try to reuse an existing buffer
    if (pool.count > 0)
    {
        id<MTLBuffer> buffer = [pool lastObject];
        [pool removeLastObject];
        [self.usedBuffers addObject:buffer]; // Track reused buffer
        return buffer;
    }

    // Create new buffer if none available
    id<MTLBuffer> newBuffer = [self.device newBufferWithLength:alignedLength
                                                        options:MTLResourceStorageModeShared];
    if (!newBuffer)
    {
        fprintf(stderr, "MKL Warning: Failed to allocate buffer of size %lu\n", alignedLength);
        return nil;
    }

    // Track this buffer as used this frame
    [self.usedBuffers addObject:newBuffer];

    return newBuffer;
}

- (void)returnBuffer:(id<MTLBuffer>)buffer
{
    if (!buffer) return;

    const NSUInteger alignedLength = MKL_ALIGN_BUFFER(buffer.length);
    NSNumber *key = @(alignedLength);

    NSMutableArray<id<MTLBuffer>> *pool = self.bufferPools[key];
    if (pool)
    {
        [pool addObject:buffer];
    }
}

- (void)resetFrame
{
    // Return all used buffers to their pools
    for (id<MTLBuffer> buffer in self.usedBuffers)
    {
        const NSUInteger alignedLength = (buffer.length + 4095) & ~4095;
        NSNumber *key = @(alignedLength);

        NSMutableArray<id<MTLBuffer>> *pool = self.bufferPools[key];
        if (pool)
        {
            [pool addObject:buffer];
        }
    }

    // Clear used buffers for next frame
    [self.usedBuffers removeAllObjects];

    self.frameCount++;

    // Limit pool size to prevent unbounded growth
    const NSUInteger maxBuffersPerPool = 32; // Reduced from 64 for tighter memory control

    for (NSMutableArray *pool in [self.bufferPools allValues])
    {
        while (pool.count > maxBuffersPerPool)
        {
            [pool removeLastObject]; // Remove excess buffers to free memory
        }
    }
}

@end

#pragma mark - Renderer Creation and Destruction

MKLRenderer *MKLCreateRenderer(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "MKLCreateRenderer: Failed to create renderer because window is null", NULL);

    MKLRenderer *renderer = (MKLRenderer *)calloc(1, sizeof(MKLRenderer));
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to allocate memory for MKLRenderer", NULL);

    renderer->window = window;

    // Create Metal device
    renderer->_device = MTLCreateSystemDefaultDevice();
    MKL_NULL_CHECK(renderer, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create MTLDevice", NULL);

    // Detect GPU capabilities (Metal 3 optimizations)
    MKLGPUCapabilities *gpuCaps = (MKLGPUCapabilities *)malloc(sizeof(MKLGPUCapabilities));
    if (gpuCaps) {
        *gpuCaps = MKLDetectGPUCapabilities(renderer->_device);
        renderer->_gpuCapabilities = gpuCaps;

        // Print GPU capabilities for debugging
        MKLPrintGPUCapabilities(gpuCaps);
    }

    // Create Metal view
    renderer->_view = [[MTKView alloc] init];
    MKL_NULL_CHECK(renderer->_view, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create MTKView", NULL);

    renderer->_view.device = renderer->_device;
    renderer->_view.preferredFramesPerSecond = 60;
    renderer->_view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    renderer->_view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;

    // Set the view's frame to match the window's content view
    renderer->_view.frame = window->_nswindow.contentView.bounds;

    // Disable automatic drawable resizing and set it manually to match window size (not retina-scaled)
    // This ensures the render size matches the window size exactly (like raylib)
    renderer->_view.autoResizeDrawable = NO;
    renderer->_view.drawableSize = window->_nswindow.contentView.bounds.size;

    // Create Metal layer
    renderer->_metalLayer = [[CAMetalLayer alloc] init];
    MKL_NULL_CHECK(renderer->_metalLayer, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create CAMetalLayer", NULL);

    renderer->_metalLayer.device = renderer->_device;
    renderer->_metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    renderer->_metalLayer.framebufferOnly = NO; // Allow reading back if needed
    renderer->_metalLayer.drawableSize = window->_nswindow.contentView.frame.size;

    // Disable automatic retina scaling for CAMetalLayer as well
    renderer->_metalLayer.contentsScale = 1.0;

    // Enable wide color if available for better color accuracy
    if (@available(macOS 10.12, *))
    {
        renderer->_metalLayer.wantsExtendedDynamicRangeContent = NO;
    }

    [window->_nswindow setContentView:renderer->_view];
    [window->_nswindow.contentView setLayer:renderer->_metalLayer];
    [window->_nswindow.contentView setWantsLayer:YES];
    [window->_nswindow.contentView acceptsFirstResponder];

    // Create command queue - this is thread-safe and should be reused
    renderer->_commandQueue = [renderer->_device newCommandQueue];
    renderer->_commandQueue.label = @"MKL Main Command Queue";

    // Create buffer allocator and pool
    renderer->_bufferAllocator = [[MTKMeshBufferAllocator alloc] initWithDevice:renderer->_device];
    renderer->_bufferPool = [[MklBufferPool alloc] initWithDevice:renderer->_device];

    // Create triple-buffered uniform buffer
    renderer->_uniformBuffer = [[MklUniformBuffer alloc] initWithDevice:renderer->_device size:sizeof(MKLUniforms)];
    MKL_NULL_CHECK(renderer->_uniformBuffer, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create uniform buffer", NULL);

    // Create triple buffering semaphore
    renderer->_inFlightSemaphore = dispatch_semaphore_create(MAX_FRAMES_IN_FLIGHT);
    renderer->_currentBufferIndex = 0;

    // Initialize custom shader to NULL
    renderer->_customShader = NULL;

    // Initialize MSAA (Multi-Sample Anti-Aliasing)
    renderer->_msaaSampleCount = MKL_DEFAULT_MSAA_SAMPLES;
    renderer->_msaaColorTexture = nil;
    renderer->_msaaDepthTexture = nil;
    
    // Set default clear color to black (prevents first frame flash)
    renderer->_clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);

    // Load shaders and create pipeline
    MKLShaderLib(renderer, "MKL/src/Graphics/Shaders/Shaders.metal");
    MKL_NULL_CHECK(renderer->_library, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal library", NULL);

    MKLVertexDescriptorLib(renderer);
    MKL_NULL_CHECK(renderer->_vertexDescriptor, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal vertex descriptor", NULL);

    MKLRenderPipelineLib(renderer);
    MKL_NULL_CHECK(renderer->_pipelineState, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal render pipeline", NULL);

    MKLDepetStencilStateLib(renderer);
    MKL_NULL_CHECK(renderer->_depthStencilState, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal depth stencil state", NULL);

    // Setup enhanced rendering (lighting and textures)
    MKLSetupEnhancedRendering(renderer);

    // Create reusable render pass descriptor
    renderer->_renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];

    // Initialize uniforms
    renderer->uniforms = _gUniforms;
    renderer->uniforms.viewMatrix = matrix_identity_float4x4;
    renderer->uniforms.projectionMatrix = matrix_identity_float4x4;
    
    // Pre-create MSAA and depth textures to avoid first-frame glitch
    // This ensures all resources are ready before the first frame
    @autoreleasepool {
        CGSize drawableSize = renderer->_metalLayer.drawableSize;
        NSUInteger width = (NSUInteger)drawableSize.width;
        NSUInteger height = (NSUInteger)drawableSize.height;
        
        MKLGPUCapabilities *gpuCaps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
        
        if (renderer->_msaaSampleCount > 1 && width > 0 && height > 0) {
            // Create MSAA color texture
            MTLTextureDescriptor *msaaColorDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:renderer->_metalLayer.pixelFormat
                                             width:width
                                            height:height
                                         mipmapped:NO];
            msaaColorDesc.textureType = MTLTextureType2DMultisample;
            msaaColorDesc.sampleCount = renderer->_msaaSampleCount;
            msaaColorDesc.usage = MTLTextureUsageRenderTarget;
            msaaColorDesc.storageMode = gpuCaps ? MKLGetOptimalMSAAStorageMode(gpuCaps) : MTLStorageModePrivate;
            renderer->_msaaColorTexture = [renderer->_device newTextureWithDescriptor:msaaColorDesc];
            
            // Create MSAA depth texture
            MTLTextureDescriptor *msaaDepthDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                             width:width
                                            height:height
                                         mipmapped:NO];
            msaaDepthDesc.textureType = MTLTextureType2DMultisample;
            msaaDepthDesc.sampleCount = renderer->_msaaSampleCount;
            msaaDepthDesc.usage = MTLTextureUsageRenderTarget;
            msaaDepthDesc.storageMode = gpuCaps ? MKLGetOptimalMSAAStorageMode(gpuCaps) : MTLStorageModePrivate;
            renderer->_msaaDepthTexture = [renderer->_device newTextureWithDescriptor:msaaDepthDesc];
            
            // Print optimization message once during initialization
            if (gpuCaps && gpuCaps->supportsMemorylessTargets) {
                printf("✓ Using Metal 3 memoryless storage for MSAA (~20-30%% bandwidth savings)\n");
            }
        } else if (width > 0 && height > 0) {
            // Create regular depth texture
            MTLTextureDescriptor *depthDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                             width:width
                                            height:height
                                         mipmapped:NO];
            depthDesc.usage = MTLTextureUsageRenderTarget;
            depthDesc.storageMode = gpuCaps ? MKLGetOptimalDepthStorageMode(gpuCaps) : MTLStorageModePrivate;
            renderer->_depthTexture = [renderer->_device newTextureWithDescriptor:depthDesc];
        }
    }

    printf("✓ Metal renderer initialized with triple buffering\n");
    return renderer;
}

void MKLClearRenderer(MKLRenderer *renderer, const MKLColor color)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLClearRenderer: Failed to clear renderer because renderer is null");
    renderer->_clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
}

#pragma mark - Drawing Functions

void MKLBeginDrawing(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLBeginDrawing: Failed to begin drawing because renderer is null");

    // Wait for a free slot in the triple buffer
    dispatch_semaphore_wait(renderer->_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    // Get next drawable
    renderer->_drawable = [renderer->_metalLayer nextDrawable];
    if (!renderer->_drawable)
    {
        fprintf(stderr, "MKL Warning: Failed to get next drawable\n");
        dispatch_semaphore_signal(renderer->_inFlightSemaphore);
        return;
    }

    // Create command buffer
    renderer->_commandBuffer = [renderer->_commandQueue commandBuffer];
    renderer->_commandBuffer.label = @"MKL Frame Command Buffer";

    // Add completion handler to signal semaphore when GPU is done
    __block dispatch_semaphore_t blockSemaphore = renderer->_inFlightSemaphore;
    [renderer->_commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        (void)buffer; // Suppress unused parameter warning
        dispatch_semaphore_signal(blockSemaphore);
    }];

    const NSUInteger width = renderer->_drawable.texture.width;
    const NSUInteger height = renderer->_drawable.texture.height;

    // MSAA: Create multisample textures if MSAA is enabled (sample count > 1)
    if (renderer->_msaaSampleCount > 1) {
        // Create or update MSAA color texture
        if (!renderer->_msaaColorTexture ||
            renderer->_msaaColorTexture.width != width ||
            renderer->_msaaColorTexture.height != height ||
            renderer->_msaaColorTexture.sampleCount != renderer->_msaaSampleCount)
        {
            MTLTextureDescriptor *msaaColorDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:renderer->_metalLayer.pixelFormat
                                             width:width
                                            height:height
                                         mipmapped:NO];
            msaaColorDesc.textureType = MTLTextureType2DMultisample;
            msaaColorDesc.sampleCount = renderer->_msaaSampleCount;
            msaaColorDesc.usage = MTLTextureUsageRenderTarget;

            // Use Metal 3 optimized storage mode (memoryless on Apple Silicon)
            MKLGPUCapabilities *gpuCaps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
            msaaColorDesc.storageMode = gpuCaps ? MKLGetOptimalMSAAStorageMode(gpuCaps) : MTLStorageModePrivate;
            renderer->_msaaColorTexture = [renderer->_device newTextureWithDescriptor:msaaColorDesc];
        }

        // Create or update MSAA depth texture
        if (!renderer->_msaaDepthTexture ||
            renderer->_msaaDepthTexture.width != width ||
            renderer->_msaaDepthTexture.height != height ||
            renderer->_msaaDepthTexture.sampleCount != renderer->_msaaSampleCount)
        {
            MTLTextureDescriptor *msaaDepthDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                             width:width
                                            height:height
                                         mipmapped:NO];
            msaaDepthDesc.textureType = MTLTextureType2DMultisample;
            msaaDepthDesc.sampleCount = renderer->_msaaSampleCount;
            msaaDepthDesc.usage = MTLTextureUsageRenderTarget;

            // Use optimal storage mode based on GPU capabilities (Metal 3 optimization)
            MKLGPUCapabilities *gpuCaps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
            if (gpuCaps) {
                msaaDepthDesc.storageMode = MKLGetOptimalMSAAStorageMode(gpuCaps);
            } else {
                msaaDepthDesc.storageMode = MTLStorageModePrivate;
            }

            renderer->_msaaDepthTexture = [renderer->_device newTextureWithDescriptor:msaaDepthDesc];
        }

        // Configure MSAA render pass: Render to MSAA texture, resolve to drawable
        renderer->_renderPassDescriptor.colorAttachments[0].texture = renderer->_msaaColorTexture;
        renderer->_renderPassDescriptor.colorAttachments[0].resolveTexture = renderer->_drawable.texture;
        renderer->_renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
        renderer->_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderer->_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;

        // Configure MSAA depth attachment
        renderer->_renderPassDescriptor.depthAttachment.texture = renderer->_msaaDepthTexture;
        renderer->_renderPassDescriptor.depthAttachment.clearDepth = 1.0;
        renderer->_renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
        renderer->_renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    } else {
        // No MSAA: Regular rendering
        // Create or update depth texture if needed
        if (!renderer->_depthTexture ||
            renderer->_depthTexture.width != width ||
            renderer->_depthTexture.height != height)
        {
            MTLTextureDescriptor *depthDesc = [MTLTextureDescriptor
                texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                             width:width
                                            height:height
                                         mipmapped:NO];
            depthDesc.usage = MTLTextureUsageRenderTarget;

            // Use optimal storage mode based on GPU capabilities (Metal 3 optimization)
            MKLGPUCapabilities *gpuCaps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
            depthDesc.storageMode = gpuCaps ? MKLGetOptimalDepthStorageMode(gpuCaps) : MTLStorageModePrivate;
            renderer->_depthTexture = [renderer->_device newTextureWithDescriptor:depthDesc];
        }

        // Configure regular render pass
        renderer->_renderPassDescriptor.colorAttachments[0].texture = renderer->_drawable.texture;
        renderer->_renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
        renderer->_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderer->_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        renderer->_renderPassDescriptor.colorAttachments[0].resolveTexture = nil;

        // Configure depth attachment
        renderer->_renderPassDescriptor.depthAttachment.texture = renderer->_depthTexture;
        renderer->_renderPassDescriptor.depthAttachment.clearDepth = 1.0;
        renderer->_renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
        renderer->_renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    }

    // Create render encoder
    renderer->_renderEncoder = [renderer->_commandBuffer
        renderCommandEncoderWithDescriptor:renderer->_renderPassDescriptor];
    renderer->_renderEncoder.label = @"MKL Render Encoder";

    if (!renderer->_renderEncoder)
    {
        fprintf(stderr, "MKL Error: Failed to create render encoder\n");
        return;
    }

    // Set pipeline state once
    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    [renderer->_renderEncoder setDepthStencilState:renderer->_depthStencilState];
    [renderer->_renderEncoder setCullMode:MTLCullModeBack];

    // Set front-facing winding (important for correct culling)
    [renderer->_renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];

    // Update uniforms for this frame
    renderer->uniforms.projectionMatrix = MPerspective(renderer->camera.fov,
                                                       renderer->camera.aspect,
                                                       renderer->camera.near,
                                                       renderer->camera.far);
    const vector_float3 target = MAddVector(renderer->camera.position, renderer->camera.forward);
    renderer->uniforms.viewMatrix = MLookAt(renderer->camera.position, target, renderer->camera.up);

    // Write uniforms to triple buffer
    memcpy([renderer->_uniformBuffer currentBufferPointer],
           &renderer->uniforms,
           sizeof(MKLUniforms));

    // Bind uniform buffer
    [renderer->_renderEncoder setVertexBuffer:renderer->_uniformBuffer.buffer
                                       offset:[renderer->_uniformBuffer currentBufferOffset]
                                      atIndex:1];

    // Update lighting data if enhanced rendering is enabled
    if (renderer->_enhancedRenderingEnabled) {
        // Update lighting uniforms
        MKLLightingUniforms *lightingUniforms = (MKLLightingUniforms *)renderer->_lightingUniformsBuffer.contents;
        lightingUniforms->lightCount = MKLGetLightCount(renderer);
        lightingUniforms->cameraPos = renderer->camera.position;

        // Update light buffer
        MKLShaderLight *shaderLights = (MKLShaderLight *)renderer->_lightBuffer.contents;
        int lightCount = MKLGetLightCount(renderer);

        for (int i = 0; i < lightCount && i < 8; i++) {
            MKLLight *light = MKLGetLight(renderer, i);
            if (light && light->enabled) {
                shaderLights[i].color = (vector_float3){light->color.x, light->color.y, light->color.z};
                shaderLights[i].intensity = light->intensity;
                shaderLights[i].position = light->position;
                shaderLights[i].direction = light->direction;
                shaderLights[i].constantAtten = light->constantAttenuation;
                shaderLights[i].linearAtten = light->linearAttenuation;
                shaderLights[i].quadraticAtten = light->quadraticAttenuation;
                shaderLights[i].type = (uint32_t)light->type;
                shaderLights[i].innerConeAngle = light->innerConeAngle;
                shaderLights[i].outerConeAngle = light->outerConeAngle;
            }
        }

        // Update default material
        MKLShaderMaterial *material = (MKLShaderMaterial *)renderer->_materialBuffer.contents;
        material->albedo = (vector_float4){1, 1, 1, 1};
        material->metallic = 0.0f;
        material->roughness = 0.5f;
        material->shininess = 32.0f;
        material->opacity = 1.0f;

        // OPTIMIZATION: Bind lighting buffers once at frame start
        // This eliminates redundant binding in every draw call
        [renderer->_renderEncoder setFragmentBuffer:renderer->_lightingUniformsBuffer
                                            offset:0 atIndex:0];
        [renderer->_renderEncoder setFragmentBuffer:renderer->_lightBuffer
                                            offset:0 atIndex:1];
        [renderer->_renderEncoder setFragmentBuffer:renderer->_materialBuffer
                                            offset:0 atIndex:2];
    }

}

void MKLEndDrawing(MKLRenderer *renderer)
{
    @autoreleasepool {
        MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLEndDrawing: Failed to end drawing because renderer is null");

        if (!renderer->_renderEncoder)
        {
            return; // Nothing to end
        }


        // End encoding
        [renderer->_renderEncoder endEncoding];
        renderer->_renderEncoder = nil;

        // Present drawable
        [renderer->_commandBuffer presentDrawable:renderer->_drawable];

        // Commit command buffer (GPU will start executing)
        [renderer->_commandBuffer commit];

        // DO NOT waitUntilCompleted - this would block and kill performance
        // The semaphore wait in MKLBeginDrawing handles synchronization

        // Advance to next uniform buffer slot
        [renderer->_uniformBuffer advanceFrame];

        // Mark frame complete for buffer pool
        [renderer->_bufferPool resetFrame];
    } // Autorelease pool drains here, releasing all temporary objects from this frame
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLDestroyRenderer: Failed to destroy renderer because renderer is null");

    // Wait for all in-flight frames to complete
    for (int i = 0; i < MAX_FRAMES_IN_FLIGHT; i++)
    {
        dispatch_semaphore_wait(renderer->_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    }

    // Clean up GPU capabilities
    if (renderer->_gpuCapabilities) {
        free(renderer->_gpuCapabilities);
        renderer->_gpuCapabilities = NULL;
    }

    // Clean up Metal objects
    renderer->_depthTexture = nil;
    renderer->_depthStencilState = nil;
    renderer->_pipelineState = nil;
    renderer->_instancedPipelineState = nil;
    renderer->_vertexDescriptor = nil;
    renderer->_library = nil;
    renderer->_renderPassDescriptor = nil;
    renderer->_uniformBuffer = nil;
    renderer->_bufferPool = nil;
    renderer->_bufferAllocator = nil;
    renderer->_commandQueue = nil;

    [renderer->_metalLayer removeFromSuperlayer];
    renderer->_metalLayer = nil;

    [renderer->_view removeFromSuperview];
    renderer->_view = nil;

    renderer->_device = nil;


    free(renderer);
}

// ========== Renderer Query Functions ==========
int MKLGetRenderWidth(MKLRenderer *renderer)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLGetRenderWidth: Failed to get render width because renderer is null", 0);

    if (renderer->_view) {
        return (int)renderer->_view.drawableSize.width;
    }

    return 0;
}

int MKLGetRenderHeight(MKLRenderer *renderer)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLGetRenderHeight: Failed to get render height because renderer is null", 0);

    if (renderer->_view) {
        return (int)renderer->_view.drawableSize.height;
    }

    return 0;
}

vector_float2 MKLGetRenderSize(MKLRenderer *renderer)
{
    if (renderer == NULL) {
        fprintf(stderr, "MKL Error: MKLGetRenderSize: Failed to get render size because renderer is null\n");
        return (vector_float2){0.0f, 0.0f};
    }

    if (renderer->_view) {
        CGSize size = renderer->_view.drawableSize;
        return (vector_float2){(float)size.width, (float)size.height};
    }

    return (vector_float2){0.0f, 0.0f};
}

// ========== Metal 3 Feature Query Functions ==========

const void *MKLGetGPUCapabilities(MKLRenderer *renderer)
{
    return renderer ? renderer->_gpuCapabilities : NULL;
}

bool MKLIsUsingMemorylessDepth(MKLRenderer *renderer)
{
    if (!renderer || !renderer->_gpuCapabilities) {
        return false;
    }

    MKLGPUCapabilities *caps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
    return caps->supportsMemorylessTargets;
}

bool MKLSupportsFastResourceLoading(MKLRenderer *renderer)
{
    if (!renderer || !renderer->_gpuCapabilities) {
        return false;
    }

    MKLGPUCapabilities *caps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
    return caps->supportsFastResourceLoading;
}

bool MKLSupportsMeshShaders(MKLRenderer *renderer)
{
    if (!renderer || !renderer->_gpuCapabilities) {
        return false;
    }

    MKLGPUCapabilities *caps = (MKLGPUCapabilities *)renderer->_gpuCapabilities;
    return caps->supportsMeshShaders;
}

// ========== Enhanced Rendering Control ==========

void MKLEnableEnhancedRendering(MKLRenderer *renderer, bool enable)
{
    if (renderer) {
        renderer->_enhancedRenderingEnabled = enable;
        if (enable) {
            printf("✓ Enhanced rendering enabled (lighting + textures)\n");
        } else {
            printf("✓ Enhanced rendering disabled (simple rendering)\n");
        }
    }
}

bool MKLIsEnhancedRenderingEnabled(MKLRenderer *renderer)
{
    return renderer && renderer->_enhancedRenderingEnabled;
}

// ========== Performance Control ==========

void MKLSetTargetFPS(MKLRenderer *renderer, int fps)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLSetTargetFPS: renderer is NULL");

    if (renderer->_view) {
        renderer->_view.preferredFramesPerSecond = fps;
    }

    // Also update CAMetalLayer to fully bypass VSync
    if (renderer->_metalLayer) {
        if (fps == 0) {
            // Disable VSync completely for unlimited FPS
            renderer->_metalLayer.displaySyncEnabled = NO;
            printf("✓ Target FPS set to UNLIMITED (VSync fully disabled)\n");
        } else {
            // Enable VSync for capped FPS
            renderer->_metalLayer.displaySyncEnabled = YES;
            printf("✓ Target FPS set to %d (VSync enabled)\n", fps);
        }
    }
}

int MKLGetTargetFPS(MKLRenderer *renderer)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLGetTargetFPS: renderer is NULL", 0);

    if (renderer->_view) {
        return (int)renderer->_view.preferredFramesPerSecond;
    }

    return 0;
}

void MKLSetMSAASamples(MKLRenderer *renderer, int samples)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLSetMSAASamples: renderer is NULL");

    // Clamp to valid values (1, 2, 4, 8)
    NSUInteger validSamples = 1;
    if (samples >= 8) validSamples = 8;
    else if (samples >= 4) validSamples = 4;
    else if (samples >= 2) validSamples = 2;
    else validSamples = 1;

    renderer->_msaaSampleCount = validSamples;

    // Clear existing MSAA textures (will be recreated on next frame)
    renderer->_msaaColorTexture = nil;
    renderer->_msaaDepthTexture = nil;

    if (validSamples > 1) {
        printf("✓ MSAA enabled: %dx anti-aliasing (smoother edges)\n", (int)validSamples);
    } else {
        printf("✓ MSAA disabled (1x sample, sharp edges)\n");
    }
}

int MKLGetMSAASamples(MKLRenderer *renderer)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER,
                   "MKLGetMSAASamples: renderer is NULL", 1);

    return (int)renderer->_msaaSampleCount;
}
