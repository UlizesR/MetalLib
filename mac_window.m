// mac_window.m
#import "mac_window.h"
#include <stdio.h>
#import <Cocoa/Cocoa.h>

MAC_Window* createWindow(int width, int height, const char* title) {
    MAC_Window* window = (MAC_Window*)malloc(sizeof(MAC_Window));
    window->width = width;
    window->height = height;
    window->title = title;

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSWindow *nsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    [nsWindow setTitle:[NSString stringWithUTF8String:title]];
    [nsWindow makeKeyAndOrderFront:nil];
    window->id = [nsWindow windowNumber];

    return window;
}

void runWindow() {
    [NSApp run];
}

void closeWindow(MAC_Window* window) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    [nsWindow close];
}

bool isWindowOpen(MAC_Window* window) {
    NSWindow *nsWindow = [NSApp windowWithWindowNumber:window->id];
    return nsWindow && [nsWindow isVisible];
}

void destroyWindow(MAC_Window* window) {
    closeWindow(window);
    free(window);
    printf("Window has been deallocated and freed.\n");
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

void setWindowFlag(MAC_Window* window, u_int32_t flags) {
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
}
