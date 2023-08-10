#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

#import "MACA/mac_view.h"
#import "MACA/mac_shapes.h"
#import "MACA/mac_renderer.h"

int shapeID = 0;

void MAC_DrawPoint(Mac_Renderer* renderer, Mac_Point* point) 
{
    if (!renderer || !point) 
    {
        printf("ERROR: Renderer or point is NULL.\n");
        return;
    }

    Mac_RView* rview = renderer->render_view->rview;
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)rview->_this;

    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSetRGBFillColor(context, point->color.r, point->color.g, point->color.b, point->color.a);
    CGContextFillRect(context, CGRectMake(point->position.x, point->position.y, 1, 1));

    [nsView setNeedsDisplay:YES];
}

Mac_Point* MAC_Point(float x, float y, Mac_Color color) 
{
    Mac_Point* point = (Mac_Point*)malloc(sizeof(Mac_Point));
    if (!point) 
    {
        printf("ERROR: Could not allocate memory for point.\n");
        return NULL;
    }
    point->position.x = x;
    point->position.y = y;
    point->color = color;
    point->base.id = shapeID++; // Using a static variable for unique shape IDs
    point->base.shape_type = MAC_SHAPE_POINT; // Assuming MAC_SHAPE_POINT is defined as a unique value for points
    return point;
}

void MAC_DrawLine(Mac_Renderer* renderer, Mac_Line* line) 
{
    if (!renderer || !line) 
    {
        printf("ERROR: Renderer or line is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    [nsView setLineWithInitPos:line->init_pos endPos:line->end_pos lineWidth:line->line_width shapeID:line->base.id color:line->color];
}

Mac_Line* MAC_Line(MFPoint init_pos, MFPoint end_pos, float line_width, Mac_Color color) 
{
    Mac_Line* line = (Mac_Line*)malloc(sizeof(Mac_Line));
    line->init_pos = init_pos;
    line->end_pos = end_pos;
    line->line_width = line_width;
    line->color = color;
    line->base.id = shapeID++; // Assuming shapeID is a global variable for unique shape IDs
    line->base.shape_type = MAC_SHAPE_LINE;
    return line;
}

void MAC_DrawRect(Mac_Rect* rect, float line_width, Mac_Renderer* renderer) 
{
    if (!rect || !renderer) 
    {
        printf("ERROR: Rectangle or renderer is NULL.\n");
        return;
    }

    MFPoint bottomLeft = rect->origin;
    MFPoint bottomRight = { rect->origin.x + rect->size.width, rect->origin.y };
    MFPoint topLeft = { rect->origin.x, rect->origin.y + rect->size.height };
    MFPoint topRight = { rect->origin.x + rect->size.width, rect->origin.y + rect->size.height };

    Mac_Line* bottomSide = MAC_Line(bottomLeft, bottomRight, line_width, rect->color);
    Mac_Line* rightSide = MAC_Line(bottomRight, topRight, line_width, rect->color);
    Mac_Line* topSide = MAC_Line(topRight, topLeft, line_width, rect->color);
    Mac_Line* leftSide = MAC_Line(topLeft, bottomLeft, line_width, rect->color);

    MAC_DrawLine(renderer, bottomSide); // Bottom side
    MAC_DrawLine(renderer, rightSide); // Right side
    MAC_DrawLine(renderer, topSide); // Top side
    MAC_DrawLine(renderer, leftSide); // Left side

    free(bottomSide);
    free(rightSide);
    free(topSide);
    free(leftSide);
}

void MAC_FillRect(Mac_Rect* rect, Mac_Renderer* renderer) 
{
    if (!renderer || !rect) 
    {
        printf("ERROR: Renderer or rect is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(rect->origin.x, rect->origin.y, rect->size.width, rect->size.height));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = rect->color;
    shape.filled = YES;
    shape.id = rect->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    // Removed the CGPathRelease(path) as it's managed by the DrawableShape object now.

    [nsView setNeedsDisplay:YES];
}


Mac_Rect* MAC_Rect(MFPoint origin, MSize size, Mac_Color color) 
{
    Mac_Rect* rect = (Mac_Rect*)malloc(sizeof(Mac_Rect));
    rect->origin = origin;
    rect->size = size;
    rect->color = color;
    rect->base.id = shapeID++;
    rect->base.shape_type = MAC_SHAPE_RECT;

    // Calculate the other points based on the origin and size
    rect->p_tr = (MFPoint){ origin.x + size.width, origin.y + size.height };
    rect->p_tl = (MFPoint){ origin.x, origin.y + size.height };
    rect->p_br = (MFPoint){ origin.x + size.width, origin.y };

    return rect;
}

void MAC_DrawTriangle(Mac_Triangle* triangle, float line_width, Mac_Renderer* renderer) 
{
    if (!triangle || !renderer) 
    {
        printf("ERROR: Triangle or renderer is NULL.\n");
        return;
    }

    Mac_Line* side1 = MAC_Line(triangle->p1, triangle->p2, line_width, triangle->color);
    Mac_Line* side2 = MAC_Line(triangle->p2, triangle->p3, line_width, triangle->color);
    Mac_Line* side3 = MAC_Line(triangle->p3, triangle->p1, line_width, triangle->color);

    MAC_DrawLine(renderer, side1);
    MAC_DrawLine(renderer, side2);
    MAC_DrawLine(renderer, side3);

    free(side1);
    free(side2);
    free(side3);
}

void MAC_FillTriangle(Mac_Triangle* triangle, Mac_Renderer* renderer) 
{
    if (!triangle || !renderer) 
    {
        printf("ERROR: Triangle or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, triangle->p1.x, triangle->p1.y);
    CGPathAddLineToPoint(path, NULL, triangle->p2.x, triangle->p2.y);
    CGPathAddLineToPoint(path, NULL, triangle->p3.x, triangle->p3.y);
    CGPathCloseSubpath(path);

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = triangle->color;
    shape.filled = YES;
    shape.id = triangle->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Triangle* MAC_Triangle(MFPoint p1, MFPoint p2, MFPoint p3, Mac_Color color) 
{
    Mac_Triangle* triangle = (Mac_Triangle*)malloc(sizeof(Mac_Triangle));
    triangle->p1 = p1;
    triangle->p2 = p2;
    triangle->p3 = p3;
    triangle->color = color;
    triangle->base.id = shapeID++;
    triangle->base.shape_type = MAC_SHAPE_TRIANGLE;
    return triangle;
}

void MAC_DrawCircle(Mac_Circle* circle, float line_width, Mac_Renderer* renderer) 
{
    if (!circle || !renderer) 
    {
        printf("ERROR: Circle or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(circle->origin.x - circle->radius, circle->origin.y - circle->radius, 2 * circle->radius, 2 * circle->radius));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = circle->color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = circle->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

void MAC_FillCircle(Mac_Circle* circle, Mac_Renderer* renderer) 
{
    if (!circle || !renderer) 
    {
        printf("ERROR: Circle or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(circle->origin.x - circle->radius, circle->origin.y - circle->radius, 2 * circle->radius, 2 * circle->radius));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = circle->color;
    shape.filled = YES;
    shape.id = circle->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Circle* MAC_Circle(MFPoint origin, float radius, Mac_Color color) 
{
    Mac_Circle* circle = (Mac_Circle*)malloc(sizeof(Mac_Circle));
    circle->origin = origin;
    circle->radius = radius;
    circle->color = color;
    circle->base.id = shapeID++;
    circle->base.shape_type = MAC_SHAPE_CIRCLE;
    return circle;
}

void MAC_DrawPolygon(Mac_Polygon* polygon, float line_width, Mac_Renderer* renderer) 
{
    if (!polygon || !renderer) 
    {
        printf("ERROR: Polygon or renderer is NULL.\n");
        return;
    }; 
    if (polygon->vertex_count < 3)
    {
        printf("ERROR: Polygon has less than 3 vertices.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view

    for (int i = 0; i < polygon->vertex_count - 1; i++) 
    {
        Mac_Line* line = MAC_Line(polygon->vertices[i], polygon->vertices[i + 1], line_width, polygon->color);
        MAC_DrawLine(renderer, line); // Pass renderer instead of parent_view
        free(line);
    }

    // Draw the line connecting the last vertex to the first to close the polygon
    Mac_Line* closingLine = MAC_Line(polygon->vertices[polygon->vertex_count - 1], polygon->vertices[0], line_width, polygon->color);
    MAC_DrawLine(renderer, closingLine); // Pass renderer instead of parent_view
    free(closingLine);
}

void MAC_FillPolygon(Mac_Polygon* polygon, Mac_Renderer* renderer) 
{
    if (!polygon || !renderer) 
    {
        printf("ERROR: Polygon or renderer is NULL.\n");
        return;
    }
    if (polygon->vertex_count < 3)
    {
        printf("ERROR: Polygon has less than 3 vertices.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, polygon->vertices[0].x, polygon->vertices[0].y);
    for (int i = 1; i < polygon->vertex_count; i++) 
    {
        CGPathAddLineToPoint(path, NULL, polygon->vertices[i].x, polygon->vertices[i].y);
    }
    CGPathCloseSubpath(path); // Close the path to create a polygon

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = polygon->color;
    shape.filled = YES;
    shape.id = polygon->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Polygon* MAC_Polygon(MFPoint* vertices, int vertex_count, Mac_Color color) 
{
    Mac_Polygon* polygon = (Mac_Polygon*)malloc(sizeof(Mac_Polygon));
    polygon->base.shape_type = MAC_SHAPE_POLYGON;
    polygon->vertices = vertices;
    polygon->vertex_count = vertex_count;
    polygon->color = color;
    return polygon;
}

void MAC_DrawEllipse(Mac_Ellipse* ellipse, float line_width, Mac_Renderer* renderer) 
{
    if (!ellipse || !renderer) 
    {
        printf("ERROR: Ellipse or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(ellipse->origin.x - ellipse->radius_x, ellipse->origin.y - ellipse->radius_y, 2 * ellipse->radius_x, 2 * ellipse->radius_y));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = ellipse->color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = ellipse->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

void MAC_FillEllipse(Mac_Ellipse* ellipse, Mac_Renderer* renderer) 
{
    if (!ellipse || !renderer) 
    {
        printf("ERROR: Ellipse or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(ellipse->origin.x - ellipse->radius_x, ellipse->origin.y - ellipse->radius_y, 2 * ellipse->radius_x, 2 * ellipse->radius_y));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = ellipse->color;
    shape.filled = YES;
    shape.id = ellipse->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Ellipse* MAC_Ellipse(MFPoint origin, float radius_x, float radius_y, Mac_Color color) 
{
    Mac_Ellipse* ellipse = (Mac_Ellipse*)malloc(sizeof(Mac_Ellipse));
    ellipse->base.shape_type = MAC_SHAPE_ELLIPSE; // Assuming you have this enum value
    ellipse->origin = origin;
    ellipse->radius_x = radius_x;
    ellipse->radius_y = radius_y;
    ellipse->color = color;
    return ellipse;
}

void MAC_DrawQuadrilateral(Mac_Quadrilateral* quad, float line_width, Mac_Renderer* renderer) 
{
    if (!quad || !renderer) 
    {
        printf("ERROR: Quadrilateral or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, quad->vertices[0].x, quad->vertices[0].y);
    for (int i = 1; i < 4; i++) 
    {
        CGPathAddLineToPoint(path, NULL, quad->vertices[i].x, quad->vertices[i].y);
    }
    CGPathCloseSubpath(path); // Close the path to create a quadrilateral

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = quad->color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = quad->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

void MAC_FillQuadrilateral(Mac_Quadrilateral* quad, Mac_Renderer* renderer) 
{
    if (!quad || !renderer) 
    {
        printf("ERROR: Quadrilateral or renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, quad->vertices[0].x, quad->vertices[0].y);
    for (int i = 1; i < 4; i++) 
    {
        CGPathAddLineToPoint(path, NULL, quad->vertices[i].x, quad->vertices[i].y);
    }
    CGPathCloseSubpath(path); // Close the path to create a quadrilateral

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = quad->color;
    shape.filled = YES;
    shape.id = quad->base.id;

    if (!nsView.shapes) 
    {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Quadrilateral* MAC_Quadrilateral(MFPoint vertices[4], Mac_Color color) 
{
    Mac_Quadrilateral* quad = (Mac_Quadrilateral*)malloc(sizeof(Mac_Quadrilateral));
    quad->base.shape_type = MAC_SHAPE_QUADRILATERAL; // Assuming you have this enum value
    memcpy(quad->vertices, vertices, 4 * sizeof(MFPoint));
    quad->color = color;
    return quad;
}

void MAC_RemoveShape(int shape_id, Mac_Renderer* renderer) 
{
    if (!renderer) 
    {
        printf("ERROR: Renderer is NULL.\n");
        return;
    }

    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    NSMutableArray<DrawableShape*>* shapes = nsView.shapes;
    if (!shapes || shapes.count == 0) return;

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

void MAC_RemoveAllShapes(Mac_Renderer* renderer)
{
    if (!renderer) 
    {
        printf("ERROR: Renderer is NULL.\n");
        return;
    }
    Mac_RView* view_to_render = renderer->render_view->rview; // Assuming the renderer has a render_view field pointing to the appropriate view
    Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view_to_render->_this; // Assuming the view is of type Core Graphics

    // Clear all shapes
    [nsView.shapes removeAllObjects];

    // Optionally, you can also clear the graphics context if needed
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextClearRect(context, CGContextGetClipBoundingBox(context));

    // Request a redraw
    [nsView setNeedsDisplay:YES];
}

void MAC_DestroyShape(Mac_Shape* shape) 
{
    if (shape != NULL) 
    {
        // You can add any specific destruction logic here based on shapeType
        free(shape);
    }
}
