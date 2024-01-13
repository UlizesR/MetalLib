#import <AppKit/AppKit.h>
#include <stdio.h>
#include <simd/vector_types.h>
#include <simd/matrix.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

#import "MKLRenderer.h"
#import "MKLLibraries.h"
#import "../Core/MKLError.h"
#import "../Core/MKLTimer.h"

#import "../Math/MKLMath.h"

#include "MKLTypes.h"

static MKLUniforms _gUniforms = {0};

@implementation MTKView (TrackingArea)

- (void)addCustomTrackingArea {
    // Remove all existing tracking areas
    for (NSTrackingArea *trackingArea in self.trackingAreas) {
        [self removeTrackingArea:trackingArea];
    }

    // Create and add a new tracking area
    NSUInteger opts = (NSTrackingMouseMoved | NSTrackingEnabledDuringMouseDrag | NSTrackingActiveAlways);
    NSTrackingArea *newTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil];
    [self addTrackingArea:newTrackingArea];
    [newTrackingArea release];
}

@end

@implementation MklBufferPool

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device;
{
    self = [super init];
    if (self) {
        _device = device;
        _buffers = [NSMutableArray array];
    }
    return self;
}

- (id<MTLBuffer>)getBufferWithBytes:(const void *)bytes length:(NSUInteger)length 
{
    id<MTLBuffer> newBuffer = [_device newBufferWithBytes:bytes length:length options:MTLResourceStorageModeShared];
    [self.buffers addObject:newBuffer];
    return newBuffer;
}

- (void)releaseBuffers
{
    [self.buffers removeAllObjects];
}
@end

MKLRenderer *MKLCreateRenderer(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "MKLCreateRenderer: Failed to create renderer because window is null", NULL)

    MKLRenderer *renderer = (MKLRenderer *)malloc(sizeof(MKLRenderer));
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to allocate memory for MKLRenderer", NULL)

    renderer->window = window;

    renderer->_device = MTLCreateSystemDefaultDevice();
    MKL_NULL_CHECK(renderer->_device, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create MTLDevice", NULL)
    
    renderer->_view = [[MTKView alloc] init];
    MKL_NULL_CHECK(renderer->_view, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create MTKView", NULL)

    renderer->_view.preferredFramesPerSecond = 60;
    renderer->_view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;

    renderer->_metalLayer = [[CAMetalLayer alloc] init];
    MKL_NULL_CHECK(renderer->_metalLayer, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create CAMetalLayer", NULL)

    renderer->_metalLayer.device = renderer->_device;
    renderer->_metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;


    renderer->_metalLayer.framebufferOnly = YES;
    renderer->_metalLayer.drawableSize = window->_nswindow.contentView.frame.size;

    [window->_nswindow setContentView:renderer->_view];
    [window->_nswindow.contentView setLayer:renderer->_metalLayer];
    [window->_nswindow.contentView setWantsLayer:YES];
    [window->_nswindow.contentView acceptsFirstResponder];

    renderer->_commandQueue = [renderer->_device newCommandQueue];
    renderer->_bufferAllocator = [[MTKMeshBufferAllocator alloc] initWithDevice:renderer->_device];
    renderer->_bufferPool = [[MklBufferPool alloc] initWithDevice:renderer->_device];

    MKLShaderLib(renderer, "MKL/src/Renderer/Shaders/Shaders.metal");
    MKL_NULL_CHECK(renderer->_library, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal library", NULL)

    MKLVertexDescriptorLib(renderer);
    MKL_NULL_CHECK(renderer->_vertexDescriptor, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal vertex descriptor", NULL)

    MKLRenderPipelineLib(renderer);
    MKL_NULL_CHECK(renderer->_pipelineState, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal render pipeline", NULL)

    MKLDepetStencilStateLib(renderer);
    MKL_NULL_CHECK(renderer->_depthStencilState, renderer, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLCreateRenderer: Failed to create Metal depth stencil state", NULL)

    renderer->uniforms = _gUniforms;

    renderer->uniforms.viewMatrix = matrix_identity_float4x4;
    renderer->uniforms.projectionMatrix = matrix_identity_float4x4;

    return renderer;
}

void MKLClearRenderer(MKLRenderer *renderer, MKLColor color)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLClearRenderer: Failed to clear renderer because renderer is null")
    renderer->_clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
}

void MKLBeginDrawing(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLBeginDrawing: Failed to begin drawing because renderer is null")

    renderer->_pool = [[NSAutoreleasePool alloc] init];

    renderer->_drawable = [renderer->_metalLayer nextDrawable];
    MKL_NULL_CHECK_VOID(renderer->_drawable, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLBeginDrawing: Failed to get next drawable")

    renderer->_commandBuffer = [renderer->_commandQueue commandBuffer];
    MKL_NULL_CHECK_VOID(renderer->_commandBuffer, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLBeginDrawing: Failed to create command buffer")

    renderer->_renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(renderer->_renderPassDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLBeginDrawing: Failed to create render pass descriptor")

    renderer->_renderPassDescriptor.colorAttachments[0].texture = renderer->_drawable.texture;
    renderer->_renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
    renderer->_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderer->_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    renderer->_renderEncoder = [renderer->_commandBuffer renderCommandEncoderWithDescriptor:renderer->_renderPassDescriptor];
    MKL_NULL_CHECK_VOID(renderer->_renderEncoder, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLBeginDrawing: Failed to create render encoder")

    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    [renderer->_renderEncoder setDepthStencilState:renderer->_depthStencilState];

    renderer->uniforms.projectionMatrix = MPerspective(renderer->camera.fov, renderer->camera.aspect, renderer->camera.near, renderer->camera.far);
    vector_float3 target = MAddVector(renderer->camera.position, renderer->camera.forward);
    renderer->uniforms.viewMatrix = MLookAt(renderer->camera.position, target, renderer->camera.up);

    [renderer->_renderEncoder setVertexBytes:&renderer->uniforms length:sizeof(MKLUniforms) atIndex:1];

    [renderer->_renderEncoder setCullMode:MTLCullModeFront];
}

void MKLEndDrawing(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLEndDrawing: Failed to end drawing because renderer is null")

    [renderer->_renderEncoder endEncoding];

    [renderer->_commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull cb) {
        [renderer->_bufferPool releaseBuffers];
    }];

    [renderer->_commandBuffer presentDrawable:renderer->_drawable];
    [renderer->_commandBuffer commit];
    [renderer->_commandBuffer waitUntilCompleted];

    [renderer->_pool drain];
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLDestroyRenderer: Failed to destroy renderer because renderer is null")

    // release all the Metal objects
    [renderer->_depthStencilState release];
    [renderer->_pipelineState release];
    [renderer->_mdlVertexDescriptor release];
    [renderer->_bufferPool releaseBuffers];
    [renderer->_bufferPool release];
    [renderer->_bufferAllocator release];
    [renderer->_commandQueue release];
    [renderer->_metalLayer removeFromSuperlayer];
    [renderer->_metalLayer release];
    [renderer->_view removeFromSuperview];
    [renderer->_view release];
    [renderer->_device release];

    free(renderer);
}