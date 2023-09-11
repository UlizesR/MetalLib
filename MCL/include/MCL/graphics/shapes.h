#ifndef _mcl_shapes_h_
#define _mcl_shapes_h_

#include "renderer.h"
#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_Triangle
{
    MCL_FPoint p1, p2, p3;
    MCL_Color color;
    void *_this;
} MCL_Triangle;

/*!
    * @brief Draws a triangle on the screen.
    * @param renderer The renderer to draw the triangle on.
    * @param triangle The triangle to draw.
    * @param points The points of the triangle.
    * @param color The color of the triangle.
*/
void MCL_DrawTriangle(MCL_Renderer *renderer, MCL_Triangle *triangle, MCL_FPoint *points, MCL_Color color);

#ifdef __cplusplus
}
#endif

#endif