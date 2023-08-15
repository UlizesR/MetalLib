#import "MACA/mac_view.h"
#import "MACA/mac_window.h"
#import "MACA/mac_devices.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>

NSView* getViewFromMacView(M_View* parent_view) {
    NSView* nsView = NULL;
    switch (parent_view->type) {
        case M_VIEW_TYPE_NORMAL:
            nsView = (__bridge M_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case M_VIEW_TYPE_CORE_G:
            nsView = (__bridge M_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case M_VIEW_TYPE_METAL:
            nsView = (__bridge M_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        case M_VIEW_TYPE_TABLE:
            nsView = (__bridge M_NSTableView *)(parent_view->view.t_view._this);
            break;
        default:
            NSLog(@"Error: Unknown view type");
            return NULL;
    }
    return nsView;
}

@implementation M_NSView_Normal
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
@end

extern int shapeID;
@implementation DrawableShape

- (instancetype)init {
    self = [super init];
    if (self) {
        _path = NULL;
        _color = (M_Color){0, 0, 0, 1}; // Default to black color
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

@implementation M_NSView_Core_G

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _shapes = [NSMutableArray array];
        _drawingCommands = [NSMutableArray array];
    }
    return self;
}

- (void)setLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos lineWidth:(float)line_width shapeID:(int)id color:(M_Color)color {
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

@implementation M_NSView_Metal
@end

static int viewIDCounter = 0; // Initialize view ID counter

M_View* M_AddSubView(M_View* parent, UInt32 type, int width, int height, int x, int y, float corner_radius, M_Color background_color, M_Renderer* renderer)
{
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent view is NULL\n");
        return NULL;
    }

    M_View* subView = (M_View*)malloc(sizeof(M_View));
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
    if (type == M_VIEW_TYPE_NORMAL)
    {
        M_NView* nview = (M_NView*)malloc(sizeof(M_NView));
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
        nview->is_content_view = false; 

        nsview = [[M_NSView_Normal alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        nview->_this = (__bridge void*)nsview;
        subView->view.n_view = *nview;

        if (parent->type == M_VIEW_TYPE_NORMAL)
        {
            M_NSView_Normal* parentNSView = (__bridge M_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == M_VIEW_TYPE_CORE_G)
        {
            M_NSView_Core_G* parentNSView = (__bridge M_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }
    else if (type == M_VIEW_TYPE_CORE_G)
    {
        M_RView* rview = (M_RView*)malloc(sizeof(M_RView));
        if (rview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for core graphics view\n");
            free(subView);
            return NULL;
        }
        if (renderer == NULL) {
            fprintf(stderr, "Error: Renderer is NULL\n");
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
        rview->is_content_view = false;

        nsview = [[M_NSView_Core_G alloc] initWithFrame:frame];
        rview->_this = (__bridge void*)nsview;
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        subView->view.r_view = *rview;

        if (parent->type == M_VIEW_TYPE_NORMAL)
        {
            M_NSView_Normal* parentNSView = (__bridge M_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == M_VIEW_TYPE_CORE_G)
        {
            M_NSView_Core_G* parentNSView = (__bridge M_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }
    else if (type == M_VIEW_TYPE_METAL)
    {
        M_MView* mview = (M_MView*)malloc(sizeof(M_MView));
        if (mview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for metal view\n");
            free(subView);
            return NULL;
        }
        if (renderer == NULL) {
            fprintf(stderr, "Error: Renderer is NULL\n");
            free(subView);
            return NULL;
        }
        mview->size.width = width;
        mview->size.height = height;
        mview->position.x = x;
        mview->position.y = y;
        mview->background_color = background_color;
        mview->window_parent = parent->view.m_view.window_parent;
        mview->id = viewIDCounter++;
        mview->is_content_view = false;
        mview->device = M_DefaultDevice();

        nsview = [[M_NSView_Metal alloc] initWithFrame:frame];
        mview->_this = (__bridge void*)nsview;
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        subView->view.m_view = *mview;

        if (parent->type == M_VIEW_TYPE_NORMAL)
        {
            M_NSView_Normal* parentNSView = (__bridge M_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == M_VIEW_TYPE_CORE_G)
        {
            M_NSView_Core_G* parentNSView = (__bridge M_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }
    else if (type == M_VIEW_TYPE_TABLE)
    {
        M_TView* tview = (M_TView*)malloc(sizeof(M_TView));
        if (tview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for table view\n");
            free(subView);
            return NULL;
        }
        tview->size.width = width;
        tview->size.height = height;
        tview->position = (MPoint){x, y};
        tview->background_color = background_color;
        tview->window_parent = parent->view.t_view.window_parent;
        tview->id = viewIDCounter++;
        tview->is_content_view = false;

        nsview = [[M_NSTableView alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        tview->_this = (__bridge void*)nsview;
        subView->view.t_view = *tview;

        if (parent->type == M_VIEW_TYPE_NORMAL)
        {
            M_NSView_Normal* parentNSView = (__bridge M_NSView_Normal*)parent->view.n_view._this;
            [parentNSView addSubview:nsview];
        }
        else if (parent->type == M_VIEW_TYPE_CORE_G)
        {
            M_NSView_Core_G* parentNSView = (__bridge M_NSView_Core_G*)parent->view.r_view._this;
            [parentNSView addSubview:nsview];
        }
    }
    else 
    {
        fprintf(stderr, "Error: Unsupported view type\n");
        free(subView);
        return NULL;
    }

    return subView;
}

M_View* M_AddContentView(M_Window* parent, M_Color background_color, UInt32 type, M_Renderer* renderer)
{
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent window is NULL\n");
        return NULL;
    }

    M_View* contentView = (M_View*)malloc(sizeof(M_View));
    if (contentView == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory for content view\n");
        return NULL;
    }

    contentView->type = type;

    NSRect frame = NSMakeRect(0, 0, parent->size.width, parent->size.height);
    // Convert the M_Color to an NSColor
    NSColor* bgColor = [NSColor colorWithRed:background_color.r
                                        green:background_color.g
                                        blue:background_color.b
                                        alpha:background_color.a];

    if (type == M_VIEW_TYPE_NORMAL)
    {
        M_NView* nview = (M_NView*)malloc(sizeof(M_NView));
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
        nview->is_content_view = true; // Set the is_content_view flag to true

        M_NSView_Normal* nsView = [[M_NSView_Normal alloc] initWithFrame:frame];
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

        // Get the NSWindow from the parent M_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:nsView]; // Set the content view of the parent window
    }
    else if (type == M_VIEW_TYPE_CORE_G)
    {
        M_RView* rview = (M_RView*)malloc(sizeof(M_RView));
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
        rview->is_content_view = true; // Set the is_content_view flag to true

        M_NSView_Core_G* nsView = [[M_NSView_Core_G alloc] initWithFrame:frame];
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

        // Get the NSWindow from the parent M_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:nsView]; // Set the content view of the parent window
    }
    else if (type == M_VIEW_TYPE_METAL)
    {
        M_MView* mview = (M_MView*)malloc(sizeof(M_MView));
        if (mview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for metal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }
        mview->size.width = parent->size.width;
        mview->size.height = parent->size.height;
        mview->position.x = 0;
        mview->position.y = 0;
        mview->background_color = background_color;
        mview->window_parent = parent;
        mview->id = viewIDCounter++; // Set the view ID
        mview->is_content_view = true; // Set the is_content_view flag to true
        mview->device = M_DefaultDevice();

        M_NSView_Metal* nsView = [[M_NSView_Metal alloc] initWithFrame:frame];
        if (nsView == NULL) {
            fprintf(stderr, "Error: Failed to create metal view\n");
            free(contentView); // Clean up the allocated memory for contentView
            return NULL;
        }

        mview->_this = (__bridge void*)nsView; // Store the Objective-C instance in _this
        [nsView setWantsLayer:YES]; // Enable layer backing

        [nsView.layer setBackgroundColor:bgColor.CGColor]; // Set the background color
        [nsView setNeedsDisplay:YES];
        contentView->view.m_view = *mview; // Assign the created nview to the contentView's UView

        // Get the NSWindow from the parent M_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:nsView]; // Set the content view of the parent window
    }
    else if (type == M_VIEW_TYPE_TABLE)
    {
        M_TView* tview = (M_TView*)malloc(sizeof(M_TView));
        if (tview == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory for table view\n");
            free(contentView);
            return NULL;
        }
        tview->size.width = parent->size.width;
        tview->size.height = parent->size.height;
        tview->position.x = 0;
        tview->position.y = 0;
        tview->background_color = background_color;
        tview->window_parent = parent;
        tview->id = viewIDCounter++;
        tview->is_content_view = true;

        M_NSTableView *nsView = [[M_NSTableView alloc] initWithFrame:frame];
        if (nsView == NULL) {
            fprintf(stderr, "Error: Failed to create table view\n");
            free(contentView);
            return NULL;
        }

        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:frame];
        if (scrollView == NULL) {
            fprintf(stderr, "Error: Failed to create scroll view\n");
            free(contentView);
            return NULL;
        }
        [scrollView setDocumentView:nsView];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [scrollView setAutohidesScrollers:YES];
        [nsView setWantsLayer:YES];
        [nsView.layer setBackgroundColor:bgColor.CGColor];
        [nsView setNeedsDisplay:YES];

        tview->_this = (__bridge void*)nsView;
        contentView->view.t_view = *tview;

        // Get the NSWindow from the parent M_Window
        NSWindow* parentNSWindow = (__bridge NSWindow*)parent->delegate;
        [parentNSWindow setContentView:scrollView]; // Set the scroll view as the content view of the parent window

    }
    return contentView;
}

void M_ChangeViewBGColor(M_View* view, M_Color color)
{
    if (view == NULL)
    {
        printf("ERROR: View is NULL. Cannot change background color.\n");
        return;
    }

    NSColor* nsColor = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];

    if (view->type == M_VIEW_TYPE_NORMAL)
    {
        M_NSView_Normal* nsView = (__bridge M_NSView_Normal*)view->view.n_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else if (view->type == M_VIEW_TYPE_CORE_G)
    {
        M_NSView_Core_G* nsView = (__bridge M_NSView_Core_G*)view->view.r_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else if (view->type == M_VIEW_TYPE_METAL)
    {
        M_NSView_Metal* nsView = (__bridge M_NSView_Metal*)view->view.m_view._this;
        [nsView.layer setBackgroundColor:nsColor.CGColor];
        [nsView setNeedsDisplay:YES];
    }
    else
    {
        printf("ERROR: Unsupported view type. Cannot change background color.\n");
    }
}

void M_HideView(M_View* view) 
{
    if (view == NULL) {
        printf("ERROR: View is NULL. Cannot hide the view.\n");
        return;
    }

    NSView* nsView = getViewFromMacView(view);

    [nsView setHidden:YES];
}

void M_ShowView(M_View *view)
{
    if (view == NULL) {
        printf("ERROR: View is NULL. Cannot hide the view.\n");
        return;
    }

    NSView* nsView = getViewFromMacView(view);

    [nsView setHidden:NO];
}

void M_DestroyView(M_View* view)
{
    if (view == NULL) {
        return;
    }

    if (view->type == M_VIEW_TYPE_NORMAL) {
        M_NView* nview = &view->view.n_view;
        M_NSView_Normal* nsview = (__bridge M_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
    }
    if (view->type == M_VIEW_TYPE_CORE_G) {
        M_RView* rview = &view->view.r_view;
        M_NSView_Core_G* nsview = (__bridge M_NSView_Core_G*)rview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
    }

    free(view); // Free the view itself
}

void M_DestroyContentView(M_View* contentView) {
    if (contentView == NULL) {
        return;
    }

    if (contentView->type == M_VIEW_TYPE_NORMAL) {
        M_NView* nview = &contentView->view.n_view;
        M_NSView_Normal* nsview = (__bridge M_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview];
    }
    else if (contentView->type == M_VIEW_TYPE_CORE_G) {
        M_RView* rview = &contentView->view.r_view;
        M_NSView_Core_G* nsview = (__bridge M_NSView_Core_G*)rview->_this;
        [nsview removeFromSuperview];
    }
    else if (contentView->type == M_VIEW_TYPE_TABLE) {
        M_TView* tview = &contentView->view.t_view;
        M_NSTableView* nsview = (__bridge M_NSTableView*)tview->_this;
        [nsview removeFromSuperview];
    }

    free(contentView);
}