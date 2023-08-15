#pragma once

#include "mac_defs.h"
#include "mac_colors.h"
#include "mac_devices.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface M_NSView_Metal: MTKView;

@end

@interface MtlRenderer: NSObject <MTKViewDelegate>
- (nonnull instancetype)initWithMetalKitView:(nonnull M_NSView_Metal *)mtkView;
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct M_MView                      // metal view to render metal graphics
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    M_Color background_color;       // The background color of the view
    MPoint position;                // The position of this view
    M_Window *_Nonnull window_parent; // The parent window of this view
    M_Renderer *_Nonnull renderer;  // The renderer that owns this view
    M_VDevice *_Nonnull device;     // The device that owns this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _Nonnull _this;           // The pointer to this view
};

/*!
    Initializes a metal renderer.
    @param renderer The renderer to initialize.
*/
void M_InitMetalRenderer(M_Renderer *_Nonnull renderer);

/*!
    Clears the MTKView associated with the renderer.
    @param renderer The renderer whose MTKView needs to be cleared.
*/
void M_ClearMTKView(M_Renderer* _Nonnull renderer);

/*!
    Sets the background color of the MTKView associated with the renderer.
    @param renderer The renderer whose MTKView's background color needs to be set.
    @param color The color to set as the background.
*/
void M_SetBackgroundColorMTKView(M_Renderer* _Nonnull renderer, M_Color color);

#ifdef __cplusplus
}
#endif
