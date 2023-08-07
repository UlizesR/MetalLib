// mac_window.m
#import "MAC/mac_window.h"
#import "MAC/mac_view.h"
#import "MAC/mac_error.h"
#import "MAC/mac_delegate.h"
#include <stdio.h>
#import <Cocoa/Cocoa.h>

@implementation Mac_WindowDelegate
@end

Mac_Window* createWindow(int width, int height, bool is_main_window, MTitle title, Mac_Color background_color, UInt32 flags) {
    Mac_Window* window = (Mac_Window*)malloc(sizeof(Mac_Window));
    if(window == NULL) {
        mac_printError(MAC_ERROR_WINDOW_CREATION_FAILED);
        return NULL;
    }
    
    window->size.width = width;
    window->size.height = height;
    window->title = title;
    window->background_color = background_color;
    window->is_main_window = is_main_window;
    window->flags = flags;

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    setWindowFlags(window, flags);
    [nsWindow setTitle:[NSString stringWithUTF8String:title]];
    
    window->content_view = addContentView(window, background_color);

    // Set the content view of the NSWindow
    Mac_NSView* nsView = (__bridge Mac_NSView*)window->content_view->_this;
    [nsWindow setContentView:nsView];
    [nsWindow setViewsNeedDisplay:YES];

    [nsWindow makeKeyAndOrderFront:nil];
    window->id = [nsWindow windowNumber];

    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    return window;
}


void closeWindow(Mac_Window* window) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    [nsWindow close];
}

bool isWindowOpen(Mac_Window* window) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    return nsWindow && ([nsWindow isVisible] || [nsWindow isMiniaturized]);
}

void destroyWindow(Mac_Window* window) {
    closeWindow(window);
    free(window);
    printf("Window has been deallocated and freed.\n");
}

void addChildWindow(Mac_Window* parent, Mac_Window* child) {
    NSWindow *parentWindow = [NSApp windowWithWindowNumber:parent->id];
    NSWindow *childWindow = [NSApp windowWithWindowNumber:child->id];
    [parentWindow addChildWindow:childWindow ordered:NSWindowAbove];
}

void removeChildWindow(Mac_Window* parent, Mac_Window* child) {
    NSWindow *parentWindow = [NSApp windowWithWindowNumber:parent->id];
    NSWindow *childWindow = [NSApp windowWithWindowNumber:child->id];
    [parentWindow removeChildWindow:childWindow];
}

void setWindowFlags(Mac_Window* window, UInt32 flags) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    if (flags & MAC_WINDOW_RESIZABLE) {
        [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskResizable];
    }
    if (flags & MAC_WINDOW_MINIMIZED) {
        [nsWindow miniaturize:nil];
    }
    if (flags & MAC_WINDOW_MAXIMIZED) {
        [nsWindow zoom:nil];
    }
    if (flags & MAC_WINDOW_FULLSCREEN) {
        [nsWindow toggleFullScreen:nil];
    }
    window->flags = flags; // Update the window's flags
}

void runWindow() {
    runDelegate();
}
