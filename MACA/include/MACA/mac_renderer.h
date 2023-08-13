#pragma once

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
    M_RENDERER_CORE_G = 1,
    M_RENDERER_METAL = 2,
} M_RendererType;

typedef union URView 
{
    M_RView* rview;
    M_MView* mview;
} URView;

struct M_Renderer
{
    M_RendererType type;      // The type of renderer
    URView* render_view;     // The view that renders the shapes
    bool is_init;               // Whether the renderer is initialized or not
};

/*!
    Create and initialize a renderer.
    @param type The type of renderer to create.
    @param view_to_render The view to render.    
*/
M_Renderer* M_CreateRenderer(M_RendererType type, M_View* view_to_render);

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
void M_CreateWindowAndRenderer(int width, int height, MTitle, M_RendererType type, UInt32 flags, M_Window** window, M_Renderer** renderer);

/*!
    Sets the renderer's background color.
    @param renderer The renderer to set the background color.
    @param color The color to set.
*/
void M_SetRendererColor(M_Renderer* renderer, M_Color color);

/*!
    Clear the renderer.
    @param renderer The renderer to clear.
*/
void M_ClearRenderer(M_Renderer* renderer);

/*!
    Destroy the given renderer.
    @param renderer The renderer to destroy.
*/
void M_DestroyRenderer(M_Renderer* renderer);

#ifdef __cplusplus
}
#endif