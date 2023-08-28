#pragma once

#include "colors.h"
#include "defs.h"

#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    M_SHAPE_POINT         = 0,    // The shape is a point
    M_SHAPE_LINE          = 1,    // The shape is a line
    M_SHAPE_TRIANGLE      = 2,    // The shape is a triangle
    M_SHAPE_QUADRILATERAL = 3,    // The shape is a quadrilateral
    M_SHAPE_POLYGON       = 4,    // The shape is a polygon
    M_SHAPE_ELLIPSE       = 5,    // The shape is an ellipse
} M_ShapeType;

typedef struct {
    int shape_type;             // 0 for line, 1 for rectangle, etc.
    int id;                     // The id of the shape
    MFPoint center_point;       // The center point of the shape
} M_Shape;

typedef struct {
    M_Shape base;             // The base shape
    MFPoint position;           // The position of the point
    M_Color color;            // The color of the point
} M_Point;

typedef struct {
    M_Shape base;             // The base shape
    MFPoint init_pos;           // The initial position of the line
    MFPoint end_pos;            // The end position of the line
    float line_width;           // The width of the line
    M_Color color;            // The color of the line
} M_Line;

typedef struct {
    M_Shape base;             // The base shape
    MSize size;                 // The size of the rectangle
    MFPoint* vertices;          // The vertices of the rectangle
    int vertex_count;           // The number of vertices of the rectangle: default is 4
    M_Color color;            // The color of the rectangle
} M_Quadrilateral;

typedef struct {
    M_Shape base;             // The base shape
    MFPoint* vertices;          // The vertices of the triangle: default is 3
    int vertex_count;           // The number of vertices of the triangle
    MSize size;                 // The size of the triangle
    M_Color color;            // The color of the triangle
} M_Triangle;

typedef struct {
    M_Shape base;             // The base shape
    MFPoint origin;             // Center of the ellipse
    float radius_x;             // Horizontal radius
    float radius_y;             // Vertical radius
    M_Color color;            // The color of the ellipse
} M_Ellipse;

typedef struct {
    M_Shape base;             // The base shape
    MFPoint* vertices;          // Array of vertices
    int vertex_count;           // Number of vertices
    M_Color color;            // The color of the polygon
} M_Polygon;

/*!
    creates a point with the given parameters
    @param x: the x position of the point
    @param y: the y position of the point
    @param color: the color of the point
    @return: a pointer to the created point
*/
M_Point* M_CreatePoint(float x, float y, M_Color color);

/*!
    draws a point with the given parameters
    @param point: the point to draw
*/
void M_DrawPoint(M_View *p_view, M_Point* point);

/*!
    creates a line with the given parameters
    @param init_pos: the initial position of the line
    @param end_pos: the end position of the line
    @param line_width: the width of the line
    @param color: the color of the line
    @return: a pointer to the created line
*/
M_Line* M_CreateLine(MFPoint init_pos, MFPoint end_pos, float line_width, M_Color color);

/*!
    draws a line with the given parameters
    @param line: the line to draw
*/
void M_DrawLine(M_View *p_view, M_Line *line);

/*!
    creates a quadrilateral with the given parameters
    @param vertices: the vertices of the quadrilateral
    @param color: the color of the quadrilateral
    @return: a pointer to the created quadrilateral
*/
M_Quadrilateral* M_CreateQuadrilateral(MFPoint* vertices, M_Color color);

/*!
    draws a wireframe (not filled) quadrilateral with the given parameters
    @param quad: the quadrilateral to draw
    @param line_width: the width of the quadrilateral's lines
*/
void M_DrawQuadrilateral(M_View *p_view, M_Quadrilateral *quad,
                         float line_width);

/*!
    draws a filled quadrilateral with the given parameters
    @param quad: the quadrilateral to fill
*/
void M_FillQuadrilateral(M_View *p_view, M_Quadrilateral *quad);

/*!
    creates a triangle with the given parameters
    @param vertices: the vertices of the triangle
    @param color: the color of the triangle
    @return: a pointer to the created triangle
*/
M_Triangle* M_CreateTriangle(MFPoint* vertices, M_Color color);

/*
    draws a wireframe (not filled) triangle with the given parameters
    @param triangle: the triangle to draw
    @param line_width: the width of the triangle's lines
*/
void M_DrawTriangle(M_View *p_view, M_Triangle *triangle, float line_width);

/*!
    draws a filled triangle with the given parameters
    @param triangle: the triangle to fill
*/
void M_FillTriangle(M_View *p_view, M_Triangle *triangle);

/*!
    creates a polygon with the given parameters
    @param vertices: the vertices of the polygon
    @param vertex_count: the number of vertices of the polygon
    @param color: the color of the polygon
    @return: a pointer to the created polygon
*/
M_Polygon* M_CreatePolygon(MFPoint* vertices, int vertex_count, M_Color color);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
*/
void M_DrawPolygon(M_View *p_view, M_Polygon *polygon, float line_width);

/*!
    draws a filled ellipse with the given parameters
    @param ellipse: the ellipse to fill
*/
void M_FillPolygon(M_View *p_view, M_Polygon *polygon);

/*!
    creates an ellipse with the given parameters, if the radius_x and radius_y are equal, the ellipse will be a circle
    @param origin: the origin of the ellipse
    @param radius_x: the horizontal radius of the ellipse
    @param radius_y: the vertical radius of the ellipse
    @param color: the color of the ellipse
    @return: a pointer to the created ellipse
*/
M_Ellipse* M_CreateEllipse(MFPoint origin, float radius_x, float radius_y, M_Color color);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
*/
void M_DrawEllipse(M_View *p_view, M_Ellipse *ellipse, float line_width);

/*!
    draws a wireframe (not filled) ellipse with the given parameters
    @param ellipse: the ellipse to draw
    @param line_width: the width of the ellipse's lines
*/
void M_FillEllipse(M_View *p_view, M_Ellipse *ellipse);

/*!
    removes a given shape from the given view
    sets the shape count to 1 less
    @param shape_id: the id of the shape
*/
void M_RemoveShape(M_View *p_view, int shape_id);

/*!
    removes all shapes from the given view
    sets the shape count to 0
*/
void M_RemoveAllShapes(M_View *p_view);

/*!
    destroys the given shape
    @param shape: the shape to destroy
*/
void M_DestroyShape(M_Shape* shape);

#ifdef __cplusplus
}
#endif