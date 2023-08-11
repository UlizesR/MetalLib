#include "MACA/mac_view.h"
#include "MACA/mac_window.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <Foundation/Foundation.h>

@implementation Mac_NSView_Normal
@end

extern int shapeID;
@implementation DrawableShape

- (instancetype)init {
    self = [super init];
    if (self) {
        _path = NULL;
        _color = (Mac_Color){0, 0, 0, 1}; // Default to black color
        _lineWidth = 1.0;
        _filled = NO;
        _id = shapeID++; // Automatically set the shape ID and increment shapeID
    }
    return self;
}

- (void)updateLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos {
    CGMutablePathRef newPath = CGPathCreateMutable();
    CGPathMoveToPoint(newPath, NULL, init_pos.x, init_pos.y);
    CGPathAddLineToPoint(newPath, NULL, end_pos.x, end_pos.y);

    if (_path) {
        CGPathRelease(_path);
    }

    _path = newPath;
}

- (void)dealloc {
    [super dealloc];
    if (_path) {
        CGPathRelease(_path);
    }
}

@end

@implementation Mac_NSView_Core_G

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _shapes = [NSMutableArray array];
        _drawingCommands = [NSMutableArray array];
    }
    return self;
}

- (void)setLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos lineWidth:(float)line_width shapeID:(int)id color:(Mac_Color)color {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, init_pos.x, init_pos.y);
    CGPathAddLineToPoint(path, NULL, end_pos.x, end_pos.y);

    DrawableShape* shape = [[DrawableShape alloc] init];
    shape.path = path;
    shape.color = color;
    shape.lineWidth = line_width;
    shape.filled = NO;
    shape.id = id;

    [self.shapes addObject:shape];

    DrawingCommand command = {init_pos, end_pos, line_width, color};
    [self.drawingCommands addObject:[NSValue valueWithBytes:&command objCType:@encode(DrawingCommand)]];

    [self setNeedsDisplay:YES];
}

- (void)updateView:(int)shapeID {
    NSMutableArray *shapesToRemove = [NSMutableArray array];
    for (DrawableShape *shape in self.shapes) {
        if (shape.id == shapeID) {
            [shapesToRemove addObject:shape];
        }
    }
    [self.shapes removeObjectsInArray:shapesToRemove];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSetShouldAntialias(context, YES);

    for (DrawableShape* shape in self.shapes) {
        CGContextSetLineWidth(context, shape.lineWidth);
        CGContextSetRGBStrokeColor(context, shape.color.r, shape.color.g, shape.color.b, shape.color.a);
        if (shape.filled) {
            CGContextSetRGBFillColor(context, shape.color.r, shape.color.g, shape.color.b, shape.color.a);
            CGContextAddPath(context, shape.path);
            CGContextFillPath(context);
        } else {
            CGContextAddPath(context, shape.path);
            CGContextStrokePath(context);
        }
    }
}

@end

@implementation Mac_NSView_Metal
@end

static int viewIDCounter = 0; // Initialize view ID counter

Mac_View* MAC_AddSubView(Mac_View* parent, UInt32 type, int width, int height, int x, int y, float corner_radius, Mac_Color background_color, Mac_Renderer* renderer)
{
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent view is NULL\n");
        return NULL;
    }

    Mac_View* subView = (Mac_View*)malloc(sizeof(Mac_View));
    if (subView == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory for subview\n");
        return NULL;
    }

    subView->type = type;

    NSRect frame = NSMakeRect(x, y, width, height);
    NSColor* bgColor = [NSColor colorWithRed:background_color.r
                                       green:background_color.g
                                        blue:background_color.b
                                       alpha:background_color.a];
    NSView* nsview = NULL;
    if (type == MAC_VIEW_TYPE_NORMAL)
    {
        Mac_NView* nview = (Mac_NView*)malloc(sizeof(Mac_NView));
        if (nview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for normal view\n");
            free(subView);
            return NULL;
        }
        nview->size.width = width;
        nview->size.height = height;
        nview->position.x = x;
        nview->position.y = y;
        nview->background_color = background_color;
        nview->window_parent = parent->view.n_view.window_parent;
        nview->id = viewIDCounter++;

        nsview = [[Mac_NSView_Normal alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        nview->_this = (__bridge void*)nsview;
        subView->view.n_view = *nview;

        if (parent->type == MAC_VIEW_TYPE_NORMAL)
        {
            Mac_NSView_Normal* parentNSView = (__bridge Mac_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == MAC_VIEW_TYPE_CORE_G)
        {
            Mac_NSView_Core_G* parentNSView = (__bridge Mac_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }
    if (type == MAC_VIEW_TYPE_CORE_G)
    {
        Mac_RView* rview = (Mac_RView*)malloc(sizeof(Mac_RView));
        if (rview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for core graphics view\n");
            free(subView);
            return NULL;
        }
        rview->size.width = width;
        rview->size.height = height;
        rview->position.x = x;
        rview->position.y = y;
        rview->background_color = background_color;
        rview->window_parent = parent->view.r_view.window_parent;
        rview->renderer = renderer;
        rview->id = viewIDCounter++;

        nsview = [[Mac_NSView_Core_G alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        rview->_this = (__bridge void*)nsview;
        subView->view.r_view = *rview;

        if (parent->type == MAC_VIEW_TYPE_NORMAL)
        {
            Mac_NSView_Normal* parentNSView = (__bridge Mac_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == MAC_VIEW_TYPE_CORE_G)
        {
            Mac_NSView_Core_G* parentNSView = (__bridge Mac_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }

    return subView;
}

Mac_View* MAC_AddContentView(Mac_Window* parent, Mac_Color background_color, UInt32 type, Mac_Renderer* renderer)
{
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent window is NULL\n");
        return NULL;
    }

    Mac_View* contentView = (Mac_View*)malloc(sizeof(Mac_View));
    if (contentView == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory for content view\n");
        return NULL;
    }

    contentView->type = type;

    NSRect frame = NSMakeRect(0, 0, parent->size.width, parent->size.height);
    // Convert the Mac_Color to an NSColor
    NSColor* bgColor = [NSColor colorWithRed:background_color.r
                                        green:background_color.g
                                        blue:background_color.b
                                        alpha:background_color.a];

    if (type == MAC_VIEW_TYPE_NORMAL)
    {
        Mac_NView* nview = (Mac_NView*)malloc(sizeof(Mac_NView));
        if (nview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for normal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }
        nview->size.width = parent->size.width;
        nview->size.height = parent->size.height;
        nview->position.x = 0;
        nview->position.y = 0;
        nview->background_color = background_color;
        nview->window_parent = parent;
        nview->id = viewIDCounter++; // Set the view ID

        Mac_NSView_Normal* nsView = [[Mac_NSView_Normal alloc] initWithFrame:frame];
        if (nsView == NULL) {
            fprintf(stderr, "Error: Failed to create normal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }
        nview->_this = (__bridge void*)nsView; // Store the Objective-C instance in _this
        [nsView setWantsLayer:YES]; // Enable layer backing

        [nsView.layer setBackgroundColor:bgColor.CGColor]; // Set the background color
        [nsView setNeedsDisplay:YES];
        contentView->view.n_view = *nview; // Assign the created nview to the contentView's UView

        // Get the NSWindow from the parent Mac_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:nsView]; // Set the content view of the parent window
    }
    if (type == MAC_VIEW_TYPE_CORE_G)
    {
        Mac_RView* rview = (Mac_RView*)malloc(sizeof(Mac_RView));
        if (rview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for normal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }
        rview->size.width = parent->size.width;
        rview->size.height = parent->size.height;
        rview->position.x = 0;
        rview->position.y = 0;
        rview->background_color = background_color;
        rview->window_parent = parent;
        rview->id = viewIDCounter++; // Set the view ID
        rview->renderer = renderer;

        Mac_NSView_Core_G* nsView = [[Mac_NSView_Core_G alloc] initWithFrame:frame];
        if (nsView == NULL) {
            fprintf(stderr, "Error: Failed to create normal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }

        rview->_this = (__bridge void*)nsView; // Store the Objective-C instance in _this
        [nsView setWantsLayer:YES]; // Enable layer backing

        [nsView.layer setBackgroundColor:bgColor.CGColor]; // Set the background color
        [nsView setNeedsDisplay:YES];
        contentView->view.r_view = *rview; // Assign the created nview to the contentView's UView

        // Get the NSWindow from the parent Mac_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:nsView]; // Set the content view of the parent window
    }

    return contentView;
}

void MAC_ChangeViewBGColor(Mac_View* view, Mac_Color color)
{
    if (view == NULL)
    {
        printf("ERROR: View is NULL. Cannot change background color.\n");
        return;
    }

    NSColor* nsColor = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];

    if (view->type & MAC_VIEW_TYPE_NORMAL)
    {
        Mac_NSView_Normal* nsView = (__bridge Mac_NSView_Normal*)view->view.n_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else if (view->type & MAC_VIEW_TYPE_CORE_G)
    {
        Mac_NSView_Core_G* nsView = (__bridge Mac_NSView_Core_G*)view->view.r_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else if (view->type & MAC_VIEW_TYPE_METAL)
    {
        Mac_NSView_Metal* nsView = (__bridge Mac_NSView_Metal*)view->view.m_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else
    {
        printf("ERROR: Unsupported view type. Cannot change background color.\n");
    }
}

void MAC_DestroyView(Mac_View* view)
{
    if (view == NULL) {
        return;
    }

    if (view->type == MAC_VIEW_TYPE_NORMAL) {
        Mac_NView* nview = &view->view.n_view;
        Mac_NSView_Normal* nsview = (__bridge Mac_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
    }
    if (view->type == MAC_VIEW_TYPE_CORE_G) {
        Mac_RView* rview = &view->view.r_view;
        Mac_NSView_Core_G* nsview = (__bridge Mac_NSView_Core_G*)rview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
    }

    free(view); // Free the view itself
}


void MAC_DestroyContentView(Mac_View* contentView) {
    if (contentView == NULL) {
        return;
    }

    if (contentView->type == MAC_VIEW_TYPE_NORMAL) {
        Mac_NView* nview = &contentView->view.n_view;
        Mac_NSView_Normal* nsview = (__bridge Mac_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
        free(nview);
    }

    free(contentView);
}
