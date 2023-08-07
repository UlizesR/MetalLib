// mac_view.m
#import "MACA/mac_view.h"
#import "MACA/mac_window.h"

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

@implementation Mac_NSView

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


Mac_View* addSubView(Mac_View* parent, int width, int height, int x, int y, Mac_Color background_color) {
    Mac_View* view = (Mac_View*)malloc(sizeof(Mac_View));
    view->parent_view = parent;
    view->window_parent = parent->window_parent;
    view->size.width = width;
    view->size.height = height;
    view->position.x = x;
    view->position.y = y;
    view->background_color = background_color;
    view->is_root = false;
    view->is_metal_view = false;

    Mac_NSView* nsView = [[Mac_NSView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    [nsView setWantsLayer:YES];
    [nsView.layer setBackgroundColor:CGColorCreateGenericRGB(background_color.r, background_color.g, background_color.b, background_color.a)];

    // Assign the Mac_NSView instance to the _this member of the Mac_View struct
    view->_this = (__bridge void *)(nsView);

    NSView* parentNSView;
    if (parent->is_root) {
        Mac_WindowDelegate* delegate = (__bridge Mac_WindowDelegate*)parent->window_parent->delegate;
        parentNSView = delegate.content_view;
    } else {
        parentNSView = (__bridge NSView*)parent->parent_view;
    }
    [parentNSView addSubview:nsView];

    if (g_viewCount < MAX_VIEWS) {
        g_views[g_viewCount++] = view;
    }

    return view;
}

Mac_View* addContentView(Mac_Window* parent, Mac_Color background_color) {
    Mac_View* view = (Mac_View*)malloc(sizeof(Mac_View));
    view->parent_view = NULL;
    view->window_parent = parent;
    view->size.width = parent->size.width;
    view->size.height = parent->size.height;
    view->position.x = 0;
    view->position.y = 0;
    view->background_color = background_color;
    view->is_root = true;
    view->is_metal_view = false;

    Mac_NSView* nsView = [[Mac_NSView alloc] initWithFrame:NSMakeRect(0, 0, view->size.width, view->size.height)];
    [nsView setWantsLayer:YES];
    [nsView.layer setBackgroundColor:CGColorCreateGenericRGB(background_color.r, background_color.g, background_color.b, background_color.a)];

    // Assign the Mac_NSView instance to the _this member of the Mac_View struct
    view->_this = (__bridge void *)(nsView);

    if (g_viewCount < MAX_VIEWS) {
        g_views[g_viewCount++] = view;
    }

    return view;
}

void updateView(Mac_View* view, int shape_id) {
    Mac_NSView* nsView = (__bridge Mac_NSView*)view->_this;
    [nsView updateView:shape_id];
}


void destroyView(Mac_View* view) {
    Mac_WindowDelegate* delegate = (__bridge Mac_WindowDelegate*)view->window_parent->delegate;
    for (NSView* subview in delegate.content_view.subviews) {
        if ([subview isKindOfClass:[Mac_NSView class]]) {
            [subview removeFromSuperview];
        }
    }
    free(view);
}

void destroyViews(Mac_View* views[], int count) {
    for (int i = 0; i < count; i++) {
        destroyView(views[i]);
    }
}