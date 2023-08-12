#include "MACA/mac_defs.h"
#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

#import "MACA/mac_view.h"
#import "MACA/mac_shapes.h"
#import "MACA/mac_renderer.h"

int shapeID = 0;

Mac_Point* MAC_Point(float x, float y, Mac_Color color)
{
    // Allocate memory for point
    Mac_Point* point = (Mac_Point*)malloc(sizeof(Mac_Point));
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
    point->base.shape_type = MAC_SHAPE_POINT; 
    // Return point
    return point;
}

void MAC_DrawPoint(Mac_Renderer* renderer, Mac_Point* point)
{
    // Check if renderer or point is NULL
    if (!renderer || !point) 
    {
        printf("ERROR: Renderer or point is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the point
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextSetRGBFillColor(context, point->color.r, point->color.g, point->color.b, point->color.a);
        CGContextFillRect(context, CGRectMake(point->position.x, point->position.y, 1, 1));
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

Mac_Line* MAC_Line(MFPoint init_pos, MFPoint end_pos, float line_width, Mac_Color color)
{
    // Allocate memory for line
    Mac_Line* line = (Mac_Line*)malloc(sizeof(Mac_Line));
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
    line->base.shape_type = MAC_SHAPE_LINE;
    // Return line
    return line;
}

void MAC_DrawLine(Mac_Renderer* renderer, Mac_Line* line)
{
    // Check if renderer or line is NULL
    if (!renderer || !line) 
    {
        printf("ERROR: Renderer or line is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Create the path for the line
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, line->init_pos.x, line->init_pos.y);
        CGPathAddLineToPoint(path, NULL, line->end_pos.x, line->end_pos.y);
        // Create the shape
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path; // Set the path
        shape.color = line->color;
        shape.filled = NO;
        shape.id = line->base.id;
        // Add the shape to the view
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setLineWithInitPos:line->init_pos endPos:line->end_pos lineWidth:line->line_width shapeID:line->base.id color:line->color];
        // Release the path since it's retained by the DrawableShape
        CGPathRelease(path);
    }
}

Mac_Quadrilateral* MAC_Quadrilateral(MFPoint* vertices, Mac_Color color)
{
    // Allocate memory for quadrilateral
    Mac_Quadrilateral* quad = (Mac_Quadrilateral*)malloc(sizeof(Mac_Quadrilateral));
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
    
    quad->base.shape_type = MAC_SHAPE_QUADRILATERAL;
    // Return quadrilateral
    return quad;
}

void MAC_DrawQuadrilateral(Mac_Quadrilateral* quad, float line_width, Mac_Renderer* renderer)
{
    // Check if quadrilateral or renderer is NULL
    if (!quad || !renderer) 
    {
        printf("ERROR: Quadrilateral or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the quadrilateral
        [nsView setLineWithInitPos:quad->vertices[0] endPos:quad->vertices[1] lineWidth:line_width shapeID:quad->base.id color:quad->color];
        [nsView setLineWithInitPos:quad->vertices[1] endPos:quad->vertices[2] lineWidth:line_width shapeID:quad->base.id color:quad->color];
        [nsView setLineWithInitPos:quad->vertices[2] endPos:quad->vertices[3] lineWidth:line_width shapeID:quad->base.id color:quad->color];
        [nsView setLineWithInitPos:quad->vertices[3] endPos:quad->vertices[0] lineWidth:line_width shapeID:quad->base.id color:quad->color];
        // set shape path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, quad->vertices[0].x, quad->vertices[0].y);
        CGPathAddLineToPoint(path, NULL, quad->vertices[1].x, quad->vertices[1].y);
        CGPathAddLineToPoint(path, NULL, quad->vertices[2].x, quad->vertices[2].y);
        CGPathAddLineToPoint(path, NULL, quad->vertices[3].x, quad->vertices[3].y);
        CGPathCloseSubpath(path); // Close the path to form a quadangle
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = quad->color;
        shape.filled = NO;
        shape.id = quad->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_FillQuadrilateral(Mac_Quadrilateral* quad, Mac_Renderer* renderer)
{
    // Check if quadrilateral or renderer is NULL
    if (!quad || !renderer) 
    {
        printf("ERROR: Quadrilateral or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the quadrilateral
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(quad->vertices[0].x, quad->vertices[0].y, quad->size.width, quad->size.height));
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = quad->color;
        shape.filled = YES;
        shape.id = quad->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

Mac_Triangle* MAC_Triangle(MFPoint* vertices, Mac_Color color)
{
    // Allocate memory for triangle
    Mac_Triangle* triangle = (Mac_Triangle*)malloc(sizeof(Mac_Triangle));
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
    triangle->base.shape_type = MAC_SHAPE_TRIANGLE;
    // Return triangle
    return triangle;
}

void MAC_DrawTriangle(Mac_Triangle* triangle, float line_width, Mac_Renderer* renderer)
{
    // Check if triangle or renderer is NULL
    if (!triangle || !renderer) 
    {
        printf("ERROR: Triangle or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the triangle
        [nsView setLineWithInitPos:triangle->vertices[0] endPos:triangle->vertices[1] lineWidth:line_width shapeID:triangle->base.id color:triangle->color];
        [nsView setLineWithInitPos:triangle->vertices[1] endPos:triangle->vertices[2] lineWidth:line_width shapeID:triangle->base.id color:triangle->color];
        [nsView setLineWithInitPos:triangle->vertices[2] endPos:triangle->vertices[0] lineWidth:line_width shapeID:triangle->base.id color:triangle->color];
        // set shape path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, triangle->vertices[0].x, triangle->vertices[0].y);
        CGPathAddLineToPoint(path, NULL, triangle->vertices[1].x, triangle->vertices[1].y);
        CGPathAddLineToPoint(path, NULL, triangle->vertices[2].x, triangle->vertices[2].y);
        CGPathCloseSubpath(path); // Close the path to form a triangle
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = triangle->color;
        shape.filled = NO;
        shape.id = triangle->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_FillTriangle(Mac_Triangle* triangle, Mac_Renderer* renderer)
{
    // Check if triangle or renderer is NULL
    if (!triangle || !renderer) 
    {
        printf("ERROR: Triangle or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the triangle
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, triangle->vertices[0].x, triangle->vertices[0].y);
        CGPathAddLineToPoint(path, NULL, triangle->vertices[1].x, triangle->vertices[1].y);
        CGPathAddLineToPoint(path, NULL, triangle->vertices[2].x, triangle->vertices[2].y);
        CGPathCloseSubpath(path); // Close the path to form a triangle
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = triangle->color;
        shape.filled = YES;
        shape.id = triangle->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

Mac_Polygon* MAC_Polygon(MFPoint* vertices, int vertex_count, Mac_Color color)
{
    // Allocate memory for polygon
    Mac_Polygon* polygon = (Mac_Polygon*)malloc(sizeof(Mac_Polygon));
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
    polygon->base.shape_type = MAC_SHAPE_POLYGON;
    // Return polygon
    return polygon;
}

void MAC_DrawPolygon(Mac_Polygon* polygon, float line_width, Mac_Renderer* renderer)
{
    // Check if polygon or renderer is NULL
    if (!polygon || !renderer) 
    {
        printf("ERROR: Polygon or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the polygon
        for (int i = 0; i < polygon->vertex_count - 1; i++)
        {
            [nsView setLineWithInitPos:polygon->vertices[i] endPos:polygon->vertices[i + 1] lineWidth:line_width shapeID:polygon->base.id color:polygon->color];
        }
        [nsView setLineWithInitPos:polygon->vertices[polygon->vertex_count - 1] endPos:polygon->vertices[0] lineWidth:line_width shapeID:polygon->base.id color:polygon->color];
        // set shape path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, polygon->vertices[0].x, polygon->vertices[0].y);
        for (int i = 1; i < polygon->vertex_count; i++)
        {
            CGPathAddLineToPoint(path, NULL, polygon->vertices[i].x, polygon->vertices[i].y);
        }
        CGPathCloseSubpath(path); // Close the path to form a polygon
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = polygon->color;
        shape.filled = NO;
        shape.id = polygon->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_FillPolygon(Mac_Polygon* polygon, Mac_Renderer* renderer)
{
    // Check if polygon or renderer is NULL
    if (!polygon || !renderer) 
    {
        printf("ERROR: Polygon or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* rview = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;
        // Draw the polygon
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, polygon->vertices[0].x, polygon->vertices[0].y);
        for (int i = 1; i < polygon->vertex_count; i++)
        {
            CGPathAddLineToPoint(path, NULL, polygon->vertices[i].x, polygon->vertices[i].y);
        }
        CGPathCloseSubpath(path); // Close the path to form a polygon
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = polygon->color;
        shape.filled = YES;
        shape.id = polygon->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

Mac_Ellipse* MAC_Ellipse(MFPoint origin, float radius_x, float radius_y, Mac_Color color)
{
    // Allocate memory for ellipse
    Mac_Ellipse* ellipse = (Mac_Ellipse*)malloc(sizeof(Mac_Ellipse));
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
    ellipse->base.shape_type = MAC_SHAPE_ELLIPSE;
    // Return ellipse
    return ellipse;
}

void MAC_DrawEllipse(Mac_Ellipse* ellipse, float line_width, Mac_Renderer* renderer)
{
    // Check if ellipse or renderer is NULL
    if (!ellipse || !renderer) 
    {
        printf("ERROR: Ellipse or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics
        // set shape path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(ellipse->origin.x - ellipse->radius_x, ellipse->origin.y - ellipse->radius_y, 2 * ellipse->radius_x, 2 * ellipse->radius_y));
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = ellipse->color;
        shape.lineWidth = line_width;
        shape.filled = NO;
        shape.id = ellipse->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_FillEllipse(Mac_Ellipse* ellipse, Mac_Renderer* renderer)
{
    // Check if ellipse or renderer is NULL
    if (!ellipse || !renderer) 
    {
        printf("ERROR: Ellipse or renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics
        // set shape path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(ellipse->origin.x - ellipse->radius_x, ellipse->origin.y - ellipse->radius_y, 2 * ellipse->radius_x, 2 * ellipse->radius_y));
        // create shape and set properties
        DrawableShape* shape = [[DrawableShape alloc] init];
        shape.path = path;
        shape.color = ellipse->color;
        shape.filled = YES;
        shape.id = ellipse->base.id;
        // Add the shape to the list of shapes
        if (!nsView.shapes) 
        {
            nsView.shapes = [NSMutableArray array];
        }
        [nsView.shapes addObject:shape];
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_RemoveShape(int shape_id, Mac_Renderer* renderer)
{
    // Check if renderer is NULL
    if (!renderer) 
    {
        printf("ERROR: Renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* view_to_render = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this;
        // Get the list of shapes
        NSMutableArray<DrawableShape*>* shapes = nsView.shapes;
        if (!shapes || shapes.count == 0) return;
        // Remove the shape
        NSMutableArray<DrawableShape*>* shapesToRemove = [NSMutableArray array];
        for (DrawableShape* shape in shapes) 
        {
            if (shape.id == shape_id) 
            {
                [shapesToRemove addObject:shape];
            }
        }
        if (shapesToRemove.count > 0) 
        {
            [shapes removeObjectsInArray:shapesToRemove];
            [nsView setNeedsDisplay:YES];
        }
    }
    shapeID--;
}

void MAC_RemoveAllShapes(Mac_Renderer* renderer)
{
    // Check if renderer is NULL
    if (!renderer) 
    {
        printf("ERROR: Renderer is NULL.\n");
        return;
    }
    // Check if renderer is of type Core Graphics
    if (renderer->type == MAC_RENDERER_CORE_G)
    {
        // Get the Core Graphics view
        Mac_RView* view_to_render = renderer->render_view->rview;
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this;
        // Clear all shapes
        [nsView.shapes removeAllObjects];
        // Optionally, you can also clear the graphics context if needed
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextClearRect(context, CGContextGetClipBoundingBox(context));
        // Request a redraw
        [nsView setNeedsDisplay:YES];
    }
}

void MAC_DestroyShape(Mac_Shape* shape)
{
    if (shape != NULL) 
    {
        // You can add any specific destruction logic here based on shapeType
        free(shape);
    }
}