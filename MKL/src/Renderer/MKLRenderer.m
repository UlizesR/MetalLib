#include <AppKit/AppKit.h>
#include <CoreFoundation/CoreFoundation.h>
#include <QuartzCore/QuartzCore.h>
#include <Metal/Metal.h>

#import "MKLRenderer.h"
#import "MKLLibraries.h"

MKLRenderer *MKLCreateRenderer(MKLWindow *window)
{
    // assert that the window is not null
    if (window == NULL)
    {
        NSLog(@"Cannot create renderer for a null window");
        return NULL;
    }

    MKLRenderer *renderer = (MKLRenderer *)malloc(sizeof(MKLRenderer));
    if (renderer == NULL)
    {
        NSLog(@"Failed to allocate memory for renderer");
        return NULL;
    }

    renderer->window = window;

    renderer->_device = MTLCreateSystemDefaultDevice();
    if (renderer->_device == nil)
    {
        NSLog(@"Failed to create Metal device");
        free(renderer);
        return NULL;
    }
    
    renderer->_view = [[MTKView alloc] init];
    renderer->_view.preferredFramesPerSecond = 60;
    [window->_nswindow setContentView:renderer->_view];

    renderer->_metalLayer = [[CAMetalLayer alloc] init];
    if (renderer->_metalLayer == nil)
    {
        NSLog(@"Failed to create Metal layer");
        free(renderer);
        return NULL;
    }
    renderer->_metalLayer.device = renderer->_device;
    renderer->_metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;

    renderer->_metalLayer.framebufferOnly = YES;
    renderer->_metalLayer.drawableSize = window->_nswindow.contentView.frame.size;

    [window->_nswindow.contentView setLayer:renderer->_metalLayer];
    [window->_nswindow.contentView setWantsLayer:YES];

    renderer->_commandQueue = [renderer->_device newCommandQueue];

    MKLShaderLib(renderer, "MKL/src/Renderer/Shaders/Shaders.metal");
    if (renderer->_library == nil)
    {
        NSLog(@"Failed to create Metal library");
        free(renderer);
        return NULL;
    }
    MKLVertexDescriptorLib(renderer);
    if (renderer->_vertexDescriptor == nil)
    {
        NSLog(@"Failed to create Metal vertex descriptor");
        free(renderer);
        return NULL;
    }
    MKLRenderPipelineLib(renderer);
    if (renderer->_pipelineState == nil)
    {
        NSLog(@"Failed to create Metal render pipeline state");
        free(renderer);
        return NULL;
    }

    return renderer;
}

void MKLClearRenderer(MKLRenderer *renderer, MKLColor color)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }
    renderer->_clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
    // [renderer->_view setNeedsDisplay:YES];
}

void MKLBeginDrawing(MKLRenderer *renderer)
{
     if (renderer == NULL)
     {
         NSLog(@"Renderer is NULL");
         return;
     }

    renderer->_pool = [[NSAutoreleasePool alloc] init];

    renderer->_drawable = [renderer->_metalLayer nextDrawable];
    if (renderer->_drawable == nil)
    {
        NSLog(@"Failed to get drawable");
        return;
    }
    renderer->_commandBuffer = [renderer->_commandQueue commandBuffer];
    if (renderer->_commandBuffer == nil)
    {
        NSLog(@"Failed to create command buffer");
        return;
    }
    renderer->_renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    if (renderer->_renderPassDescriptor == nil)
    {
        NSLog(@"Failed to get render pass descriptor");
        return;
    }

    renderer->_renderPassDescriptor.colorAttachments[0].texture = renderer->_drawable.texture;
    renderer->_renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
    renderer->_renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderer->_renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    renderer->_renderEncoder = [renderer->_commandBuffer renderCommandEncoderWithDescriptor:renderer->_renderPassDescriptor];
    if (renderer->_renderEncoder == nil)
    {
        NSLog(@"Failed to create render encoder");
        return;
    }
}

void MKLEndDrawing(MKLRenderer *renderer)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }

    [renderer->_renderEncoder endEncoding];
    [renderer->_commandBuffer presentDrawable:renderer->_drawable];
    [renderer->_commandBuffer commit];
    [renderer->_commandBuffer waitUntilCompleted];

    [renderer->_pool drain];
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }   

    // release all the Metal objects
    [renderer->_metalLayer removeFromSuperlayer];
    [renderer->_metalLayer release];
    [renderer->_view removeFromSuperview];
    [renderer->_view release];
    [renderer->_commandQueue release];
    [renderer->_pipelineState release];
    [renderer->_vertexDescriptor release];
    [renderer->_vertexBuffer release];
    [renderer->_device release];

    free(renderer);
}