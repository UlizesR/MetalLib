#include "MACA/mac_colors.h"
#include "MACA/mac_renderer.h"
#include "MACA/mac_shapes.h"
#include "MACA/mac_view.h"
#include "MACA/mac_window.h"

#include <MacTypes.h>
#include <stdio.h>
#include <stdlib.h>

Mac_Renderer* MAC_CreateRenderer(Mac_RendererType type, Mac_View* view_to_render)
{
    if (view_to_render == NULL)
    {
        printf("ERROR: View to render is NULL.\n");
        return NULL;
    }

    Mac_Renderer* renderer = (Mac_Renderer*)malloc(sizeof(Mac_Renderer));
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

    if (type == MAC_RENDERER_CORE_G)
    {
        if (!(view_to_render->type & MAC_VIEW_TYPE_CORE_G))
        {
            printf("ERROR: View is not a core graphics view.\n");
            free(renderer->render_view);
            free(renderer);
            return NULL;
        }
        renderer->render_view->rview = &view_to_render->view.r_view;
    }
    else if (type == MAC_RENDERER_METAL)
    {
        if (!(view_to_render->type & MAC_VIEW_TYPE_METAL))
        {
            printf("ERROR: View is not a metal view.\n");
            free(renderer->render_view);
            free(renderer);
            return NULL;
        }
        renderer->render_view->mview = &view_to_render->view.m_view;
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

void MAC_CreateWindowAndRenderer(int width, int height, MTitle title, Mac_RendererType type, UInt32 flags, Mac_Window** window, Mac_Renderer** renderer)
{
    if (window == NULL || renderer == NULL)
    {
        printf("ERROR: Window or renderer pointer is NULL.\n");
        return;
    }

    *window = MAC_CreateWindow(width, height, true, title, flags);
    if (!*window)
    {
        printf("ERROR: Could not create window.\n");
        return;
    }

    UInt32 view_type;
    if (type == MAC_RENDERER_CORE_G)
        view_type = MAC_VIEW_TYPE_CORE_G;
    else if (type == MAC_RENDERER_METAL)
        view_type = MAC_VIEW_TYPE_METAL;
    else
    {
        printf("ERROR: Unsupported renderer type.\n");
        MAC_DestroyWindow(*window);
        return;
    }

    (*window)->content_view = MAC_AddContentView(*window, MAC_COLOR_TRANSPARENT, view_type, NULL);
    if (!(*window)->content_view)
    {
        printf("ERROR: Could not add content view.\n");
        MAC_DestroyWindow(*window);
        return;
    }

    *renderer = MAC_CreateRenderer(type, (*window)->content_view);
    if (!*renderer)
    {
        printf("ERROR: Could not create renderer.\n");
        MAC_DestroyContentView((*window)->content_view); // Cleanup content view
        MAC_DestroyWindow(*window);
        return;
    }
}

void MAC_SetRendererColor(Mac_Renderer* renderer, Mac_Color color)
{
    if (!renderer)
    {
        printf("ERROR: Renderer pointer is NULL.\n");
        return;
    }

    Mac_View view_to_change;

    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        view_to_change.view.r_view = *renderer->render_view->rview;
        view_to_change.type = MAC_VIEW_TYPE_CORE_G;
    }
    else if (renderer->type == MAC_RENDERER_METAL)
    {
        view_to_change.view.m_view = *renderer->render_view->mview;
        view_to_change.type = MAC_VIEW_TYPE_METAL;
    }
    else
    {
        printf("ERROR: Unsupported renderer type.\n");
        return;
    }

    MAC_ChangeViewBGColor(&view_to_change, color);
}

void MAC_ClearRenderer(Mac_Renderer* renderer) {
    if (!renderer)
    {
        printf("ERROR: Renderer pointer is NULL.\n");
        return;
    }
    MAC_RemoveAllShapes(renderer);
    Mac_View view_to_change;
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        view_to_change.view.r_view = *renderer->render_view->rview;
        view_to_change.type = MAC_VIEW_TYPE_CORE_G;
    }
    else if (renderer->type == MAC_RENDERER_METAL)
    {
        view_to_change.view.m_view = *renderer->render_view->mview;
        view_to_change.type = MAC_VIEW_TYPE_METAL;
    }
    else
    {
        printf("ERROR: Unsupported renderer type.\n");
        return;
    }
    MAC_ChangeViewBGColor(&view_to_change, MAC_COLOR_TRANSPARENT);
}


void MAC_DestroyRenderer(Mac_Renderer* renderer)
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
