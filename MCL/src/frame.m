#import "MCL/frame.h"
#include <AppKit/AppKit.h>
#import "MCL/window.h"

#import <Cocoa/Cocoa.h>

void MCL_SetWindowFrame(MCL_Window *window, MCL_Color color)
{
    // check if the window is not null
    if (!window)
    {
        fprintf(stderr, "Failed to set the window frame! The window is null!\n");
        return;
    }
    // set the window main frame
    // allocate memory for the window frame and check if the allocation was successful
    window->window_frame = (MCL_Frame *)malloc(sizeof(MCL_Frame));
    if (!window->window_frame)
    {
        fprintf(stderr, "Failed to allocate memory for the window frame!\n");
        return;
    }
    // set the window frame properties
    window->window_frame->width = window->width;
    window->window_frame->height = window->height;
    window->window_frame->x = 0;
    window->window_frame->y = 0;
    window->window_frame->corner_radius = 0;
    window->window_frame->bg_color = color;
    // create the ns window frame
    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    NSColor *nsColor = [NSColor colorWithSRGBRed:color.r green:color.g blue:color.b alpha:color.a];
    NSRect frame = NSMakeRect(0, 0, window->width, window->height);
    NSView *nsView = [[NSView alloc] initWithFrame:frame];
    // set the ns view properties
    [nsView setWantsLayer:YES];                          // set the view to use a layer so we can set the background color
    [nsView.layer setBackgroundColor:nsColor.CGColor];   // set the background color
    [nsWindow setContentView:nsView];                    // set the ns view as the content view of the ns window
    // set ns view
    window->window_frame->_this = (__bridge void *)nsView;
}

void MCL_AddFrame(MCL_Frame *pframe, MCL_Frame *cframe, bool resizable) 
{
    // check if the parent frame is not null
    if (!pframe)
    {
        fprintf(stderr, "Failed to add a frame! The parent frame is null!\n");
        return;
    }
    // check if the child frame is not null
    if (!cframe)
    {
        fprintf(stderr, "Failed to add a frame! The child frame is null!\n");
        return;
    }
    // get the parent ns view
    NSView *pview = (__bridge NSView *)pframe->_this;
    // create the child ns view
    NSRect frame = NSMakeRect(cframe->x, cframe->y, cframe->width, cframe->height);
    NSColor *color = [NSColor colorWithSRGBRed:cframe->bg_color.r green:cframe->bg_color.g blue:cframe->bg_color.b alpha:cframe->bg_color.a];
    NSView *cview = [[NSView alloc] initWithFrame:frame];
    // set the ns view properties
    [cview setWantsLayer:YES];                              // set the view to use a layer so we can set the background color
    [cview.layer setBackgroundColor:color.CGColor];         // set the background color
    [cview.layer setCornerRadius:cframe->corner_radius];    // set the corner radius
    // set the autoresizing mask
    if (resizable)
        [cview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable]; 
    // add the child view to the parent view
    [pview addSubview:cview];                               
    [pview setNeedsDisplay:YES];                            // redraw the view

    cframe->_this = (__bridge void *)cview;
}

void MCL_ChangeFrameColor(MCL_Frame *frame, MCL_Color color)
{
    // check if the frame is not null
    if (!frame)
    {
        fprintf(stderr, "Failed to change the frame color! The frame is null!\n");
        return;
    }
    // get the ns color
    NSColor *nsColor = [NSColor colorWithSRGBRed:color.r green:color.g blue:color.b alpha:color.a];
    // get the ns view
    NSView *view = (__bridge NSView *)frame->_this;
    // set the background color
    [view.layer setBackgroundColor:nsColor.CGColor];
    // redraw the view
    [view setNeedsDisplay:YES];

}

void MCL_HideFrame(MCL_Frame *frame)
{
    // check if the frame is not null
    if (!frame)
    {
        fprintf(stderr, "Failed to hide the frame! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *view = (__bridge NSView *)frame->_this;
    // hide the view
    [view setHidden:YES];
}

void MCL_ShowFrame(MCL_Frame *frame)
{
    // check if the frame is not null
    if (!frame)
    {
        fprintf(stderr, "Failed to show the frame! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *view = (__bridge NSView *)frame->_this;
    // show the view
    [view setHidden:NO];
}