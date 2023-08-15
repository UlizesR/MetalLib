#include "MACA/mac_colors.h"
#include "MACA/mac_renderer.h"
#include "MACA/mac_shapes.h"
#include "MACA/mac_view.h"
#include "MACA/mac_window.h"
#include "MACA/mac_metal.h"

#include <MacTypes.h>
#include <stdio.h>
#include <stdlib.h>

M_Renderer* M_CreateRenderer(M_RendererType type, M_View* view_to_render)
{
    if (view_to_render == NULL)
    {
        printf("ERROR: View to render is NULL.\n");
        return NULL;
    }

    M_Renderer* renderer = (M_Renderer*)malloc(sizeof(M_Renderer));
    if (!renderer)
    {
        printf("ERROR: Could not allocate memory for renderer.\n");
        return NULL;
    }

    renderer->type = type;
    renderer->render_view = (URView*)malloc(sizeof(URView));
    if (!renderer->render_view)
    {
        printf("ERROR: Could not allocate memory for render view.\n");
        free(renderer);
        return NULL;
    }

    if (type == M_RENDERER_CORE_G)
    {
        if (!(view_to_render->type & M_VIEW_TYPE_CORE_G))
        {
            printf("ERROR: View is not a core graphics view.\n");
            free(renderer->render_view);
            free(renderer);
            return NULL;
        }
        renderer->render_view->rview = &view_to_render->view.r_view;
    }
    else if (type == M_RENDERER_METAL)
    {
        if (!(view_to_render->type & M_VIEW_TYPE_METAL))
        {
            printf("ERROR: View is not a metal view.\n");
            free(renderer->render_view);
            free(renderer);
            return NULL;
        }
        renderer->render_view->mview = &view_to_render->view.m_view;
        M_InitMetalRenderer(renderer);
    }
    else
    {
        printf("ERROR: Unsupported renderer type.\n");
        free(renderer->render_view);
        free(renderer);
        return NULL;
    }

    renderer->is_init = true;
    return renderer;
}

void M_CreateWindowAndRenderer(int width, int height, MTitle title, M_RendererType type, UInt32 flags, M_Window** window, M_Renderer** renderer)
{
    if (window == NULL || renderer == NULL)
    {
        printf("ERROR: Window or renderer pointer is NULL.\n");
        return;
    }

    *window = M_CreateWindow(width, height, true, title, flags);
    if (!*window)
    {
        printf("ERROR: Could not create window.\n");
        return;
    }

    UInt32 view_type;
    if (type == M_RENDERER_CORE_G)
        view_type = M_VIEW_TYPE_CORE_G;
    else if (type == M_RENDERER_METAL)
        view_type = M_VIEW_TYPE_METAL;
    else
    {
        printf("ERROR: Unsupported renderer type.\n");
        M_DestroyWindow(*window);
        return;
    }

    (*window)->content_view = M_AddContentView(*window, M_COLOR_TRANSPARENT, view_type, NULL);
    if (!(*window)->content_view)
    {
        printf("ERROR: Could not add content view.\n");
        M_DestroyWindow(*window);
        return;
    }

    *renderer = M_CreateRenderer(type, (*window)->content_view);
    if (!*renderer)
    {
        printf("ERROR: Could not create renderer.\n");
        M_DestroyContentView((*window)->content_view); // Cleanup content view
        M_DestroyWindow(*window);
        return;
    }
}

// Helper function to set up view_to_change
static void M_SetupViewToChange(M_Renderer* renderer, M_View* view_to_change) {
    if (renderer->type == M_RENDERER_CORE_G) {
        view_to_change->view.r_view = *renderer->render_view->rview;
        view_to_change->type = M_VIEW_TYPE_CORE_G;
    } else if (renderer->type == M_RENDERER_METAL) {
        view_to_change->view.m_view = *renderer->render_view->mview;
        view_to_change->type = M_VIEW_TYPE_METAL;
    } else {
        printf("ERROR: Unsupported renderer type.\n");
        return;
    }
}

void M_SetRendererColor(M_Renderer* renderer, M_Color color) {
    if (!renderer) {
        printf("ERROR: Renderer pointer is NULL.\n");
        return;
    }

    M_View view_to_change;
    M_SetupViewToChange(renderer, &view_to_change);

    if (renderer->type == M_RENDERER_METAL)
        M_SetBackgroundColorMTKView(renderer, color);
    else 
        M_ChangeViewBGColor(&view_to_change, color);
}

void M_ClearRenderer(M_Renderer* renderer) {
    if (!renderer) {
        printf("ERROR: Renderer pointer is NULL.\n");
        return;
    }

    M_RemoveAllShapes(renderer);
    M_View view_to_change;
    M_SetupViewToChange(renderer, &view_to_change);

    if (renderer->type == M_RENDERER_METAL)
        M_ClearMTKView(renderer);
    else
        M_ChangeViewBGColor(&view_to_change, M_COLOR_TRANSPARENT);
}

void M_DestroyRenderer(M_Renderer* renderer)
{
    if (!renderer)
    {
        printf("ERROR: Renderer pointer is NULL.\n");
        return;
    }

    // Free the render view
    if (renderer->render_view)
    {
        free(renderer->render_view);
    }

    // Free the renderer itself
    free(renderer);
}
