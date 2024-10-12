#import "MKLWindow.h"
#include "Core/MKLTimer.h"
#import "Core/MKLError.h" 

@implementation MklDelegate // Updated class name

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title width:(int)width height:(int)height 
{
    self = [super init];
    MKL_NULL_CHECK(self, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "Failed to allocate memory for MklDelegate", nil)

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;

    self.window = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];

    MKL_NULL_CHECK(self.window, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "Failed to allocate memory for NSWindow", nil)

    [self.window setTitle:title];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    // [self.window setAcceptsMouseMovedEvents:YES];
    [self.window setDelegate:self];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    if (self == nil) {
        return;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification 
{
    if (self == nil) {
        return;
    }
}

- (void)windowWillClose:(NSNotification *)notification 
{
    if (self == nil) {
        return;
    }
}

@end

MKLWindow *MKLCreateWindow(int width, int height, const char *title)
{
    // Allocate memory for the window
    MKLWindow *window = (MKLWindow *)malloc(sizeof(MKLWindow));
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "Failed to allocate memory for MKLWindow", NULL)

    // Create the Delegate first so that it can be passed to the NSApplication
    NSString *titleString = [NSString stringWithUTF8String:title];
    MklDelegate *delegate = [[MklDelegate alloc] initWithTitle:titleString width:width height:height];
    MKL_NULL_CHECK(delegate, window, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "Failed to allocate memory for MklDelegate", NULL)

    window->_nswindow = delegate.window;

    [NSApp setDelegate:delegate];

    // Since we already set the delegate, we can release it
    [delegate release];

    // This will make the application run as a regular app, not a menu bar
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    MKLInitTimer();

    return window;
}

void MKLCloseWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Failed to close window. The window is NULL")
    [window->_nswindow close];
}

int MKLWindowShouldClose(MKLWindow *window)
{
    MKL_NULL_CHECK(window, NULL, MKL_ERROR_NULL_POINTER, "Failed to check if window should close. The window is NULL", 0)
    return [window->_nswindow isVisible] || [window->_nswindow isMiniaturized];
}

void MKLDestroyWindow(MKLWindow *window)
{
    MKL_NULL_CHECK_VOID(window, NULL, MKL_ERROR_NULL_POINTER, "Failed to destroy window. The window is NULL")

    if (window->_nswindow != NULL)
    {
        [window->_nswindow release];
    }
    free(window);
}