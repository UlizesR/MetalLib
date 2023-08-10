#ifndef mac_renderer_h_
#define mac_renderer_h_

#include "mac_defs.h"
#include "mac_colors.h"
#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    MAC_RENDERER_CORE_G = 1,
    MAC_RENDERER_METAL = 2,
} Mac_RendererType;

typedef union URView 
{
    Mac_RView* rview;
    Mac_MView* mview;
} URView;

struct Mac_Renderer
{
    Mac_RendererType type;      // The type of renderer
    URView* render_view;     // The view that renders the shapes
    bool is_init;               // Whether the renderer is initialized or not
};

/*!
    Create and initialize a renderer.
    @param type The type of renderer to create.
    @param view_to_render The view to render.    
*/
Mac_Renderer* MAC_CreateRenderer(Mac_RendererType type, Mac_View* view_to_render);

/*!
    Create a window and a renderer.
    To use if you want to purely do graphics.
    @param width The width of the window.
    @param height The height of the window.
    @param title The title of the window.
    @param type The type of renderer to create.
    @param window The created window.
    @param renderer The created renderer.
*/
void MAC_CreateWindowAndRenderer(int width, int height, MTitle, Mac_RendererType type, UInt32 flags, Mac_Window** window, Mac_Renderer** renderer);

/*!
    Sets the renderer's background color.
    @param renderer The renderer to set the background color.
    @param color The color to set.
*/
void MAC_SetRendererColor(Mac_Renderer* renderer, Mac_Color color);

/*!
    Clear the renderer.
    @param renderer The renderer to clear.
*/
void MAC_ClearRenderer(Mac_Renderer* renderer);

/*!
    Destroy the given renderer.
    @param renderer The renderer to destroy.
*/
void MAC_DestroyRenderer(Mac_Renderer* renderer);

#ifdef __cplusplus
}
#endif

#endif // mac_renderer_h_