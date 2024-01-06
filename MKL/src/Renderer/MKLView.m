#import "MKLView.h"
#import "../Input/Mouse.h"
#import "../Input/Keyboard.h"

#include <AppKit/AppKit.h>

@implementation MklView

- (nonnull instancetype)initMklView
{
    self = [super init];
    if (!self) 
    {
        NSLog(@"Failed to initialize MKLView");
        return nil;
    }
    self.device = MTLCreateSystemDefaultDevice();
    if (!self.device) 
    {
        NSLog(@"Failed to create Metal device");
        return nil;
    }
    self.preferredFramesPerSecond = 60;
    self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    self.enableSetNeedsDisplay = YES;
    [self acceptsFirstResponder];
    return self;
}

- (BOOL)acceptsFirstResponder 
{
    return YES;
}

- (void)keyDown:(NSEvent * _Nonnull)event 
{
    [Keyboard setKeyPressed:event.keyCode isOn:YES];
    if([Keyboard isKeyPressed:MKL_KEY_ESCAPE])
    {
        [NSApp terminate:nil];
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