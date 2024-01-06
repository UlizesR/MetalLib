#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

@interface MklView : MTKView

- (nonnull instancetype)initMklView;
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

#endif // _MKL_VIEW_H_