#ifndef mac_shapes_h_
#define mac_shapes_h_

#include "mac_pixels.h"
#include "mac_internals.h"
#include <stdbool.h>

#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MAC_SHAPE_LINE      = 0,
    MAC_SHAPE_RECT      = 1,
    MAC_SHAPE_CIRCLE    = 2,
    MAC_SHAPE_ELLIPSE   = 3,
    MAC_SHAPE_TRIANGLE  = 4,
    MAC_SHAPE_POLYGON   = 5,
    MAC_SHAPE_POINT     = 6,
} Mac_ShapeType;

typedef struct {
    int shape_type; // 0 for line, 1 for rectangle, etc.
    int id;
    // Add any other common properties here
} Mac_Shape;

typedef struct {
    Mac_Shape base;
    MFPoint position;
    Mac_Color color;
} Mac_Point;

typedef struct {
    Mac_Shape base;
    MFPoint init_pos;
    MFPoint end_pos;
    float line_width;
    Mac_Color color;
} Mac_Line;

typedef struct {
    Mac_Shape base;
    MSize size;
    MFPoint p_tr, p_tl, p_br, origin;
    Mac_Color color;
} Mac_Rect;

typedef struct {
    Mac_Shape base;
    MFPoint p1;
    MFPoint p2;
    MFPoint p3;
    MSize size;
    Mac_Color color;
} Mac_Triangle;

typedef struct {
    Mac_Shape base;
    MFPoint origin;
    float radius;
    Mac_Color color;
} Mac_Circle;

typedef struct {
    Mac_Shape base;
    MFPoint* vertices; // Array of vertices
    int vertex_count;  // Number of vertices
    Mac_Color color;
} Mac_Polygon;


/*!
    draws a point with the given parameters
    @param parent_view: the view to draw the point on
    @param point: the point to draw
*/
void mac_draw_point(Mac_View* parent_view, Mac_Point* point);

/*!
    creates a point with the given parameters
    @param x: the x position of the point
    @param y: the y position of the point
    @param color: the color of the point
    @return: a pointer to the created point
*/
Mac_Point* mac_point(float x, float y, Mac_Color color);

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
Mac_Line* mac_line(MFPoint init_pos, MFPoint end_pos, float line_width, Mac_Color color);


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
Mac_Rect* mac_rect(MFPoint origin, MSize size, Mac_Color color);

/*
    draws a wireframe (not filled) triangle with the given parameters
    @param triangle: the triangle to draw
    @param line_width: the width of the triangle's lines
    @param parent_view: the view to draw the triangle on
*/
void mac_draw_triangle(Mac_Triangle* triangle, float line_width, Mac_View* parent_view);

/*!
    draws a filled triangle with the given parameters
    @param triangle: the triangle to fill
    @param parent_view: the view to fill the triangle on
*/
void mac_fill_triangle(Mac_Triangle* triangle, Mac_View* parent_view);

/*!
    creates a triangle with the given parameters
    @param p1: the first point of the triangle
    @param p2: the second point of the triangle
    @param p3: the third point of the triangle
    @param color: the color of the triangle
    @return: a pointer to the created triangle
*/
Mac_Triangle* mac_triangle(MFPoint p1, MFPoint p2, MFPoint p3, Mac_Color color);

/*!
    draws a wireframe (not filled) circle with the given parameters
    @param circle: the circle to draw
    @param line_width: the width of the circle's lines
    @param parent_view: the view to draw the circle on
*/
void mac_draw_circle(Mac_Circle* circle, float line_width, Mac_View* parent_view);

/*!
    draws a filled circle with the given parameters
    @param circle: the circle to fill
    @param parent_view: the view to fill the circle on
*/
void mac_fill_circle(Mac_Circle* circle, Mac_View* parent_view);

/*!
    creates a circle with the given parameters
    @param origin: the origin of the circle
    @param radius: the radius of the circle
    @param color: the color of the circle
    @return: a pointer to the created circle
*/
Mac_Circle* mac_circle(MFPoint origin, float radius, Mac_Color color);

void mac_draw_polygon(Mac_Polygon* polygon, float line_width, Mac_View* parent_view);

void mac_fill_polygon(Mac_Polygon* polygon, Mac_View* parent_view);

Mac_Polygon* mac_polygon(MFPoint* vertices, int vertex_count, Mac_Color color);


/*!
    removes a given shape from the given view
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