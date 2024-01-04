#import "MWindow.h"
#import "MApp.h"
#import "MError.h"

#import <Cocoa/Cocoa.h>

MWindow *MCreateMainWindow(int width, int height, const char *title)
{
    MWindow *window = (MWindow *)malloc(sizeof(MWindow));
    if (window == NULL)
    {
        NSLog(@"Failed to allocate memory for window");
        return NULL;
    }

    window->title = title;
    window->width = width;
    window->height = height;

    window->flags = 0;
    window->parent = NULL;
    window->children = NULL;
    window->childCount = 0;

    window->contentView = NULL;

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;

    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];

    if (nsWindow == nil)
    {
        NSLog(@"Failed to create ns window");
        free(window);
        return NULL;
    }

    MAppDelegate *appDelegate = [[MAppDelegate alloc] init];

    [nsWindow setDelegate:appDelegate];
    [nsWindow setTitle:[NSString stringWithUTF8String:title]];
    [nsWindow makeKeyAndOrderFront:nil];

    window->_this = (__bridge void *)nsWindow;

    return window;
}

MWindow *MCreateChildWindow(MWindow *parent, int width, int height, const char *title)
{
    return NULL;
}

void MSetWindowHints(MWindow *window, uint32_t flags)
{
    if (window == NULL)
    {
        NSLog(@"Window is null");
        return;
    }

    window->flags = flags;

    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;

    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    if (flags & MWINDOW_FLAG_RESIZABLE)
    {
        styleMask |= NSWindowStyleMaskResizable;
    }
    if (flags & MWINDOW_FLAG_MAXIMIZABLE)
    {
        styleMask |= NSWindowStyleMaskMiniaturizable;
    }
    if (flags & MWINDOW_FLAG_MINIMIZABLE)
    {
        styleMask |= NSWindowStyleMaskMiniaturizable;
    }

    [nsWindow setStyleMask:styleMask];
}

int MWindowShouldClose(MWindow *window)
{
     if (!window) 
    {
        NSLog(@"Window is null");
        return M_ERROR_NULL_POINTER;
    }

    NSWindow *nsWindow = (__bridge NSWindow *)window->_this;
    return [nsWindow isVisible] || [nsWindow isMiniaturized];
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