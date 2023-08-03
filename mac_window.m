// mac_window.m
#import "mac_window.h"
#import "mac_delegate.h"
#import <Cocoa/Cocoa.h>

MAC_Window createWindow(int width, int height, const char* title) {
    
    MAC_Window window;
    window.width = width;
    window.height = height;
    window.title = title;
    window.parent = NULL;
    window.children = NULL;
    window.flags = 0;

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];
    [nsWindow setTitle:[NSString stringWithUTF8String:title]];
    [nsWindow makeKeyAndOrderFront:nil];

    window.id = (MAC_WindowID)[nsWindow windowNumber];

    return window;
}

void runWindow() {
    printf("Running window\n");
    runDelegate();
}

void closeWindow(MAC_Window* window) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    [nsWindow close];
    printf("Closing window\n");
}

void addChildWindow(MAC_Window* parent, MAC_Window* child) {
    NSWindow *parentWindow = [NSApp windowWithWindowNumber:parent->id];
    NSWindow *childWindow = [NSApp windowWithWindowNumber:child->id];
    [parentWindow addChildWindow:childWindow ordered:NSWindowAbove];
}

void removeChildWindow(MAC_Window* parent, MAC_Window* child) {
    NSWindow *parentWindow = [NSApp windowWithWindowNumber:parent->id];
    NSWindow *childWindow = [NSApp windowWithWindowNumber:child->id];
    [parentWindow removeChildWindow:childWindow];
}

void setWindowFlag(MAC_Window* window, uint32_t flags) {
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
    // ... handle other flags as needed ...
}
