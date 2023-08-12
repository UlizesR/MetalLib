#pragma once

#include "mac_colors.h"
#include "mac_defs.h"

#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MAC_SHAPE_POINT         = 0,    // The shape is a point
    MAC_SHAPE_LINE          = 1,    // The shape is a line
    MAC_SHAPE_TRIANGLE      = 2,    // The shape is a triangle
    MAC_SHAPE_QUADRILATERAL = 3,    // The shape is a quadrilateral
    MAC_SHAPE_POLYGON       = 4,    // The shape is a polygon
    MAC_SHAPE_ELLIPSE       = 5,    // The shape is an ellipse
} Mac_ShapeType;

typedef struct {
    int shape_type;             // 0 for line, 1 for rectangle, etc.
    int id;                     // The id of the shape
    MFPoint center_point;       // The center point of the shape
} Mac_Shape;

typedef struct {
    Mac_Shape base;             // The base shape
    MFPoint position;           // The position of the point
    Mac_Color color;            // The color of the point
} Mac_Point;

typedef struct {
    Mac_Shape base;             // The base shape
    MFPoint init_pos;           // The initial position of the line
    MFPoint end_pos;            // The end position of the line
    float line_width;           // The width of the line
    Mac_Color color;            // The color of the line
} Mac_Line;

typedef struct {
    Mac_Shape base;             // The base shape
    MSize size;                 // The size of the rectangle
    MFPoint* vertices;          // The vertices of the rectangle
    int vertex_count;           // The number of vertices of the rectangle: default is 4
    Mac_Color color;            // The color of the rectangle
} Mac_Quadrilateral;

typedef struct {
    Mac_Shape base;             // The base shape
    MFPoint* vertices;          // The vertices of the triangle: default is 3
    int vertex_count;           // The number of vertices of the triangle
    MSize size;                 // The size of the triangle
    Mac_Color color;            // The color of the triangle
} Mac_Triangle;

typedef struct {
    Mac_Shape base;             // The base shape
    MFPoint origin;             // Center of the ellipse
    float radius_x;             // Horizontal radius
    float radius_y;             // Vertical radius
    Mac_Color color;            // The color of the ellipse
} Mac_Ellipse;

typedef struct {
    Mac_Shape base;             // The base shape
    MFPoint* vertices;          // Array of vertices
    int vertex_count;           // Number of vertices
    Mac_Color color;            // The color of the polygon
} Mac_Polygon;

/*!
    creates a point with the given parameters
    @param x: the x position of the point
    @param y: the y position of the point
    @param color: the color of the point
    @return: a pointer to the created point
*/
Mac_Point* MAC_Point(float x, float y, Mac_Color color);

/*!
    draws a point with the given parameters
    @param renderer: the renderer to draw the shape to
    @param point: the point to draw
*/
void MAC_DrawPoint(Mac_Renderer* renderer, Mac_Point* point);

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
    draws a line with the given parameters
    @param renderer: the renderer to draw the shape to
    @param line: the line to draw
*/
void MAC_DrawLine(Mac_Renderer* renderer, Mac_Line* line);

/*!
    creates a quadrilateral with the given parameters
    @param vertices: the vertices of the quadrilateral
    @param color: the color of the quadrilateral
    @return: a pointer to the created quadrilateral
*/
Mac_Quadrilateral* MAC_Quadrilateral(MFPoint* vertices, Mac_Color color);

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
    creates a triangle with the given parameters
    @param vertices: the vertices of the triangle
    @param color: the color of the triangle
    @return: a pointer to the created triangle
*/
Mac_Triangle* MAC_Triangle(MFPoint* vertices, Mac_Color color);

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
void MAC_DrawPolygon(Mac_Polygon* polygon, float line_width, Mac_Renderer* renderer);

/*!
    draws a filled ellipse with the given parameters
    @param ellipse: the ellipse to fill
    @param renderer: the renderer to draw the shape to
*/
void MAC_FillPolygon(Mac_Polygon* polygon, Mac_Renderer* renderer);

/*!
    creates an ellipse with the given parameters, if the radius_x and radius_y are equal, the ellipse will be a circle
    @param origin: the origin of the ellipse
    @param radius_x: the horizontal radius of the ellipse
    @param radius_y: the vertical radius of the ellipse
    @param color: the color of the ellipse
    @return: a pointer to the created ellipse
*/
Mac_Ellipse* MAC_Ellipse(MFPoint origin, float radius_x, float radius_y, Mac_Color color);

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
    removes a given shape from the given view
    sets the shape count to 1 less
    @param shape_id: the id of the shape
    @param renderer: the renderer to draw the shape to
*/
void MAC_RemoveShape(int shape_id, Mac_Renderer* renderer);

/*!
    removes all shapes from the given view
    sets the shape count to 0
    @param renderer: the renderer to draw the shape to
*/
void MAC_RemoveAllShapes(Mac_Renderer* renderer);

/*!
    destroys the given shape
    @param shape: the shape to destroy
*/
void MAC_DestroyShape(Mac_Shape* shape);

#ifdef __cplusplus
}
#endif