#include "MACA/mac_view.h"
#include "MACA/mac_window.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <Foundation/Foundation.h>

@implementation Mac_NSView_Normal
@end

@implementation Mac_NSView_Core_G
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

    if (type & MAC_VIEW_TYPE_NORMAL)
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

        Mac_NSView_Normal* nsview = [[Mac_NSView_Normal alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        nview->_this = (__bridge void*)nsview;
        subView->view.n_view = *nview;

        Mac_NSView_Normal* parentNSView = (__bridge Mac_NSView_Normal*)parent->view.n_view._this;
        [parentNSView addSubview:nsview];
    }
    if (type & MAC_VIEW_TYPE_CORE_G)
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

        Mac_NSView_Core_G* nsview = [[Mac_NSView_Core_G alloc] initWithFrame:frame];
        [nsview setWantsLayer:YES];
        [nsview.layer setBackgroundColor:bgColor.CGColor];
        [nsview.layer setCornerRadius:corner_radius];
        [nsview setNeedsDisplay:YES];
        [nsview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        rview->_this = (__bridge void*)nsview;
        subView->view.r_view = *rview;

        Mac_NSView_Core_G* parentNSView = (__bridge Mac_NSView_Core_G*)parent->view.r_view._this;
        [parentNSView addSubview:nsview];
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

    if (type & MAC_VIEW_TYPE_NORMAL)
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
    if (type & MAC_VIEW_TYPE_CORE_G)
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

void MAC_DestroyView(Mac_View* view)
{
    if (view == NULL) {
        return;
    }

    if (view->type & MAC_VIEW_TYPE_NORMAL) {
        Mac_NView* nview = &view->view.n_view;
        Mac_NSView_Normal* nsview = (__bridge Mac_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
    }
    if (view->type & MAC_VIEW_TYPE_CORE_G) {
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

    if (contentView->type & MAC_VIEW_TYPE_NORMAL) {
        Mac_NView* nview = &contentView->view.n_view;
        Mac_NSView_Normal* nsview = (__bridge Mac_NSView_Normal*)nview->_this;
        [nsview removeFromSuperview]; // Remove the Objective-C view from its superview
        free(nview);
    }

    free(contentView);
}
