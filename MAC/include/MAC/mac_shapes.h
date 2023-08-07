#ifndef mac_shapes_h_
#define mac_shapes_h_

#include "mac_pixels.h"
#include "mac_internals.h"
#include "mac_view.h"
#include <stdbool.h>

#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

void mac_draw_line(Mac_View* parent_view, Mac_FPoint init_pos, Mac_FPoint end_pos, float line_width, Mac_Color color);

/*
    Rectangle struct and functions
*/
typedef struct 
{
    Mac_FPoint origin;
    MSize size;
    Mac_Color color;
} Mac_Rect;

/*!
    draws a wireframe (not filled) rectangle with the given parameters
    @param rect: the rectangle to draw
    @param line_width: the width of the rectangle's lines
    @param parent_view: the view to draw the rectangle on
*/
void mac_draw_rect(Mac_Rect* rect, float line_width, Mac_View* parent_view);

/*!
    draws a filled rectangle with the given parameters
    @param rect: the rectangle to fill
    @param parent_view: the view to fill the rectangle on
*/
void mac_fill_rect(Mac_Rect* rect, Mac_View* parent_view);

/*!
    creates a rectangle with the given parameters
    @param origin: the origin of the rectangle
    @param size: the size of the rectangle
    @param color: the color of the rectangle
    @return: a pointer to the created rectangle
*/
Mac_Rect* mac_rect(Mac_FPoint origin, MSize size, Mac_Color color);

/*!
    destroys the given rectangle
    @param rect: the rectangle to destroy
*/
void destroy_rect(Mac_Rect* rect);

#ifdef __cplusplus
}
#endif

#endif // mac_shapes_h_