#import "MCL2/MCLCore/MCLWindow.h"
#import "MCL2/MCLCore/MCLApplication.h"

#import <Cocoa/Cocoa.h>

@implementation WindowDelegate
@end

void MCL_AppWindow(MCL_App *app, int width, int height, const char *title) {
    // check if the app is initialized
    if (!app->is_init) {
        fprintf(stderr, "Failed to create a window! The app is not initialized!\n");
        return;
    }
    // allocate memory for the window and check if the allocation was successful
    app->app_window = (MCL_Window *)malloc(sizeof(MCL_Window));
    if (!app->app_window) {
        fprintf(stderr, "Failed to allocate memory for the window\n");
        return;
    }
    // check the width and height
    if (width <= 0 || height <= 0) {
        fprintf(stderr, "Invalid window size! Setting the window size to 800x600\n");
        width = 800;
        height = 600;
    }
    // set the window properties
    app->app_window->width = width;
    app->app_window->height = height;
    app->app_window->title = title;
    app->app_window->flags = 0;
    app->app_window->content_view = NULL;
    app->app_window->app_window = true;
    // create the ns window
    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                     styleMask:style
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    if (!nsWindow) {
        fprintf(stderr, "Failed to create a window!\n");
        return;
    }
    // set the window title
    [nsWindow setTitle:@(title)];
    // set the app's delegate window
    app->nsDelegate.app_window = nsWindow;
    // set the window delegate
    [app->nsDelegate.app_window setDelegate:[[WindowDelegate alloc] init]];
    // window->delegate = (__bridge void *)nsWindow;
    app->app_window->_this = (__bridge void *)nsWindow;
    // set the window to visible
    [nsWindow makeKeyAndOrderFront:nil];
}

MCL_Window *MCL_ChildWindow(MCL_Window *parent, int width, int height, const char* title)
{
    // check if the parent window is null
    if (!parent)
    {
        fprintf(stderr, "Failed to create a child window! The parent window is null!\n");
        return NULL;
    }
    else if (!parent->app_window)
    {
        fprintf(stderr, "Failed to create a child window! The parent window is not an app window!\n");
        return NULL;
    }
    // allocate memory for the child window
    MCL_Window *child = (MCL_Window *)malloc(sizeof(MCL_Window));
    if (!child)
    {
        fprintf(stderr, "Failed to allocate memory for the child window!\n");
        return NULL;
    }
    // check the width and height
    if (width <= 0 || height <= 0)
    {
        fprintf(stderr, "Invalid window size! Setting the window size to half of the parent window size\n");
        width = parent->width / 2;
        height = parent->height / 2;
    }
    // set the child window properties
    child->width = width;
    child->height = height;
    child->title = title;
    child->flags = 0;
    child->content_view = NULL;
    child->app_window = false;
    // create the ns window
    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                     styleMask:style
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    if (!nsWindow)
    {
        fprintf(stderr, "Failed to create a child window!\n");
        return NULL;
    }
    // set the window title
    [nsWindow setTitle:@(title)];
    // set the parent window
    NSWindow *nsParentWindow = (__bridge NSWindow *)(parent->_this);
    [nsParentWindow addChildWindow:nsWindow ordered:NSWindowAbove];
    // set the child window delegate
    [nsWindow setDelegate:[[WindowDelegate alloc] init]];
    // set the child window
    child->_this = (__bridge void *)nsWindow;
    // set the window to visible
    [nsWindow makeKeyAndOrderFront:nil];
    // return the child window
    return child;
} 

void MCL_WindowHints(MCL_Window *window, uint32_t flags)
{
    // check if the window is not null
    if (!window)
    {
        fprintf(stderr, "Failed to set the window hints! The window is null!\n");
        return;
    }
    // get the ns window
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_this);
    // set the window hints
    // Set the window flags
    if (flags & MCL_WINDOW_FULLSCREEN) {
        if (flags & (MCL_WINDOW_MINIMIZED | MCL_WINDOW_RESIZABLE)) 
        {
            fprintf(stderr, "Error: Cannot set window to be both resizable and fullscreen\n");
        }
        [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskFullScreen];
    }
    if (flags & MCL_WINDOW_RESIZABLE) {
        [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskResizable];
        [nsWindow setMinSize:nsWindow.frame.size];
    }
    if (flags & MCL_WINDOW_MINIMIZED) {
        [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskMiniaturizable];
    }
}

void MCL_CloseWindow(MCL_Window *window) 
{
    // check if the window is NULL
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot close a NULL window\n");
        return;
    }
    // transform the window pointer to an NSWindow pointer
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_this);
    // close the window
    [nsWindow close];
}

bool MCL_IsWindowOpen(MCL_Window *window) 
{
    // check if the window is NULL
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot check if a NULL window is open\n");
        return false;
    }
    // transform the window pointer to an NSWindow pointer
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_this);
    // check if the window is open
    return ([nsWindow isMiniaturized] || [nsWindow isVisible]);
}

void MCL_DestroyWindow(MCL_Window *window) {
    // check if the window is NULL
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot destroy a NULL window\n");
        return;
    }
    // close the window
    MCL_CloseWindow(window);
    // release the window
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_this);
    [nsWindow release];
    // free the main frame
    if (window->content_view != NULL) {
        free(window->content_view);
    }
    // free the window
    free(window);
}