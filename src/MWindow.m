#import "MWindow.h"
#import "MDefs.h"
#import "MError.h"
#import "MApp.h"

#include <AppKit/AppKit.h>

MWindow *MCreateMainWindow(int width, int height, const char *title)
{
    MWindow *window = malloc(sizeof(MWindow));
    if (!window) 
    {
        NSLog(@"Failed to allocate memory for window");
        return NULL;
    }

    window->width = width;
    window->height = height;
    window->title = title;
    window->flags = 0;
    window->parent = NULL;
    window->children = NULL;
    window->child_count = 0;
    window->content_view = NULL;

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:NO];
    if (!nsWindow) 
    {
        NSLog(@"Failed to create NSWindow");
        return NULL;
    }

    MAppDelegate *appDelegate = [[MAppDelegate alloc] init];
    [nsWindow setTitle:@(title)];
    [nsWindow setDelegate:appDelegate];
    [nsWindow makeKeyAndOrderFront:nil];

    window->_this = (__bridge void *)nsWindow;

    return window;
}

int MWindowShouldClose(MWindow *window)
{
    if (!window) 
    {
        NSLog(@"Window is null");
        return MDL_ERROR_NULL_POINTER;
    }

    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    return [nsWindow isVisible] || [nsWindow isMiniaturized];
}

void MShowWindow(MWindow *window)
{
    if (!window) 
    {
        NSLog(@"Window is null");
        return;
    }

    // NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    // [NSApp sharedApplication];
    [NSApp run];
}

void MDestroyWindow(MWindow *window)
{
    if (!window) 
    {
        NSLog(@"Window is null");
        return;
    }

    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    [nsWindow release];
    window->_this = NULL;
    free(window);
}