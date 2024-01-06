#import "MKLRenderer.h"
#import "MKLView.h"
#import "../MKLWindow.h"

#import <Metal/Metal.h>

@implementation MklRenderer


- (nonnull instancetype)initRenderer:(MTKView *_Nonnull)view
{
    self = [super init];
    if (!self) 
    {
        NSLog(@"Failed to initialize MKLRenderer");
        return nil;
    }
    self.bounds = (vector_float2){0.0f,0.0f};
    self.deltaTime = 1.0f / (float)view.preferredFramesPerSecond;
    self.commandQueue = [view.device newCommandQueue];
    [self updateScreenSize:view];

    return self;

}

- (void)updateScreenSize:(MTKView *_Nonnull)view
{
    self.bounds = (vector_float2){view.bounds.size.width, view.bounds.size.height};
}

- (void)drawInMTKView:(nonnull MTKView *)view 
{
    id<CAMetalDrawable> drawable = (id<CAMetalDrawable>)view.currentDrawable;
    if(!drawable)
    {
        NSLog(@"Failed to get drawable");
        return;
    }

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if(!commandBuffer)
    {
        NSLog(@"Failed to create command buffer");
        return;
    }

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(!renderPassDescriptor)
    {
        NSLog(@"Failed to get render pass descriptor");
        return;
    }

    renderPassDescriptor.colorAttachments[0].clearColor = self.clearColor;
	renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
	renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    if(!renderEncoder)
    {
        NSLog(@"Failed to create render encoder");
        return;
    }

    [renderEncoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size 
{
    // This is called whenever the window is resized
    [self updateScreenSize:view];
}


@end


MKLRenderer *MKLCreateRenderer(MKLWindow *window)
{
    // Allocate memory for the renderer
    MKLRenderer *renderer = malloc(sizeof(MKLRenderer));
    if(renderer == NULL)
    {
        NSLog(@"Failed to allocate memory for renderer");
        return NULL;
    }

    // Create the view
    renderer->_view = [[MklView alloc] initMklView];
    if(renderer->_view == NULL)
    {
        NSLog(@"Failed to create view");
        free(renderer);
        return NULL;
    }

    // Create the renderer
    renderer->_renderer = [[MklRenderer alloc] initRenderer:renderer->_view];
    if(renderer->_renderer == NULL)
    {
        NSLog(@"Failed to create renderer");
        free(renderer);
        return NULL;
    }

    [window->_nswindow setContentView:renderer->_view];
    [window->_nswindow makeFirstResponder:renderer->_view];

    [renderer->_view setDelegate:renderer->_renderer];

    return renderer;
}

void MKLClearRenderer(MKLRenderer *renderer, MKLColor color)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }
    renderer->_renderer.clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
    [renderer->_view setNeedsDisplay:YES];
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }
    [renderer->_view release];
    [renderer->_renderer release];
    free(renderer);
}