#import "MCL/graphics/renderer.h"
#import "MCL/mcl_sys/gpu.h"
#import "MCL/window.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@implementation MTK_Renderer

- (id)init:(id<MTLDevice>)device
{
    self = [super init];
    if (!self)
    {
        printf("Failed to create MTK_Renderer\n");
        return nil;
    }
    self.device = device;
    self.commandQueue = [self.device newCommandQueue];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];

    NSError *error = nil;
    NSString *shaderCode =
        @"#include <metal_stdlib>\n"
         "using namespace metal;\n"
         "#include <simd/simd.h>\n"
         "struct Vertex {\n"
            "vector_float2 position;\n"
            "vector_float4 color;\n"
        "};\n"
         "struct Fragment {\n"
         "    float4 position [[position]];\n"
         "    float4 color;\n"
         "};\n"
         "vertex Fragment vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid_id [[vertex_id]]) {\n"
         "Vertex input = vertexArray[vid_id];\n"

         "Fragment output;\n"
         "output.position = float4(input.position.x, input.position.y, 0, 1.0);\n"
         "output.color = input.color;\n"

         "return output;\n"
         "}\n"

         "fragment float4 fragmentShader(Fragment input [[stage_in]]) {\n"
         "return input.color;\n"
         "};";

    id<MTLLibrary> library = [self.device newLibraryWithSource:shaderCode
                                                        options:nil
                                                          error:&error];
    if (error) {
      fprintf(stderr, "Error: Failed to create MTLLibrary: %s\n",
              [[error localizedDescription] UTF8String]);
      return nil;
    }   
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertexShader"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (!self.pipelineState) {
        fprintf(stderr, "Error: Failed to create pipeline state\n");
        return nil;
    }

    // Vertex vertices[] = {
    //         {{0.0, 0.5}, MCL_COLOR2VECTOR_F4(MCL_COLOR_MAGENTA_5)},
    //         {{-0.5, -0.5}, MCL_COLOR2VECTOR_F4(MCL_COLOR_CYAN_5)},
    //         {{0.5, -0.5}, MCL_COLOR2VECTOR_F4(MCL_COLOR_YELLOW_5)}
    // };
    // self.vertexBuffer = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    self.scene = [[MCL_NsScene alloc] init];
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size 
{
}

- (void)drawInMTKView:(nonnull MTKView *)view 
{
    // get drawable
    id<MTLDrawable> drawable = view.currentDrawable;
    if (!drawable) {
        fprintf(stderr, "Error: Failed to get drawable\n");
        return;
    }
    // create command buffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    // create render pass descriptor
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (!renderPassDescriptor) {
        fprintf(stderr, "Error: Failed to get render pass descriptor\n");
        return;
    }
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

    // create render command encoder
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    if (!renderCommandEncoder) {
        fprintf(stderr, "Error: Failed to create render command encoder\n");
        return;
    }

    if (self.mesh)
    {
        // set render command encoder state
        [renderCommandEncoder setRenderPipelineState:self.pipelineState];
        [renderCommandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];

    }
    // end encoding
    [renderCommandEncoder endEncoding];

    // present drawable
    [commandBuffer presentDrawable:drawable];
    // commit command buffer
    [commandBuffer commit];
}

@end

void MCL_CreateRenderer(MCL_Window *window, MCL_Renderer *renderer) 
{
    renderer->device = MCL_GetVDevice();
    if (!renderer->device) 
    {
        fprintf(stderr, "Error: Failed to get virtual device\n");
        return;
    }
    renderer->surface = NULL;
    renderer->context = NULL;
    renderer->window = window;

    MTK_Renderer *mtk_renderer = [[MTK_Renderer alloc] init:renderer->device->_device.device];
    if (!mtk_renderer) 
    {
        fprintf(stderr, "Error: Failed to create MTK_Renderer\n");
        return;
    }
    renderer->_this = (__bridge void *)(mtk_renderer);
}

void MCL_SetRendererSurface(MCL_Renderer *renderer, MCL_Surface *surface, int x, int y, int w, int h) 
{
    // check if renderer null
    if (renderer == NULL) {
        fprintf(stderr, "Failed to set renderer surface: renderer is null\n");
        return;
    }
    // get the MTK_Renderer
    MTK_Renderer *mtk_renderer = (__bridge MTK_Renderer *)(renderer->_this);
    surface->x = x;
    surface->y = y;
    surface->w = w;
    surface->h = h;
    surface->layer = NULL;
    // set the surface
    renderer->surface = surface;
    // get the device
    id<MTLDevice> device = renderer->device->_device.device;
    // create a MTKView
    MTKView *view = [[MTKView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    // set the view's delegate to the MTK_Renderer
    view.delegate = mtk_renderer;
    // set the view preffered fps
    view.preferredFramesPerSecond = 60;
    view.enableSetNeedsDisplay = YES;
    // set the view device
    view.device = device;

    view.framebufferOnly = NO;
    view.drawableSize = view.frame.size;

    // get the ns window
    NSWindow *ns_window = (__bridge NSWindow *)(renderer->window->_this);
    if (!ns_window) {
        fprintf(stderr, "Error: Failed to get NSWindow\n");
        return;
    }
    renderer->surface->_this = (__bridge void *)(view);
    [ns_window setContentView:view];
}

void MCL_ClearRenderer(MCL_Renderer *renderer, MCL_Color color)
{

}