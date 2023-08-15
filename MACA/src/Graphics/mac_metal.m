#import "MACA/mac_metal.h"
#include "MACA/mac_defs.h"
#include "MACA/mac_colors.h"
#include <stdio.h>
#import "MACA/mac_renderer.h"

@implementation MtlRenderer
{
    id<MTLDevice> _device;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _commandQueue;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull M_NSView_Metal *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;

        // Create the command queue
        _commandQueue = [_device newCommandQueue];
    }

    return self;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    // The render pass descriptor references the texture into which Metal should draw
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil)
    {
        return;
    }

    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    // Create a render pass and immediately end encoding, causing the drawable to be cleared
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder endEncoding];
    
    // Get the drawable that will be presented at the end of the frame

    id<MTLDrawable> drawable = view.currentDrawable;

    // Request that the drawable texture be presented by the windowing system once drawing is done
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

@end

// Clears the MTKView
void clearMTKView(M_NSView_Metal *mtkView) {
    [mtkView setNeedsDisplay:YES];
}

// Sets the background color of the MTKView
void setBackgroundColorMTKView(M_NSView_Metal *mtkView, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    mtkView.clearColor = MTLClearColorMake(red, green, blue, alpha);
}


void M_InitMetalRenderer(M_Renderer *renderer)
{
    if (!renderer)
    {
        printf("M_InitMetalRenderer: renderer is NULL\n");
        return;
    }
    M_NSView_Metal *mtkView = (__bridge M_NSView_Metal *)renderer->render_view->mview->_this;
    mtkView.device = MTLCreateSystemDefaultDevice();

    MtlRenderer *mtlRenderer = [[MtlRenderer alloc] initWithMetalKitView:mtkView];
    if (!mtlRenderer)
    {
        printf("M_InitMetalRenderer: mtlRenderer is NULL\n");
        return;
    }

    mtkView.delegate = mtlRenderer;
}

void M_ClearMTKView(M_Renderer* renderer) {
    if (renderer == NULL) {
        printf("M_ClearMTKView: renderer is NULL\n");
        return;
    }
    M_NSView_Metal *mtkView = (__bridge M_NSView_Metal *)renderer->render_view->mview->_this;
    clearMTKView(mtkView);
    
}

// Sets the background color of the MTKView
void M_SetBackgroundColorMTKView(M_Renderer* renderer, M_Color color) {
    if (renderer == NULL) {
        printf("M_SetBackgroundColorMTKView: renderer is NULL\n");
        return;
    }
    M_NSView_Metal *mtkView = (__bridge M_NSView_Metal *)renderer->render_view->mview->_this;
    setBackgroundColorMTKView(mtkView, color.r, color.g, color.b, color.a);
    
}