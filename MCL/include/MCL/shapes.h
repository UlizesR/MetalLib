#pragma once

#include "colors.h"
#include "defs.h"

#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  M_SHAPE_POINT = 0,         // The shape is a point
  M_SHAPE_LINE = 1,          // The shape is a line
  M_SHAPE_TRIANGLE = 2,      // The shape is a triangle
  M_SHAPE_QUADRILATERAL = 3, // The shape is a quadrilateral
  M_SHAPE_POLYGON = 4,       // The shape is a polygon
  M_SHAPE_ELLIPSE = 5,       // The shape is an ellipse
} M_ShapeType;

typedef struct {
  int shape_type;       // 0 for line, 1 for rectangle, etc.
  int id;               // The id of the shape
  MFPoint center_point; // The center point of the shape
} M_Shape;

typedef struct {
  M_Shape base;     // The base shape
  MFPoint position; // The position of the point
  M_Color color;    // The color of the point
} M_Point;

typedef struct {
  M_Shape base;     // The base shape
  MFPoint init_pos; // The initial position of the line
  MFPoint end_pos;  // The end position of the line
  float line_width; // The width of the line
  M_Color color;    // The color of the line
} M_Line;

typedef struct {
  M_Shape base;      // The base shape
  MSize size;        // The size of the rectangle
  MFPoint *vertices; // The vertices of the rectangle
  int vertex_count;  // The number of vertices of the rectangle: default is 4
  M_Color color;     // The color of the rectangle
} M_Quadrilateral;

typedef struct {
  M_Shape base;      // The base shape
  MFPoint *vertices; // The vertices of the triangle: default is 3
  int vertex_count;  // The number of vertices of the triangle
  MSize size;        // The size of the triangle
  M_Color color;     // The color of the triangle
} M_Triangle;

typedef struct {
  M_Shape base;   // The base shape
  MFPoint origin; // Center of the ellipse
  float radius_x; // Horizontal radius
  float radius_y; // Vertical radius
  M_Color color;  // The color of the ellipse
} M_Ellipse;

typedef struct {
  M_Shape base;      // The base shape
  MFPoint *vertices; // Array of vertices
  int vertex_count;  // Number of vertices
  M_Color color;     // The color of the polygon
} M_Polygon;

#ifdef __cplusplus
}
#endif