#import "MApplication.h"
#include "MDefs.h"
#include "MError.h"

@implementation MAppDelegate

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
//     if (self == nil) {
//         return NO;
//     }
//     return YES;
// }

@end

@implementation MWindowDelegate
@end 

MError MApplicationInit(MApplication *app, int argc, char **argv)
{
    app->_delegate = [[MAppDelegate alloc] init];

    if (!app->_delegate)
    {
        NSLog(@"Failed to initialize app delegate");
        return M_ERROR_INIT;
    }

    [NSApp setDelegate:app->_delegate];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    // [NSApp acceptsFirstResponder];
    [NSApp activateIgnoringOtherApps:YES];
    // [NSApp activate];

    return M_SUCCESS; 
}

void MRunApplication()
{
    NSEvent *event;
    do {
        event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                   untilDate:[NSDate distantPast]
                                   inMode:NSDefaultRunLoopMode
                                   dequeue:YES];
        if (event) {
            [NSApp sendEvent:event];
            [NSApp updateWindows];
        }
    } while (event);
}

MWindow *MMainAppWindow(int width, int height, const char *title)
{
    MWindow *window = (MWindow *)malloc(sizeof(MWindow));
    if (window == NULL)
    {
        NSLog(@"Failed to allocate memory for window");
        return NULL;
    }

    window->_delegate = [[MWindowDelegate alloc] init];
    if (window->_delegate == nil)
    {
        NSLog(@"Failed to initialize window delegate");
        free(window);
        return NULL;
    }
    window->_window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    if (window->_window == nil)
    {
        NSLog(@"Failed to create ns window");
        free(window);
        return NULL;
    }

    [window->_window setTitle:[NSString stringWithUTF8String:title]];
    [window->_window setDelegate:window->_delegate];
    [window->_window center];
    [window->_window makeKeyAndOrderFront:nil];

    window->title = title;
    window->width = width;
    window->height = height;

    window->flags = 0;
    window->parent = NULL;
    window->children = NULL;
    window->childCount = 0;

    window->contentView = NULL;

    return window;
}

MBool MWindowShouldClose(MWindow *window)
{
    if (window == NULL) 
    {
        NSLog(@"Window is null");
        return M_ERROR_NULL_POINTER;
    }

    return [window->_window isVisible] || [window->_window isMiniaturized];
}

void MDestroyWindow(MWindow *window)
{
    if (window == NULL)
    {
        NSLog(@"Window is null");
        return;
    }

    if (window->contentView != NULL)
    {
        free(window->contentView);
    }

    [window->_window close];
    [window->_window release];
    free(window);
}