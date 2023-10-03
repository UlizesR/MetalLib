#import "MCL2/MCLCore/MCLView.h"
#import "MCL2/MCLCore/MCLWindow.h"

#import <Cocoa/Cocoa.h>

void MCL_SetWindowView(MCL_Window *window, MCL_Color color) {
    // check if the window is not null
    if (!window) {
        fprintf(stderr, "Failed to set the window View! The window is null!\n");
        return;
    }
    // set the window main View
    // allocate memory for the window View and check if the allocation was
    // successful
    window->content_view = (MCL_View *)malloc(sizeof(MCL_View));
    if (!window->content_view) {
        fprintf(stderr, "Failed to allocate memory for the window View!\n");
        return;
    }
    // set the window View properties
    window->content_view->width = window->width;
    window->content_view->height = window->height;
    window->content_view->x = 0;
    window->content_view->y = 0;
    window->content_view->corner_radius = 0;
    window->content_view->bg_color = color;
    // create the ns window View
    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    NSColor *nsColor = [NSColor colorWithSRGBRed:color.r
                                            green:color.g
                                            blue:color.b
                                            alpha:color.a];
    NSRect frame = NSMakeRect(0, 0, window->width, window->height);
    NSView *nsView = [[NSView alloc] initWithFrame:frame];
    // set the ns view properties
    [nsView setWantsLayer:YES]; // set the view to use a layer so we can set the
                                // background color
    [nsView.layer setBackgroundColor:nsColor.CGColor]; // set the background color
    [nsWindow setContentView:nsView]; // set the ns view as the content view of
                                        // the ns window
    // set ns view
    window->content_view->_this = (__bridge void *)nsView;
}

void MCL_AddView(MCL_View *pView, MCL_View *cView, bool resizable) {
    // check if the parent View is not null
    if (!pView) {
        fprintf(stderr, "Failed to add a View! The parent View is null!\n");
        return;
    }
    // check if the child View is not null
    if (!cView) {
        fprintf(stderr, "Failed to add a View! The child View is null!\n");
        return;
    }
    // get the parent ns view
    NSView *pview = (__bridge NSView *)pView->_this;
    // create the child ns view
    NSRect frame = NSMakeRect(cView->x, cView->y, cView->width, cView->height);
    NSColor *color = [NSColor colorWithSRGBRed:cView->bg_color.r
                                        green:cView->bg_color.g
                                            blue:cView->bg_color.b
                                        alpha:cView->bg_color.a];
    NSView *cview = [[NSView alloc] initWithFrame:frame];
    // set the ns view properties
    [cview setWantsLayer:YES]; // set the view to use a layer so we can set the
                                // background color
    [cview.layer setBackgroundColor:color.CGColor]; // set the background color
    [cview.layer setCornerRadius:cView->corner_radius]; // set the corner radius
    // set the autoresizing mask
    if (resizable)
        [cview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    // add the child view to the parent view
    [pview addSubview:cview];
    [pview setNeedsDisplay:YES]; // redraw the view

    cView->_this = (__bridge void *)cview;
}

void MCL_ChangeViewColor(MCL_View *View, MCL_Color color) {
    // check if the View is not null
    if (!View) {
        fprintf(stderr, "Failed to change the View color! The View is null!\n");
        return;
    }
    // get the ns color
    NSColor *nsColor = [NSColor colorWithSRGBRed:color.r
                                            green:color.g
                                            blue:color.b
                                            alpha:color.a];
    // get the ns view
    NSView *view = (__bridge NSView *)View->_this;
    // set the background color
    [view.layer setBackgroundColor:nsColor.CGColor];
    // redraw the view
    [view setNeedsDisplay:YES];
}

void MCL_HideView(MCL_View *View) {
    // check if the View is not null
    if (!View) {
        fprintf(stderr, "Failed to hide the View! The View is null!\n");
        return;
    }
    // get the ns view
    NSView *view = (__bridge NSView *)View->_this;
    // hide the view
    [view setHidden:YES];
}

void MCL_ShowView(MCL_View *View) {
    // check if the View is not null
    if (!View) {
        fprintf(stderr, "Failed to show the View! The View is null!\n");
        return;
    }
    // get the ns view
    NSView *view = (__bridge NSView *)View->_this;
    // show the view
    [view setHidden:NO];
}

void MCL_UpdateView(MCL_View *View) {
    // check if the View is not null
    if (!View) {
        fprintf(stderr, "Failed to update the View! The View is null!\n");
        return;
    }
    // get the ns view
    NSView *view = (__bridge NSView *)View->_this;
    // redraw the view
    [view setNeedsDisplay:YES];
    [view displayIfNeeded];
}