#import "window.h"
#import "delegate.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>

@implementation M_Window_Delegate
@end

static int windowIDCounter = 0;

M_Window *M_CreateWindow(int width, int height, bool is_main_window,
                         MTitle title, uint32_t flags) {
  // Allocate memory for the window
  M_Window *window = (M_Window *)malloc(sizeof(M_Window));
  // Check if the allocation was successful
  if (window == NULL) {
    fprintf(stderr, "Error: Failed to allocate memory for the window\n");
    return NULL;
  }
  // Set the window properties
  window->size.width = width;
  window->title = title;
  window->id = windowIDCounter++;
  window->flags = flags;
  window->is_main_window = is_main_window;
  window->parent = NULL;
  window->children = NULL;
  window->num_children = 0;
  window->content_view = NULL;
  // Create the corresponding Objective-C window object
  NSWindow *nsWindow;
  M_Window_Delegate *windowDelegate = [[M_Window_Delegate alloc] init];
  // Check if the window is the main window
  if (is_main_window) {
    globalDelegate.mainWindow = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, width, height)
                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    nsWindow = globalDelegate.mainWindow;
    nsWindow.delegate = windowDelegate;
    window->delegate = (__bridge void *)nsWindow;
  } else {
    nsWindow = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, width, height)
                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    nsWindow.delegate = windowDelegate;
    window->delegate = (__bridge void *)nsWindow;
    // Set the parent window
    window->parent = (__bridge M_Window *)globalDelegate.mainWindow;
    // Add the window to the global delegate's child windows array
    [globalDelegate.childWindows addObject:(__bridge id _Nonnull)(window)];
    M_Window *parentWindow = (__bridge M_Window *)globalDelegate.mainWindow;
    parentWindow->num_children++;
  }
  // Set the window title
  [nsWindow setTitle:[NSString stringWithUTF8String:title]];
  // Set the window flags
  if (flags & M_WINDOW_FULLSCREEN) {
    if (flags &
        (M_WINDOW_MINIMIZED | M_WINDOW_RESIZABLE)) // Fixed the condition
    {
      fprintf(stderr, "Error: Cannot set window to be both resizable and fullscreen\n");
    }
    [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskFullScreen];
  }
  if (flags & M_WINDOW_RESIZABLE) {
    [nsWindow setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskResizable];
    [nsWindow setMinSize:NSMakeSize(width, height)];
  }
  if (flags & M_WINDOW_MINIMIZED) {
    [nsWindow
        setStyleMask:[nsWindow styleMask] | NSWindowStyleMaskMiniaturizable];
  }
  // Set the the activation policy to regular
  [nsWindow makeKeyAndOrderFront:nil];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];
  // Return the window
  return window;
}

void M_CloseWindow(M_Window *window) {
  if (window == NULL) {
    fprintf(stderr, "Error: Cannot close a NULL window\n");
    return;
  }
  NSWindow *nsWindow = (__bridge NSWindow *)(window->delegate);
  [nsWindow close];

  // If this is the main window, close all child windows
  if (window->is_main_window) {
    M_Delegate *delegate = initDelegate();
    NSArray<NSWindow *> *childWindows = delegate.childWindows;
    for (NSWindow *childWindow in childWindows) {
      [childWindow close];
    }
  }
}

bool M_IsWindowOpen(M_Window *window) {
  if (window == NULL) {
    fprintf(stderr, "Error: Cannot check if a NULL window is open\n");
    return false;
  }
  NSWindow *nsWindow = (__bridge NSWindow *)(window->delegate);
  return [nsWindow isMiniaturized] || [nsWindow isVisible];
}

void M_DestroyWindow(M_Window *window) {
  if (window == NULL) {
    fprintf(stderr, "Error: Cannot destroy a NULL window\n");
    return;
  }
  M_CloseWindow(window);

  // Destroy the content view
  free(window->content_view);
  // Destroy child windows if this is the main window
  if (window->is_main_window) {
    NSArray<NSWindow *> *childWindows = globalDelegate.childWindows;
    for (NSWindow *childWindow in childWindows) {
      M_Window *childMacWindow = (__bridge M_Window *)(childWindow.delegate);
      M_DestroyWindow(childMacWindow); // Recursively destroy child windows
    }
  }
  free(window);
}
