#ifndef mac_shapes_h_
#define mac_shapes_h_

#include "mac_colors.h"
#include "mac_defs.h"

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
    MAC_SHAPE_QUADRILATERAL = 7,
} Mac_ShapeType;

typedef struct {
    int shape_type; // 0 for line, 1 for rectangle, etc.
    int id;
    MFPoint center_point;
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
    MFPoint* vertices;
    int vertex_count;
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
    MFPoint origin; // Center of the ellipse
    float radius_x; // Horizontal radius
    float radius_y; // Vertical radius
    Mac_Color color;
} Mac_Ellipse;

typedef struct {
    Mac_Shape base;
    MFPoint* vertices; // Array of vertices
    int vertex_count;  // Number of vertices
    Mac_Color color;
} Mac_Polygon;

typedef struct {
    Mac_Shape base;
    MFPoint vertices[4]; // Four vertices of the quadrilateral
    Mac_Color color;
} Mac_Quadrilateral;

/*!
    draws a point with the given parameters
    @param renderer: the renderer to draw the shape to
    @param point: the point to draw
*/
void MAC_DrawPoint(Mac_Renderer* renderer, Mac_Point* point);

/*!
    creates a point with the given parameters
    @param x: the x position of the point
    @param y: the y position of the point
    @param color: the color of the point
    @return: a pointer to the created point
*/
Mac_Point* MAC_Point(float x, float y, Mac_Color color);

/*!
    draws a line with the given parameters
    @param renderer: the renderer to draw the shape to
    @param line: the line to draw
*/

void MAC_DrawLine(Mac_Renderer* renderer, Mac_Line* line);

/*!
    creates a line with the given parameters
    @param init_pos: the initial position of the line
    @param end_pos: the end position of the line
    @param line_width: the width of the line
    @param color: the color of the line
    @return: a pointer to the created line
*/
Mac_Line* MAC_Line(MFPoint init_pos, MFPoint end_pos, float line_width, Mac_Color color);


/*!
    draws a wireframe (not filled) rectangle with the given parameters
    @param rect: the rectangle to draw
    @param line_width: the width of the rectangle's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawRect(Mac_Rect* rect, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled rectangle with the given parameters
    @param rect: the rectangle to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillRect(Mac_Rect* rect, Mac_Renderer* renderer);

/*!
    creates a rectangle with the given parameters
    @param origin: the origin of the rectangle
    @param size: the size of the rectangle
    @param color: the color of the rectangle
    @return: a pointer to the created rectangle
*/
Mac_Rect* MAC_Rect(MFPoint origin, MSize size, Mac_Color color);

/*
    draws a wireframe (not filled) triangle with the given parameters
    @param triangle: the triangle to draw
    @param line_width: the width of the triangle's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawTriangle(Mac_Triangle* triangle, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled triangle with the given parameters
    @param triangle: the triangle to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillTriangle(Mac_Triangle* triangle, Mac_Renderer* renderer);

/*!
    creates a triangle with the given parameters
    @param p1: the first point of the triangle
    @param p2: the second point of the triangle
    @param p3: the third point of the triangle
    @param color: the color of the triangle
    @return: a pointer to the created triangle
*/
Mac_Triangle* MAC_Triangle(MFPoint p1, MFPoint p2, MFPoint p3, Mac_Color color);

/*!
    draws a wireframe (not filled) circle with the given parameters
    @param circle: the circle to draw
    @param line_width: the width of the circle's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawCircle(Mac_Circle* circle, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled circle with the given parameters
    @param circle: the circle to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillCircle(Mac_Circle* circle, Mac_Renderer* renderer);

/*!
    creates a circle with the given parameters
    @param origin: the origin of the circle
    @param radius: the radius of the circle
    @param color: the color of the circle
    @return: a pointer to the created circle
*/
Mac_Circle* MAC_Circle(MFPoint origin, float radius, Mac_Color color);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawPolygon(Mac_Polygon* polygon, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled ellipse with the given parameters
    @param ellipse: the ellipse to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillPolygon(Mac_Polygon* polygon, Mac_Renderer* renderer);

/*!
    creates a polygon with the given parameters
    @param vertices: the vertices of the polygon
    @param vertex_count: the number of vertices of the polygon
    @param color: the color of the polygon
    @return: a pointer to the created polygon
*/
Mac_Polygon* MAC_Polygon(MFPoint* vertices, int vertex_count, Mac_Color color);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawEllipse(Mac_Ellipse* ellipse, float line_width, Mac_Renderer* renderer);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillEllipse(Mac_Ellipse* ellipse, Mac_Renderer* renderer);

/*!
    creates an ellipse with the given parameters
    @param origin: the origin of the ellipse
    @param radius_x: the horizontal radius of the ellipse
    @param radius_y: the vertical radius of the ellipse
    @param color: the color of the ellipse
    @return: a pointer to the created ellipse
*/
Mac_Ellipse* MAC_Ellipse(MFPoint origin, float radius_x, float radius_y, Mac_Color color);

/*!
    draws a wireframe (not filled) quadrilateral with the given parameters
    @param quad: the quadrilateral to draw
    @param line_width: the width of the quadrilateral's lines
    @param renderer: the renderer to draw the shape to
*/
void MAC_DrawQuadrilateral(Mac_Quadrilateral* quad, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled quadrilateral with the given parameters
    @param quad: the quadrilateral to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillQuadrilateral(Mac_Quadrilateral* quad, Mac_Renderer* renderer);

/*!
    creates a quadrilateral with the given parameters
    @param vertices: the vertices of the quadrilateral
    @param color: the color of the quadrilateral
    @return: a pointer to the created quadrilateral
*/
Mac_Quadrilateral* MAC_Quadrilateral(MFPoint vertices[4], Mac_Color color);

/*!
    removes a given shape from the given view
    @param shape_id: the id of the rectangle
    @param renderer: the renderer to draw the shape to
*/
void MAC_RemoveShape(int shape_id, Mac_Renderer* renderer);

/*!
    removes all shapes from the given view
    @param renderer: the renderer to draw the shape to
*/
void MAC_RemoveAllShapes(Mac_Renderer* renderer);

/*!
    destroys the given rectangle
    @param rect: the rectangle to destroy
*/
void MAC_DestroyShape(Mac_Shape* shape);

#ifdef __cplusplus
}
#endif

#endif // mac_shapes_h_