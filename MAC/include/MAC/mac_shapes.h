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

typedef enum {
    MAC_SHAPE_LINE = 0,
    MAC_SHAPE_RECT = 1,
    MAC_SHAPE_CIRCLE = 2,
    MAC_SHAPE_ELLIPSE = 3,
    MAC_SHAPE_TRIANGLE = 4,
    MAC_SHAPE_POLYGON = 5,
} Mac_ShapeType;

typedef struct {
    int shape_type; // 0 for line, 1 for rectangle, etc.
    int id;
    // Add any other common properties here
} Mac_Shape;

typedef struct {
    Mac_Shape base;
    Mac_FPoint origin;
    MSize size;
    Mac_Color color;
} Mac_Rect;

typedef struct {
    Mac_Shape base;
    Mac_FPoint init_pos;
    Mac_FPoint end_pos;
    float line_width;
    Mac_Color color;
} Mac_Line;


/*!
    draws a line with the given parameters
    @param parent_view: the view to draw the line on
    @param init_pos: the initial position of the line
    @param end_pos: the end position of the line
    @param line_width: the width of the line
    @param color: the color of the line
*/

void mac_draw_line(Mac_View* parent_view, Mac_Line* line);

/*!
    creates a line with the given parameters
    @param init_pos: the initial position of the line
    @param end_pos: the end position of the line
    @param line_width: the width of the line
    @param color: the color of the line
    @return: a pointer to the created line
*/
Mac_Line* mac_line(Mac_FPoint init_pos, Mac_FPoint end_pos, float line_width, Mac_Color color);


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
    adds the given rectangle to the given view
    @param shape_id: the id of the rectangle
    @param parent_view: the view to add the rectangle to
*/
void mac_remove_shape(int shape_id, Mac_View* parent_view);

/*!
    destroys the given rectangle
    @param rect: the rectangle to destroy
*/
void destroy_shape(Mac_Shape* shape);

#ifdef __cplusplus
}
#endif

#endif // mac_shapes_h_