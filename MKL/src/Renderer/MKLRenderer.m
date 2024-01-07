#import "MKLRenderer.h"
#include <AppKit/AppKit.h>
#include <QuartzCore/QuartzCore.h>
#include <Metal/Metal.h>
#import "../Input/Mouse.h"
#import "../Input/Keyboard.h"

#import <assert.h>

@implementation MklView

- (BOOL)acceptsFirstResponder 
{
    return YES;
}

- (void)keyDown:(NSEvent * _Nonnull)event 
{
    [Keyboard setKeyPressed:event.keyCode isOn:YES];
    if([Keyboard isKeyPressed:MKL_KEY_ESCAPE])
    {
        [[NSApp mainWindow] close];
    }
}

- (void)keyUp:(NSEvent * _Nonnull)event 
{
    [Keyboard setKeyPressed:event.keyCode isOn:NO];
}

- (void)mouseDown:(NSEvent * _Nonnull)event 
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:YES];
}

- (void)mouseUp:(NSEvent * _Nonnull)event 
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:NO];
}

- (void)rightMouseDown:(NSEvent * _Nonnull)event
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:YES];
}

- (void)rightMouseUp:(NSEvent * _Nonnull)event
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:NO];
}

- (void)otherMouseDown:(NSEvent * _Nonnull)event
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:YES];
}

- (void)otherMouseUp:(NSEvent * _Nonnull)event
{
    [Mouse setMouseButtonPressed:event.buttonNumber isOn:NO];
}

- (void)setMousePositionChanged:(NSEvent * _Nonnull)event
{
    vector_float2 overallLocation = {event.locationInWindow.x, event.locationInWindow.y};
    vector_float2 deltaLocation = {event.deltaX, event.deltaY};
    [Mouse setMousePositionChangeWithOverallPosition:overallLocation deltaPosition:deltaLocation];
}

- (void)updateTrackingAreas 
{
    NSUInteger opts = (NSTrackingMouseMoved | NSTrackingEnabledDuringMouseDrag | NSTrackingActiveAlways);
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseMoved:(NSEvent * _Nonnull)event
{
    [self setMousePositionChanged:event];
}

- (void)mouseDragged:(NSEvent * _Nonnull)event
{
    [self setMousePositionChanged:event];
}

- (void)rightMouseDragged:(NSEvent * _Nonnull)event
{
    [self setMousePositionChanged:event];
}

- (void)otherMouseDragged:(NSEvent * _Nonnull)event
{
    [self setMousePositionChanged:event];
}

- (void)scrollWheel:(NSEvent * _Nonnull)event
{
    [Mouse scrollMouse:event.deltaY];
}

@end

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
    MklView *view = [[MklView alloc] initWithFrame:window->_nswindow.contentView.bounds];
    if (view == nil)
    {
        NSLog(@"Failed to create view");
        free(renderer);
        return NULL;
    }
    renderer->_view = view;
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

    [window->_nswindow.contentView setLayer:renderer->_metalLayer];
    [window->_nswindow.contentView setWantsLayer:YES];

    renderer->_commandQueue = [renderer->_device newCommandQueue];

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

void MKLDraw(MKLRenderer *renderer)
{
    @autoreleasepool {
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

        id<MTLCommandBuffer> commandBuffer = [renderer->_commandQueue commandBuffer];
        if (commandBuffer == nil)
        {
            NSLog(@"Failed to create command buffer");
            return;
        }
        MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        if (renderPassDescriptor == nil)
        {
            NSLog(@"Failed to get render pass descriptor");
            return;
        }

        renderPassDescriptor.colorAttachments[0].texture = renderer->_drawable.texture;
        renderPassDescriptor.colorAttachments[0].clearColor = renderer->_clearColor;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        if (renderEncoder == nil)
        {
            NSLog(@"Failed to create render encoder");
            return;
        }
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:renderer->_drawable];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];

        [renderPassDescriptor release];
    }
}

void MKLDestroyRenderer(MKLRenderer *renderer)
{
    if (renderer == NULL)
    {
        NSLog(@"Renderer is NULL");
        return;
    }   
    [renderer->_view release];
    [renderer->_metalLayer release];
    free(renderer);
}