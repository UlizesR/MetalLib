#import "MKLWindow.h"

#import "Input/Keyboard.h"

@implementation MklDelegate // Updated class name

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title width:(int)width height:(int)height 
{
    self = [super init];
    if (self == nil) {
        NSLog(@"Failed to initialize MklDelegate");
        return nil;
    }

    NSRect frame = NSMakeRect(0, 0, width, height);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;

    self.window = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];

    if (self.window == nil)
    {
        NSLog(@"Failed to create NSWindow");
        return nil;
    }

    [self.window setTitle:title];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    [self.window setAcceptsMouseMovedEvents:YES];
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

// - (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender 
// {
//     // if (self == nil) {
//     //     return NO;
//     // }
//     // return YES;
// }

- (void)windowWillClose:(NSNotification *)notification 
{
    if (self == nil) {
        return;
    }
    [NSApp terminate:nil];
}

// - (void)keyDown:(NSEvent * _Nonnull)event 
// {
//     [Keyboard setKeyPressed:event.keyCode isOn:YES];
//     if([Keyboard isKeyPressed:MKL_KEY_ESCAPE])
//     {
//         [NSApp terminate:nil];
//     }
// }

// - (void)keyUp:(NSEvent * _Nonnull)event 
// {
//     [Keyboard setKeyPressed:event.keyCode isOn:NO];
// }

@end

MKLWindow *MKLCreateWindow(int width, int height, const char *title)
{
    // Allocate memory for the window
    MKLWindow *window = (MKLWindow *)malloc(sizeof(MKLWindow));
    if (window == NULL) 
    {
        NSLog(@"Failed to allocate memory for window");
        return NULL;
    }
    // Create the Delegate first so that it can be passed to the NSApplication
    NSString *titleString = [NSString stringWithUTF8String:title];
    MklDelegate *delegate = [[MklDelegate alloc] initWithTitle:titleString width:width height:height];
    if (delegate == nil)
    {
        NSLog(@"Failed to create MklDelegate");
        free(window);
        return NULL;
    }
    window->_nswindow = delegate.window;
    delegate.app = [NSApplication sharedApplication];
    [delegate.app setDelegate:delegate];

    // This will make the application run as a regular app, not a menu bar
    [delegate.app setActivationPolicy:NSApplicationActivationPolicyRegular];
    [delegate.app activateIgnoringOtherApps:YES];

    return window;
}

void MKLShowWindow(MKLWindow *window)
{
    if (window == NULL) 
    {
        NSLog(@"Failed to show window. The window is NULL");
        return;
    }
    [NSApp run];
}

void MKLDestroyWindow(MKLWindow *window)
{
    if (window == NULL) 
    {
        NSLog(@"Failed to destroy window. The window is NULL");
        return;
    }
    if (window->_nswindow != NULL)
    {
        [window->_nswindow close];
    }
    free(window);
}