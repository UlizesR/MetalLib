#include <simd/matrix.h>
#include <stdio.h>

#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

#import "MKLRenderer.h"
#import "MKLLibraries.h"
#import "MKLLight.h"
#import "../Core/MKLError.h"
#import "../Core/MKLTimer.h"
#import "../Math/MKLMath.h"
#include "MKLTypes.h"

// Triple buffering constant - allows 3 frames in flight
#define MAX_FRAMES_IN_FLIGHT 3

static MKLUniforms _gUniforms = {0};

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
    const NSUInteger alignedLength = (length + 4095) & ~4095;
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
    
    const NSUInteger alignedLength = (buffer.length + 4095) & ~4095;
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
    
    printf("✓ Metal renderer initialized with triple buffering\n");
    return renderer;
}

void MKLClearRenderer(MKLRenderer *renderer, const MKLColor color)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLClearRenderer: Failed to clear renderer because renderer is null");
    renderer->_clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
}

#pragma mark - Drawing Functions

void MKLBeginDrawing(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLBeginDrawing: Failed to begin drawing because renderer is null");

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

    // Create or update depth texture if needed
    if (!renderer->_depthTexture || 
        renderer->_depthTexture.width != renderer->_drawable.texture.width ||
        renderer->_depthTexture.height != renderer->_drawable.texture.height)
    {
        MTLTextureDescriptor *depthDesc = [MTLTextureDescriptor 
            texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                         width:renderer->_drawable.texture.width
                                        height:renderer->_drawable.texture.height
                                     mipmapped:NO];
        depthDesc.usage = MTLTextureUsageRenderTarget;
        depthDesc.storageMode = MTLStorageModePrivate;
        renderer->_depthTexture = [renderer->_device newTextureWithDescriptor:depthDesc];
    }

    // Configure render pass descriptor
    renderer->_renderPassDescriptor.colorAttachments[0].texture = renderer->_drawable.texture;
    renderer->_renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
    renderer->_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderer->_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    // Configure depth attachment
    renderer->_renderPassDescriptor.depthAttachment.texture = renderer->_depthTexture;
    renderer->_renderPassDescriptor.depthAttachment.clearDepth = 1.0;
    renderer->_renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    renderer->_renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    
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
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER,
                   "MKLGetRenderWidth: Failed to get render width because renderer is null", 0);
    
    if (renderer->_view) {
        return (int)renderer->_view.drawableSize.width;
    }
    
    return 0;
}

int MKLGetRenderHeight(MKLRenderer *renderer)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER,
                   "MKLGetRenderHeight: Failed to get render height because renderer is null", 0);
    
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
