#import "MKLWindow.h"
#include "Core/MKLTimer.h"
#import "Core/MKLError.h" 

@implementation MklDelegate

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title 
                                width:(int)width 
                               height:(int)height
                                flags:(uint32_t)flags
{
    self = [super init];
    if (!self)
    {
        fprintf(stderr, "MKL Error: Failed to allocate MklDelegate\n");
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to allocate memory for MklDelegate";
        return nil;
    }

    const NSRect frame = NSMakeRect(0, 0, width, height);
    
    // Build style mask based on flags
    NSWindowStyleMask styleMask = 0;
    
    if (flags & MKL_WINDOW_UNDECORATED)
    {
        styleMask = NSWindowStyleMaskBorderless;
    }
    else
    {
        styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
        
        if (flags & MKL_WINDOW_RESIZABLE)
        {
            styleMask |= NSWindowStyleMaskResizable;
        }
        
        styleMask |= NSWindowStyleMaskMiniaturizable;
    }

    self.window = [[NSWindow alloc] initWithContentRect:frame 
                                              styleMask:styleMask 
                                                backing:NSBackingStoreBuffered 
                                                  defer:NO];

    if (!self.window)
    {
        fprintf(stderr, "MKL Error: Failed to allocate NSWindow\n");
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to allocate memory for NSWindow";
        return nil;
    }

    [self.window setTitle:title];
    [self.window center];
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window setDelegate:self];
    
    // Apply window flags
    if (flags & MKL_WINDOW_TOPMOST)
    {
        [self.window setLevel:NSFloatingWindowLevel];
    }
    
    if (flags & MKL_WINDOW_MOUSE_PASSTHROUGH)
    {
        [self.window setIgnoresMouseEvents:YES];
    }
    
    // Show window unless hidden flag is set
    if (!(flags & MKL_WINDOW_HIDDEN))
    {
        [self.window makeKeyAndOrderFront:nil];
        
        // Focus unless unfocused flag is set
        if (!(flags & MKL_WINDOW_UNFOCUSED))
        {
            [self.window makeMainWindow];
        }
    }
    
    if (flags & MKL_WINDOW_MINIMIZED)
    {
        [self.window miniaturize:nil];
    }
    else if (flags & MKL_WINDOW_MAXIMIZED)
    {
        [self.window zoom:nil];
    }

    return self;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    (void)aNotification;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification 
{
    (void)aNotification;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    (void)sender;
    return YES;
}

#pragma mark - NSWindowDelegate

- (void)windowDidMove:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        const NSRect frame = [self.window frame];
        window->posX = (int)frame.origin.x;
        window->posY = (int)frame.origin.y;
        
        if (window->callbacks.windowPosCallback)
        {
            window->callbacks.windowPosCallback(window->posX, window->posY);
        }
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        const NSRect frame = [self.window contentRectForFrameRect:[self.window frame]];
        window->width = (int)frame.size.width;
        window->height = (int)frame.size.height;
        
        if (window->callbacks.windowSizeCallback)
        {
            window->callbacks.windowSizeCallback(window->width, window->height);
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification 
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        window->shouldClose = true;
        
        if (window->callbacks.windowCloseCallback)
        {
            window->callbacks.windowCloseCallback();
        }
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        window->focused = true;
        
        if (window->callbacks.windowFocusCallback)
        {
            window->callbacks.windowFocusCallback(true);
        }
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        window->focused = false;
        
        if (window->callbacks.windowFocusCallback)
        {
            window->callbacks.windowFocusCallback(false);
        }
    }
}

- (void)windowDidMiniaturize:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        window->minimized = true;
        
        if (window->callbacks.windowIconifyCallback)
        {
            window->callbacks.windowIconifyCallback(true);
        }
    }
}

- (void)windowDidDeminiaturize:(NSNotification *)notification
{
    (void)notification;
    
    if (self.mklWindow)
    {
        MKLWindow *window = (MKLWindow *)self.mklWindow;
        window->minimized = false;
        
        if (window->callbacks.windowIconifyCallback)
        {
            window->callbacks.windowIconifyCallback(false);
        }
    }
}

@end

#pragma mark - Window Creation and Destruction

MKLWindow *MKLCreateWindow(const int width, const int height, const char *title)
{
    return MKLCreateWindowEx(width, height, title, 0);
}

MKLWindow *MKLCreateWindowEx(const int width, const int height, const char *title, const uint32_t flags)
{
    if (!title)
    {
        fprintf(stderr, "MKL Error: NULL title provided to MKLCreateWindow\n");
        gError.type = MKL_ERROR_NULL_POINTER;
        gError.message = "NULL title provided";
        return NULL;
    }

    if (width <= 0 || height <= 0)
    {
        fprintf(stderr, "MKL Error: Invalid window dimensions (%dx%d)\n", width, height);
        gError.type = MKL_ERROR_UNKNOWN;
        gError.message = "Invalid window dimensions";
        return NULL;
    }

    // Allocate memory for the window structure
    MKLWindow *window = (MKLWindow *)calloc(1, sizeof(MKLWindow));
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                   "Failed to allocate memory for MKLWindow", NULL);

    // Store window properties
    window->width = width;
    window->height = height;
    window->title = title;
    window->flags = flags;
    window->shouldClose = false;
    window->focused = !(flags & MKL_WINDOW_UNFOCUSED);
    window->minimized = (flags & MKL_WINDOW_MINIMIZED) != 0;
    window->maximized = (flags & MKL_WINDOW_MAXIMIZED) != 0;
    window->hidden = (flags & MKL_WINDOW_HIDDEN) != 0;

    // Create the Delegate
    NSString *titleString = [NSString stringWithUTF8String:title];
    MklDelegate *delegate = [[MklDelegate alloc] initWithTitle:titleString 
                                                         width:width 
                                                        height:height
                                                         flags:flags];
    MKL_NULL_CHECK(delegate, window, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                   "Failed to allocate memory for MklDelegate", NULL);

    window->_nswindow = delegate.window;
    window->_delegate = (__bridge void *)delegate;
    delegate.mklWindow = window;

    [NSApp setDelegate:delegate];

    // Make the application run as a regular app, not a menu bar app
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    // Get initial position
    const NSRect frame = [window->_nswindow frame];
    window->posX = (int)frame.origin.x;
    window->posY = (int)frame.origin.y;

    MKLInitTimer();

    return window;
}

void MKLDestroyWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, 
                        "Failed to destroy window: window is NULL");

    if (window->_nswindow)
    {
        [window->_nswindow close];
        window->_nswindow = nil;
    }
    
    window->_delegate = NULL;
    free(window);
}

#pragma mark - Window State Control

void MKLCloseWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, 
                        "Failed to close window: window is NULL");
    
    window->shouldClose = true;
    
    if (window->_nswindow)
    {
    [window->_nswindow close];
}
}

bool MKLWindowShouldClose(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, 
                   "Failed to check if window should close: window is NULL", true);
    
    if (!window->_nswindow)
    {
        return true;
    }
    
    if (window->shouldClose)
    {
        return true;
    }
    
    // Return true if window is not visible (closed)
    return ![window->_nswindow isVisible];
}

void MKLSetWindowShouldClose(MKLWindow *window, const bool shouldClose)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, 
                        "Failed to set window should close: window is NULL");
    
    window->shouldClose = shouldClose;
}

#pragma mark - Window State Queries

bool MKLIsWindowFocused(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return [window->_nswindow isKeyWindow];
    }
    return false;
}

bool MKLIsWindowMinimized(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return [window->_nswindow isMiniaturized];
    }
    return window->minimized;
}

bool MKLIsWindowMaximized(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return [window->_nswindow isZoomed];
    }
    return window->maximized;
}

bool MKLIsWindowHidden(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return ![window->_nswindow isVisible];
    }
    return window->hidden;
}

bool MKLIsWindowVisible(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return [window->_nswindow isVisible];
    }
    return !window->hidden;
}

#pragma mark - Window Manipulation

void MKLSetWindowTitle(MKLWindow *window, const char *title)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    MKL_NULL_CHECK_VOID(title, NULL, MKL_ERROR_NULL_POINTER, "Title is NULL");
    
    window->title = title;
    
    if (window->_nswindow)
    {
        NSString *titleString = [NSString stringWithUTF8String:title];
        [window->_nswindow setTitle:titleString];
    }
}

void MKLSetWindowPosition(MKLWindow *window, const int x, const int y)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    window->posX = x;
    window->posY = y;
    
    if (window->_nswindow)
    {
        const NSPoint point = NSMakePoint(x, y);
        [window->_nswindow setFrameOrigin:point];
    }
}

void MKLGetWindowPosition(MKLWindow *window, int *x, int *y)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        const NSRect frame = [window->_nswindow frame];
        if (x) *x = (int)frame.origin.x;
        if (y) *y = (int)frame.origin.y;
    }
    else
    {
        if (x) *x = window->posX;
        if (y) *y = window->posY;
    }
}

void MKLSetWindowSize(MKLWindow *window, const int width, const int height)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (width <= 0 || height <= 0)
    {
        fprintf(stderr, "MKL Warning: Invalid window size (%dx%d)\n", width, height);
        return;
    }
    
    window->width = width;
    window->height = height;
    
    if (window->_nswindow)
    {
        NSRect frame = [window->_nswindow frame];
        frame.size = NSMakeSize(width, height);
        [window->_nswindow setFrame:frame display:YES animate:NO];
    }
}

void MKLGetWindowSize(MKLWindow *window, int *width, int *height)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        const NSRect frame = [window->_nswindow contentRectForFrameRect:[window->_nswindow frame]];
        if (width) *width = (int)frame.size.width;
        if (height) *height = (int)frame.size.height;
    }
    else
    {
        if (width) *width = window->width;
        if (height) *height = window->height;
    }
}

void MKLMinimizeWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    window->minimized = true;
    
    if (window->_nswindow)
    {
        [window->_nswindow miniaturize:nil];
    }
}

void MKLMaximizeWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    window->maximized = true;
    
    if (window->_nswindow && ![window->_nswindow isZoomed])
    {
        [window->_nswindow zoom:nil];
    }
}

void MKLRestoreWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        if ([window->_nswindow isMiniaturized])
        {
            [window->_nswindow deminiaturize:nil];
            window->minimized = false;
        }
        else if ([window->_nswindow isZoomed])
        {
            [window->_nswindow zoom:nil];
            window->maximized = false;
        }
    }
}

void MKLShowWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    window->hidden = false;
    
    if (window->_nswindow)
    {
        [window->_nswindow makeKeyAndOrderFront:nil];
    }
}

void MKLHideWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    window->hidden = true;
    
    if (window->_nswindow)
    {
        [window->_nswindow orderOut:nil];
    }
}

void MKLFocusWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        [window->_nswindow makeKeyAndOrderFront:nil];
        [window->_nswindow makeMainWindow];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

void MKLCenterWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        [window->_nswindow center];
        
        // Update stored position
        const NSRect frame = [window->_nswindow frame];
        window->posX = (int)frame.origin.x;
        window->posY = (int)frame.origin.y;
    }
}

#pragma mark - Window Attributes

void MKLSetWindowOpacity(MKLWindow *window, const float opacity)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    const float clampedOpacity = fminf(1.0f, fmaxf(0.0f, opacity));
    
    if (window->_nswindow)
    {
        [window->_nswindow setAlphaValue:clampedOpacity];
    }
}

float MKLGetWindowOpacity(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", 1.0f);
    
    if (window->_nswindow)
    {
        return (float)[window->_nswindow alphaValue];
    }
    return 1.0f;
}

void MKLToggleFullscreen(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    
    if (window->_nswindow)
    {
        [window->_nswindow toggleFullScreen:nil];
    }
}

bool MKLIsWindowFullscreen(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL", false);
    
    if (window->_nswindow)
    {
        return ([window->_nswindow styleMask] & NSWindowStyleMaskFullScreen) != 0;
    }
    return false;
}

#pragma mark - Window Callbacks

void MKLSetWindowPosCallback(MKLWindow *window, void (*callback)(int x, int y))
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    window->callbacks.windowPosCallback = callback;
}

void MKLSetWindowSizeCallback(MKLWindow *window, void (*callback)(int width, int height))
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    window->callbacks.windowSizeCallback = callback;
}

void MKLSetWindowCloseCallback(MKLWindow *window, void (*callback)(void))
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    window->callbacks.windowCloseCallback = callback;
}

void MKLSetWindowFocusCallback(MKLWindow *window, void (*callback)(bool focused))
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Window is NULL");
    window->callbacks.windowFocusCallback = callback;
}
