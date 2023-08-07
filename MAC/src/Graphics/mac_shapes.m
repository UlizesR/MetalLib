#include "MAC/mac_view.h"
#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

#import "MAC/mac_shapes.h"

int shapeID = 1;

void mac_draw_line(Mac_View* parent_view, Mac_Line* line) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;
    [nsView setLineWithInitPos:line->init_pos endPos:line->end_pos lineWidth:line->line_width shapeID:line->base.id color:line->color];
}

Mac_Line* mac_line(MFPoint init_pos, MFPoint end_pos, float line_width, Mac_Color color) {
    Mac_Line* line = (Mac_Line*)malloc(sizeof(Mac_Line));
    line->init_pos = init_pos;
    line->end_pos = end_pos;
    line->line_width = line_width;
    line->color = color;
    line->base.id = shapeID++;
    line->base.shape_type = MAC_SHAPE_LINE;
    return line;
}

void mac_draw_rect(Mac_Rect* rect, float line_width, Mac_View* parent_view) {
    MFPoint bottomLeft = rect->origin;
    MFPoint bottomRight = { rect->origin.x + rect->size.width, rect->origin.y };
    MFPoint topLeft = { rect->origin.x, rect->origin.y + rect->size.height };
    MFPoint topRight = { rect->origin.x + rect->size.width, rect->origin.y + rect->size.height };

    Mac_Line* bottomSide = mac_line(bottomLeft, bottomRight, line_width, rect->color);
    Mac_Line* rightSide = mac_line(bottomRight, topRight, line_width, rect->color);
    Mac_Line* topSide = mac_line(topRight, topLeft, line_width, rect->color);
    Mac_Line* leftSide = mac_line(topLeft, bottomLeft, line_width, rect->color);

    mac_draw_line(parent_view, bottomSide); // Bottom side
    mac_draw_line(parent_view, rightSide); // Right side
    mac_draw_line(parent_view, topSide); // Top side
    mac_draw_line(parent_view, leftSide); // Left side

    free(bottomSide);
    free(rightSide);
    free(topSide);
    free(leftSide);
}


void mac_fill_rect(Mac_Rect* rect, Mac_View* parent_view) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(rect->origin.x, rect->origin.y, rect->size.width, rect->size.height));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = rect->color;
    shape.filled = YES;
    shape.id = rect->base.id;

    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    // Removed the CGPathRelease(path) as it's managed by the DrawableShape object now.

    [nsView setNeedsDisplay:YES];
}

Mac_Rect* mac_rect(MFPoint origin, MSize size, Mac_Color color) {
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


void mac_draw_triangle(Mac_Triangle* triangle, float line_width, Mac_View* parent_view) {
    Mac_Line* side1 = mac_line(triangle->p1, triangle->p2, line_width, triangle->color);
    Mac_Line* side2 = mac_line(triangle->p2, triangle->p3, line_width, triangle->color);
    Mac_Line* side3 = mac_line(triangle->p3, triangle->p1, line_width, triangle->color);

    mac_draw_line(parent_view, side1);
    mac_draw_line(parent_view, side2);
    mac_draw_line(parent_view, side3);

    free(side1);
    free(side2);
    free(side3);
}

void mac_fill_triangle(Mac_Triangle* triangle, Mac_View* parent_view) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;

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

    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Triangle* mac_triangle(MFPoint p1, MFPoint p2, MFPoint p3, Mac_Color color) {
    Mac_Triangle* triangle = (Mac_Triangle*)malloc(sizeof(Mac_Triangle));
    triangle->p1 = p1;
    triangle->p2 = p2;
    triangle->p3 = p3;
    triangle->color = color;
    triangle->base.id = shapeID++;
    triangle->base.shape_type = MAC_SHAPE_TRIANGLE;
    return triangle;
}

void mac_draw_circle(Mac_Circle* circle, float line_width, Mac_View* parent_view) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(circle->origin.x - circle->radius, circle->origin.y - circle->radius, 2 * circle->radius, 2 * circle->radius));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = circle->color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = circle->base.id;

    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

void mac_fill_circle(Mac_Circle* circle, Mac_View* parent_view) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(circle->origin.x - circle->radius, circle->origin.y - circle->radius, 2 * circle->radius, 2 * circle->radius));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = circle->color;
    shape.filled = YES;
    shape.id = circle->base.id;

    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    [nsView setNeedsDisplay:YES];
}

Mac_Circle* mac_circle(MFPoint origin, float radius, Mac_Color color) {
    Mac_Circle* circle = (Mac_Circle*)malloc(sizeof(Mac_Circle));
    circle->origin = origin;
    circle->radius = radius;
    circle->color = color;
    circle->base.id = shapeID++;
    circle->base.shape_type = MAC_SHAPE_CIRCLE;
    return circle;
}



void mac_remove_shape(int shape_id, Mac_View* parent_view) {
    updateView(parent_view, shape_id);
}


void destroy_shape(Mac_Shape* shape) {
    if (shape != NULL) {
        // You can add any specific destruction logic here based on shapeType
        free(shape);
    }
}
