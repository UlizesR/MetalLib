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
    return rect;
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
