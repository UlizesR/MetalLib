#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

#include "defs.h"
#import "view.h"
#import "shapes.h"

int shapeID = 0;

DrawableShape* createDrawableShape(CGMutablePathRef path, M_Color color, BOOL filled, int shape_id) {
    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = color;
    shape.filled = filled;
    shape.id = shape_id;
    return shape;
}

// Function to add a DrawableShape object to the view
void addShapeToView(M_NSView* nsView, DrawableShape* shape) {
    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    [nsView setNeedsDisplay:YES];
}

// Function to remove a shape by ID
void removeShapeByID(M_NSView* nsView, int shape_id) {
    NSMutableArray<DrawableShape*>* shapesToRemove = [NSMutableArray array];
    for (DrawableShape* shape in nsView.shapes) {
        if (shape.id == shape_id) {
            [shapesToRemove addObject:shape];
        }
    }
    if (shapesToRemove.count > 0) {
        [nsView.shapes removeObjectsInArray:shapesToRemove];
        [nsView setNeedsDisplay:YES];
    }
}


M_Point* M_CreatePoint(float x, float y, M_Color color)
{
    // Allocate memory for point
    M_Point* point = (M_Point*)malloc(sizeof(M_Point));
    // Check if memory was allocated
    if (!point) 
    {
        printf("ERROR: Could not allocate memory for point.\n");
        return NULL;
    }
    // Set point properties
    point->position.x = x;
    point->position.y = y;
    point->color = color;
    point->base.id = shapeID++;
    point->base.center_point = point->position;
    point->base.shape_type = M_SHAPE_POINT; 
    // Return point
    return point;
}

void M_DrawPoint(M_View *p_view, M_Point *point) {
    // Check if point is NULL
    if (!point) {
        printf("ERROR: point is NULL.\n");
        return;
    }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the point
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSetRGBFillColor(context, point->color.r, point->color.g,point->color.b, point->color.a);
    CGContextFillRect(context, CGRectMake(point->position.x, point->position.y, 1, 1));
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

M_Line* M_CreateLine(MFPoint init_pos, MFPoint end_pos, float line_width, M_Color color)
{
    // Allocate memory for line
    M_Line* line = (M_Line*)malloc(sizeof(M_Line));
    // Check if memory was allocated
    if (!line) 
    {
        printf("ERROR: Could not allocate memory for line.\n");
        return NULL;
    }
    // Set line properties
    line->init_pos = init_pos;
    line->end_pos = end_pos;
    line->line_width = line_width;
    line->color = color;
    line->base.id = shapeID++;
    line->base.center_point.x = (init_pos.x + end_pos.x) / 2;
    line->base.center_point.y = (init_pos.y + end_pos.y) / 2;
    line->base.shape_type = M_SHAPE_LINE;
    // Return line
    return line;
}

void M_DrawLine(M_View *p_view, M_Line *line) {
  // Check if line is NULL
  if (!line) {
    printf("ERROR: line is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Create the path for the line
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, line->init_pos.x, line->init_pos.y);
    CGPathAddLineToPoint(path, NULL, line->end_pos.x, line->end_pos.y);
    // Create the shape
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path; // Set the path
    shape.color = line->color;
    shape.filled = NO;
    shape.id = line->base.id;
    // Add the shape to the view
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setLineWithInitPos:line->init_pos
                        endPos:line->end_pos
                     lineWidth:line->line_width
                       shapeID:line->base.id
                         color:line->color];
    // Release the path since it's retained by the DrawableShape
    CGPathRelease(path);
}

M_Quadrilateral* M_CreateQuadrilateral(MFPoint* vertices, M_Color color)
{
    // Allocate memory for quadrilateral
    M_Quadrilateral* quad = (M_Quadrilateral*)malloc(sizeof(M_Quadrilateral));
    // Check if memory was allocated
    if (!quad) 
    {
        printf("ERROR: Could not allocate memory for quadrilateral.\n");
        return NULL;
    }
    // check if if the quad is a rectangle
    if (vertices[0].x == vertices[1].x && vertices[1].y == vertices[2].y && vertices[2].x == vertices[3].x && vertices[3].y == vertices[0].y)
    {
        // set the size of the rectangle
        quad->size.width = vertices[1].x - vertices[0].x;
        quad->size.height = vertices[2].y - vertices[1].y;
        // set the center point of the rectangle
        quad->base.center_point.x = vertices[0].x + (float)quad->size.width / 2;
        quad->base.center_point.y = vertices[0].y + (float)quad->size.height / 2;
    } else {
        // set the center point of the quadrilateral
        quad->base.center_point.x = (vertices[0].x + vertices[1].x + vertices[2].x + vertices[3].x) / 4;
        quad->base.center_point.y = (vertices[0].y + vertices[1].y + vertices[2].y + vertices[3].y) / 4;
        // set the size of the quadrilateral
        quad->size = (MSize){0, 0};
    }
    // Set quadrilateral properties
    quad->vertex_count = 4;
    quad->vertices = (MFPoint*)malloc(sizeof(MFPoint) * quad->vertex_count);
    quad->vertices[0] = vertices[0];
    quad->vertices[1] = vertices[1];
    quad->vertices[2] = vertices[2];
    quad->vertices[3] = vertices[3];
    quad->color = color;
    quad->base.id = shapeID++;
    
    quad->base.shape_type = M_SHAPE_QUADRILATERAL;
    // Return quadrilateral
    return quad;
}

void M_DrawQuadrilateral(M_View *p_view, M_Quadrilateral *quad,
                         float line_width) {
  // Check if quadrilateral is NULL
  if (!quad) {
    printf("ERROR: Quadrilateral is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the quadrilateral
    [nsView setLineWithInitPos:quad->vertices[0]
                        endPos:quad->vertices[1]
                     lineWidth:line_width
                       shapeID:quad->base.id
                         color:quad->color];
    [nsView setLineWithInitPos:quad->vertices[1]
                        endPos:quad->vertices[2]
                     lineWidth:line_width
                       shapeID:quad->base.id
                         color:quad->color];
    [nsView setLineWithInitPos:quad->vertices[2]
                        endPos:quad->vertices[3]
                     lineWidth:line_width
                       shapeID:quad->base.id
                         color:quad->color];
    [nsView setLineWithInitPos:quad->vertices[3]
                        endPos:quad->vertices[0]
                     lineWidth:line_width
                       shapeID:quad->base.id
                         color:quad->color];
    // set shape path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, quad->vertices[0].x, quad->vertices[0].y);
    CGPathAddLineToPoint(path, NULL, quad->vertices[1].x, quad->vertices[1].y);
    CGPathAddLineToPoint(path, NULL, quad->vertices[2].x, quad->vertices[2].y);
    CGPathAddLineToPoint(path, NULL, quad->vertices[3].x, quad->vertices[3].y);
    CGPathCloseSubpath(path); // Close the path to form a quadangle
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = quad->color;
    shape.filled = NO;
    shape.id = quad->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void M_FillQuadrilateral(M_View *p_view, M_Quadrilateral *quad) {
  // Check if quadrilateral is NULL
  if (!quad) {
    printf("ERROR: Quadrilateral is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the quadrilateral
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL,
                  CGRectMake(quad->vertices[0].x, quad->vertices[0].y,
                             quad->size.width, quad->size.height));
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = quad->color;
    shape.filled = YES;
    shape.id = quad->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

M_Triangle* M_CreateTriangle(MFPoint* vertices, M_Color color)
{
    // Allocate memory for triangle
    M_Triangle* triangle = (M_Triangle*)malloc(sizeof(M_Triangle));
    // Check if memory was allocated
    if (!triangle) 
    {
        printf("ERROR: Could not allocate memory for triangle.\n");
        return NULL;
    }
    // Set triangle properties
    triangle->vertex_count = 3;
    triangle->vertices = (MFPoint*)malloc(sizeof(MFPoint) * triangle->vertex_count); // Allocate memory for vertices
    triangle->vertices[0] = vertices[0];
    triangle->vertices[1] = vertices[1];
    triangle->vertices[2] = vertices[2];
    triangle->color = color;
    triangle->base.id = shapeID++;
    triangle->base.center_point.x = (vertices[0].x + vertices[1].x + vertices[2].x) / 3;
    triangle->base.center_point.y = (vertices[0].y + vertices[1].y + vertices[2].y) / 3;
    triangle->base.shape_type = M_SHAPE_TRIANGLE;
    // Return triangle
    return triangle;
}

void M_DrawTriangle(M_View *p_view, M_Triangle *triangle, float line_width) {
  // Check if triangle is NULL
  if (!triangle) {
    printf("ERROR: Triangle is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the triangle
    [nsView setLineWithInitPos:triangle->vertices[0]
                        endPos:triangle->vertices[1]
                     lineWidth:line_width
                       shapeID:triangle->base.id
                         color:triangle->color];
    [nsView setLineWithInitPos:triangle->vertices[1]
                        endPos:triangle->vertices[2]
                     lineWidth:line_width
                       shapeID:triangle->base.id
                         color:triangle->color];
    [nsView setLineWithInitPos:triangle->vertices[2]
                        endPos:triangle->vertices[0]
                     lineWidth:line_width
                       shapeID:triangle->base.id
                         color:triangle->color];
    // set shape path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, triangle->vertices[0].x,
                      triangle->vertices[0].y);
    CGPathAddLineToPoint(path, NULL, triangle->vertices[1].x,
                         triangle->vertices[1].y);
    CGPathAddLineToPoint(path, NULL, triangle->vertices[2].x,
                         triangle->vertices[2].y);
    CGPathCloseSubpath(path); // Close the path to form a triangle
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = triangle->color;
    shape.filled = NO;
    shape.id = triangle->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void M_FillTriangle(M_View *p_view, M_Triangle *triangle) {
  // Check if triangle is NULL
  if (!triangle) {
    printf("ERROR: Triangle is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the triangle
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, triangle->vertices[0].x,
                      triangle->vertices[0].y);
    CGPathAddLineToPoint(path, NULL, triangle->vertices[1].x,
                         triangle->vertices[1].y);
    CGPathAddLineToPoint(path, NULL, triangle->vertices[2].x,
                         triangle->vertices[2].y);
    CGPathCloseSubpath(path); // Close the path to form a triangle
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = triangle->color;
    shape.filled = YES;
    shape.id = triangle->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

M_Polygon* M_CreatePolygon(MFPoint* vertices, int vertex_count, M_Color color)
{
    // Allocate memory for polygon
    M_Polygon* polygon = (M_Polygon*)malloc(sizeof(M_Polygon));
    // Check if memory was allocated
    if (!polygon) 
    {
        printf("ERROR: Could not allocate memory for polygon.\n");
        return NULL;
    }
    // Set polygon properties
    polygon->vertex_count = vertex_count;
    polygon->vertices = vertices;
    polygon->color = color;
    polygon->base.id = shapeID++;
    polygon->base.center_point.x = 0;
    polygon->base.center_point.y = 0;
    polygon->base.shape_type = M_SHAPE_POLYGON;
    // Return polygon
    return polygon;
}

void M_DrawPolygon(M_View *p_view, M_Polygon *polygon, float line_width) {
  // Check if polygon is NULL
  if (!polygon) {
    printf("ERROR: Polygon is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the polygon
    for (int i = 0; i < polygon->vertex_count - 1; i++) {
      [nsView setLineWithInitPos:polygon->vertices[i]
                          endPos:polygon->vertices[i + 1]
                       lineWidth:line_width
                         shapeID:polygon->base.id
                           color:polygon->color];
    }
    [nsView setLineWithInitPos:polygon->vertices[polygon->vertex_count - 1]
                        endPos:polygon->vertices[0]
                     lineWidth:line_width
                       shapeID:polygon->base.id
                         color:polygon->color];
    // set shape path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, polygon->vertices[0].x,
                      polygon->vertices[0].y);
    for (int i = 1; i < polygon->vertex_count; i++) {
      CGPathAddLineToPoint(path, NULL, polygon->vertices[i].x,
                           polygon->vertices[i].y);
    }
    CGPathCloseSubpath(path); // Close the path to form a polygon
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = polygon->color;
    shape.filled = NO;
    shape.id = polygon->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void M_FillPolygon(M_View *p_view, M_Polygon *polygon) {
  // Check if polygon is NULL
  if (!polygon) {
    printf("ERROR: Polygon is NULL.\n");
    return;
  }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // Draw the polygon
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, polygon->vertices[0].x,
                      polygon->vertices[0].y);
    for (int i = 1; i < polygon->vertex_count; i++) {
      CGPathAddLineToPoint(path, NULL, polygon->vertices[i].x,
                           polygon->vertices[i].y);
    }
    CGPathCloseSubpath(path); // Close the path to form a polygon
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = polygon->color;
    shape.filled = YES;
    shape.id = polygon->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

M_Ellipse* M_CreateEllipse(MFPoint origin, float radius_x, float radius_y, M_Color color)
{
    // Allocate memory for ellipse
    M_Ellipse* ellipse = (M_Ellipse*)malloc(sizeof(M_Ellipse));
    // Check if memory was allocated
    if (!ellipse) 
    {
        printf("ERROR: Could not allocate memory for ellipse.\n");
        return NULL;
    }
    // Set ellipse properties
    ellipse->origin = origin;
    ellipse->radius_x = radius_x;
    ellipse->radius_y = radius_y;
    ellipse->color = color;
    ellipse->base.id = shapeID++;
    ellipse->base.center_point = ellipse->origin;
    ellipse->base.shape_type = M_SHAPE_ELLIPSE;
    // Return ellipse
    return ellipse;
}

void M_DrawEllipse(M_View *p_view, M_Ellipse *ellipse, float line_width) {
    // Check if ellipse is NULL
    if (!ellipse) {
        printf("ERROR: Ellipse is NULL.\n");
        return;
    }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // set shape path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL,
                           CGRectMake(ellipse->origin.x - ellipse->radius_x,
                                      ellipse->origin.y - ellipse->radius_y,
                                      2 * ellipse->radius_x,
                                      2 * ellipse->radius_y));
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = ellipse->color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = ellipse->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) {
      nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void M_FillEllipse(M_View *p_view, M_Ellipse *ellipse) {
    // Check if ellipse is NULL
    if (!ellipse) {
        printf("ERROR: Ellipse is NULL.\n");
        return;
    }
    M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
    // set shape path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL,
                            CGRectMake(ellipse->origin.x - ellipse->radius_x,
                                        ellipse->origin.y - ellipse->radius_y,
                                        2 * ellipse->radius_x,
                                        2 * ellipse->radius_y));
    // create shape and set properties
    DrawableShape *shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = ellipse->color;
    shape.filled = YES;
    shape.id = ellipse->base.id;
    // Add the shape to the list of shapes
    if (!nsView.shapes) 
        nsView.shapes = [NSMutableArray array];
    
    [nsView.shapes addObject:shape];
    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void M_RemoveAllShapes(M_View *p_view)
{
        M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
        // Clear all shapes
        [nsView.shapes removeAllObjects];
        // Optionally, you can also clear the graphics context if needed
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextClearRect(context, CGContextGetClipBoundingBox(context));
        // Request a redraw
        [nsView setNeedsDisplay:YES];
}

void M_RemoveShape(M_View *p_view, int shape_id) {
  M_NSView *nsView = (__bridge M_NSView *)p_view->_this;
  removeShapeByID(nsView, shape_id);
  shapeID--;
}

void M_DestroyShape(M_Shape* shape) {
    if (shape != NULL) {
        // Free vertices if the shape is a polygon
        if (shape->shape_type == M_SHAPE_POLYGON) {
            free(((M_Polygon*)shape)->vertices);
        }
        free(shape);
    }
}