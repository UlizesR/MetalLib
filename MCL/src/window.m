#import "MCL/window.h"
#import "MCL/errors.h"
#import "MCL/delegate.h"

#import <Cocoa/Cocoa.h>

@implementation WindowDelegate
@end

static int window_id_counter = 0;

void MCL_AppWindow(MCL_App *app, int width, int height, const char *title)
{
    // check if the app is initialized
    if (!app->is_init)
    {
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
    if (width <= 0 || height <= 0)
    {
        fprintf(stderr, "Invalid window size! Setting the window size to 800x600\n");
        width = 800;
        height = 600;
    }
    // set the window properties
    app->app_window->width = width;
    app->app_window->height = height;
    app->app_window->title = title;
    app->app_window->id = window_id_counter++;
    app->app_window->flags = 0;
    app->app_window->is_main_window = true;
    app->app_window->parent = NULL;
    app->app_window->children = NULL;
    app->app_window->num_children = 0;
    // create the ns window
    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:NO];
    if (!nsWindow)
    {
        fprintf(stderr, "Failed to create a window!\n");
        return;
    }
    // set the window title
    NSString *nsTitle = [NSString stringWithUTF8String:title];
    [nsWindow setTitle:nsTitle];
    // set the app's delegate window
    app->nsDelegate.app_window = nsWindow;
    // set the window delegate
    WindowDelegate *wDelegate = [[WindowDelegate alloc] init];
    [app->nsDelegate.app_window setDelegate:wDelegate];
    // window->delegate = (__bridge void *)nsWindow;
    app->app_window->_delegate = (__bridge void *)nsWindow;
    // set the window to visible
    [nsWindow makeKeyAndOrderFront:nil];
}

// TODO: Implement this function
// MCL_Window *MCL_ChildWindow(MCL_Window *parent, int width, int height, const char *title) {}

void MCL_CloseWindow(MCL_Window *window)
{
    // check if the window is NULL
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot close a NULL window\n");
        return;
    }
    // transform the window pointer to an NSWindow pointer
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_delegate);
    // close the window
    [nsWindow close];
}

void MCL_DestroyWindow(MCL_Window *window)
{
    // check if the window is NULL
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot destroy a NULL window\n");
        return;
    }
    // close the window
    MCL_CloseWindow(window);
    // release the window
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_delegate);
    [nsWindow release];
    // free the window
    free(window);
}

bool MCL_IsWindowOpen(MCL_Window *window) {
    if (window == NULL) {
        fprintf(stderr, "Error: Cannot check if a NULL window is open\n");
        return false;
    }
    NSWindow *nsWindow = (__bridge NSWindow *)(window->_delegate);
    return [nsWindow isMiniaturized] || [nsWindow isVisible];
}