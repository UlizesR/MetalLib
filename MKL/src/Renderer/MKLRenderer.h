#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#include <Metal/Metal.h>
#include <QuartzCore/QuartzCore.h>
#include <stdint.h>

#include "../MKLWindow.h"
#include "../MKLCore.h"
#include "../MKLColors.h"

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

@interface MklView : MTKView

// Methods to handle events
- (BOOL)acceptsFirstResponder;

//--- Keyboard Input ---
- (void)keyDown:(NSEvent * _Nonnull)event;
- (void)keyUp:(NSEvent * _Nonnull)event;

//--- Mouse Button Input ---
- (void)mouseDown:(NSEvent * _Nonnull)event;
- (void)mouseUp:(NSEvent * _Nonnull)event;
- (void)rightMouseDown:(NSEvent * _Nonnull)event;
- (void)rightMouseUp:(NSEvent * _Nonnull)event;
- (void)otherMouseDown:(NSEvent * _Nonnull)event;
- (void)otherMouseUp:(NSEvent * _Nonnull)event;

//--- Mouse Movement Input ---
- (void)mouseMoved:(NSEvent * _Nonnull)event;
- (void)mouseDragged:(NSEvent * _Nonnull)event;
- (void)rightMouseDragged:(NSEvent * _Nonnull)event;
- (void)otherMouseDragged:(NSEvent * _Nonnull)event;

//--- Mouse Scroll Input ---
- (void)scrollWheel:(NSEvent * _Nonnull)event;

@end

#endif 

typedef struct MKLRenderer
{
    MKLWindow *window;
#ifdef __OBJC__
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<CAMetalDrawable> _drawable;
    CAMetalLayer *_metalLayer;
    MTLClearColor _clearColor;
    MklView *_view;
#endif
} MKLRenderer;



MKLAPI MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKLAPI void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKLAPI void MKLDraw(MKLRenderer *renderer);

MKLAPI void MKLDestroyRenderer(MKLRenderer *renderer);

#endif // _MKL_VIEW_H_