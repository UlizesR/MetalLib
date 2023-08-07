#include "MAC/mac_view.h"
#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

#import "MAC/mac_shapes.h"

void mac_draw_line(Mac_View* parent_view, Mac_FPoint init_pos, Mac_FPoint end_pos, float line_width, Mac_Color color) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;
    [nsView setLineWithInitPos:init_pos endPos:end_pos lineWidth:line_width color:color];
}

void mac_draw_rect(Mac_Rect* rect, float line_width, Mac_View* parent_view) {
    Mac_FPoint bottomLeft = rect->origin;
    Mac_FPoint bottomRight = { rect->origin.x + rect->size.width, rect->origin.y };
    Mac_FPoint topLeft = { rect->origin.x, rect->origin.y + rect->size.height };
    Mac_FPoint topRight = { rect->origin.x + rect->size.width, rect->origin.y + rect->size.height };

    mac_draw_line(parent_view, bottomLeft, bottomRight, line_width, rect->color); // Bottom side
    mac_draw_line(parent_view, bottomRight, topRight, line_width, rect->color); // Right side
    mac_draw_line(parent_view, topRight, topLeft, line_width, rect->color); // Top side
    mac_draw_line(parent_view, topLeft, bottomLeft, line_width, rect->color); // Left side
}

void mac_fill_rect(Mac_Rect* rect, Mac_View* parent_view) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)parent_view->_this;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(rect->origin.x, rect->origin.y, rect->size.width, rect->size.height));

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = rect->color;
    shape.filled = YES;

    if (!nsView.shapes) {
        nsView.shapes = [NSMutableArray array];
    }
    [nsView.shapes addObject:shape];

    // CGPathRelease(path);

    [nsView setNeedsDisplay:YES];
}


Mac_Rect* mac_rect(Mac_FPoint origin, MSize size, Mac_Color color) {
    Mac_Rect* rect = (Mac_Rect*)malloc(sizeof(Mac_Rect));
    rect->origin = origin;
    rect->size = size;
    rect->color = color;
    return rect;
}

void destroy_rect(Mac_Rect* rect) {
    if (rect != NULL) {
        free(rect);
    }
}
