#import "MCL/metal.h"
#include "MCL/colors.h"
#import "MCL/window.h"
#import "MCL/view.h"

#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

@implementation MTK_Renderer

- (id)initWithViewAndWindow:(nonnull MTKView *)view window:(NSWindow *)window {
    // Initialize the renderer
    self = [super init];
    if (self) {
        // Create the device
        self._device = MTLCreateSystemDefaultDevice();
        if (!self._device) {
        fprintf(stderr, "Error: Failed to create MTLDevice\n");
        return nil;
        }
        self._view = view;
        // set the view's device
        [view setDevice:self._device];
        [view setDelegate:self];
        // set the window's view
        [window setContentView:view];
        self._commandQueue = [self._device newCommandQueue];
        // Create a vertex descriptor
        MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
        vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2;
        vertexDescriptor.attributes[0].offset = 0;
        vertexDescriptor.attributes[0].bufferIndex = 0;
        vertexDescriptor.layouts[0].stride = sizeof(MFPoint);

        // Create a library from the Metal shader source
        NSError *error = nil;
        NSString *shaderSource =
            @"#include <metal_stdlib>\n"
             "using namespace metal;\n"
             "struct VertexIn {\n"
             "    float2 position [[attribute(0)]];\n"
             "};\n"
             "struct VertexOut {\n"
             "    float4 position [[position]];\n"
             "    float4 color;\n"
             "};\n"
             "vertex VertexOut vertexShader(const device VertexIn *vertices "
             "[[buffer(0)]],\n"
             "                              const constant float4 &color "
             "[[buffer(1)]],\n"
             "                              uint vid [[vertex_id]])\n"
             "{\n"
             "    VertexOut out;\n"
             "    out.position = float4(vertices[vid].position, 0.0, 1.0);\n"
             "    out.color = color;\n"
             "    return out;\n"
             "}\n"
             "fragment float4 fragmentShader(VertexOut interpolated "
             "[[stage_in]])\n"
             "{\n"
             "    return interpolated.color;\n"
             "}";
        id<MTLLibrary> library = [self._device newLibraryWithSource:shaderSource
                                                            options:nil
                                                              error:&error];
        if (error) {
          fprintf(stderr, "Error: Failed to create MTLLibrary: %s\n",
                  [[error localizedDescription] UTF8String]);
          return nil;
        }
        self._library = library;

        // Create a render pipeline descriptor
        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineDescriptor.vertexFunction = [self._library newFunctionWithName:@"vertexShader"];
        pipelineDescriptor.fragmentFunction = [self._library newFunctionWithName:@"fragmentShader"];
        pipelineDescriptor.vertexDescriptor = vertexDescriptor;
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;

        // Create a render pipeline state
        self._pipelineState = [self._device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                        error:&error];
        if (error) {
        fprintf(stderr, "Error: Failed to create MTLRenderPipelineState: %s\n", [[error localizedDescription] UTF8String]);
        return nil;
        }
        
    }
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size 
{
}

- (void)drawInMTKView:(nonnull MTKView *)view {
}

- (void)removeShape {
  // Clear the drawable
  id<MTLDrawable> drawable = self._view.currentDrawable;
  id<MTLCommandBuffer> commandBuffer = [self._commandQueue commandBuffer];
  MTLRenderPassDescriptor *renderPassDescriptor = self._view.currentRenderPassDescriptor;
  if (renderPassDescriptor) {
    id<MTLRenderCommandEncoder> commandEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
  }
}
@end

M_Renderer *M_Renderer_init(M_Window *window)
{
    M_Renderer *renderer = (M_Renderer *)malloc(sizeof(M_Renderer));
    if (!renderer) {
        fprintf(stderr, "Error: Failed to allocate memory for M_Renderer\n");
        return NULL;
    }
    // get the nsWindow
    NSWindow *nsWindow = (__bridge NSWindow *)(window->delegate);
    if (!nsWindow) {
        fprintf(stderr, "Error: Failed to get NSWindow from M_Window\n");
        return NULL;
    }
    // create the metal view
    MTKView *view = [[MTKView alloc] initWithFrame:nsWindow.frame];
    if (!view) {
        fprintf(stderr, "Error: Failed to create MTKView\n");
        return NULL;
    }
    // create the renderer
    renderer->_renderer = [[MTK_Renderer alloc] initWithViewAndWindow:view window:nsWindow];
    if (!renderer->_renderer) {
      fprintf(stderr, "Error: Failed to create MTK_Renderer\n");
      return NULL;
    }

    renderer->_view = (__bridge void *)(view);
    renderer->_delegate = NULL;
    renderer->_mview = view;
    return renderer;
}

void M_Renderer_destroy(M_Renderer *renderer)
{
    free(renderer);
}

void M_Renderer_Clear(M_Renderer *renderer, M_Color color) {
  MTKView *view = (__bridge MTKView *)(renderer->_view);
  if (!view) {
    fprintf(stderr, "Error: Failed to get MTKView from M_Renderer\n");
    return;
  }
  view.clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
  [renderer->_renderer removeShape];
}

void drawTriangle(M_Renderer *renderer, MFPoint vertices[], M_Color color) {

  id<MTLDevice> device = renderer->_renderer._device;
  if (!device) {
    fprintf(stderr, "Error: Failed to get MTLDevice from MTK_Renderer\n");
    return;
  }
  id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:vertices
                          length:3 * sizeof(MFPoint)
                         options:MTLResourceCPUCacheModeDefaultCache];

  // Create a render pass descriptor
  MTLRenderPassDescriptor *renderPassDescriptor = renderer->_mview.currentRenderPassDescriptor;
  if (renderPassDescriptor) {
    id<MTLCommandBuffer> commandBuffer = [renderer->_renderer._commandQueue commandBuffer];

    // Create a render command encoder
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

    [commandEncoder setRenderPipelineState:renderer->_renderer._pipelineState];
    [commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [commandEncoder setVertexBytes:&color length:sizeof(M_Color) atIndex:1];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                       vertexStart:0
                       vertexCount:3];
    [commandEncoder endEncoding];

    // Get the drawable that will be presented at the end of the frame
    id<MTLDrawable> drawable = renderer->_mview.currentDrawable;

    // Request that the drawable texture be presented by the windowing system
    // once drawing is done
    [commandBuffer presentDrawable:drawable];
    // Commit the command buffer to the GPU
    [commandBuffer commit];
  } else {
    fprintf(stderr,
            "Error: Failed to get MTLRenderPassDescriptor from MTKView\n");
  }
}