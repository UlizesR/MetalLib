#include <AppKit/AppKit.h>
#include <CoreFoundation/CoreFoundation.h>
#include <QuartzCore/QuartzCore.h>
#include <Metal/Metal.h>

#import "MKLRenderer.h"
#import "../Input/Mouse.h"
#import "../Input/Keyboard.h"

const char *getFilePath(const char * directory, const char * fileName, const char * fileExtension)
{
    // Get the path to the current file
    NSString *currentFile = [NSString stringWithUTF8String:__FILE__];
    NSString *currentDirectory = [currentFile stringByDeletingLastPathComponent];

    // Get the parent directory of 'src'
    currentDirectory = [currentDirectory stringByDeletingLastPathComponent];

    // Append the input string to the parent directory
    NSString *file = [NSString stringWithFormat:@"%@/%@.%@", [NSString stringWithUTF8String:directory], [NSString stringWithUTF8String:fileName], [NSString stringWithUTF8String:fileExtension]];
    NSString *filePath = [currentDirectory stringByAppendingPathComponent:file];

    return [filePath UTF8String];
}

void MKLShaderLib(MKLRenderer *renderer, const char *shaderPath)
{
    // if (shaderPath == NULL) 
    // {
        shaderPath = getFilePath("Shaders", "Shaders", "metal");
    // }

    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:[NSString stringWithUTF8String:shaderPath]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (error != nil) 
    {
        NSLog(@"MKLShaderLib: %@", error);
        return;
    }

    renderer->_library = [renderer->_device newLibraryWithSource:shaderSource
                                                          options:nil
                                                            error:&error];

    if (error != nil)
    {
        NSLog(@"MKLShaderLib: %@", error);
        return;
    }

    [shaderSource release];
}

void MKLRenderPipeline(MKLRenderer *renderer)
{
    if (renderer == nil) 
    {
        NSLog(@"MKLRenderPipeline: renderer is nil");
        return;
    }

    NSError *error = nil;
    id<MTLFunction> vertexFunction = [renderer->_library newFunctionWithName:@"vertexShader"];
    if (vertexFunction == nil) 
    {
        NSLog(@"MKLRenderPipeline: vertexFunction is nil");
        return;
    }
    id<MTLFunction> fragmentFunction = [renderer->_library newFunctionWithName:@"fragmentShader"];
    if (fragmentFunction == nil) 
    {
        NSLog(@"MKLRenderPipeline: fragmentFunction is nil");
        return;
    }

    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    if (pipelineDescriptor == nil) 
    {
        NSLog(@"MKLRenderPipeline: pipelineDescriptor is nil");
        return;
    }
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = renderer->_metalLayer.pixelFormat;

    renderer->_pipelineState = [renderer->_device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                                 error:&error];

    if (error != nil)
    {
        NSLog(@"MKLRenderPipeline: %@", error);
        return;
    }

    [pipelineDescriptor release];

}

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

    MKLShaderLib(renderer, NULL);
    MKLRenderPipeline(renderer);

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

        // Clean up temporary objects
        [renderer->_renderPassDescriptor release];
        renderer->_renderPassDescriptor = nil;
        [renderer->_renderEncoder release];
        renderer->_renderEncoder = nil;
        [renderer->_drawable release];
        renderer->_drawable = nil;
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }   

    [renderer->_view removeFromSuperview];
    [renderer->_view release];
    [renderer->_metalLayer removeFromSuperlayer];
    [renderer->_metalLayer release];
    [renderer->_device release];
    [renderer->_commandQueue release];
    free(renderer);
}