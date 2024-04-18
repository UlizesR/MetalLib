#import "MTLCWindow.h"
#include <string.h>
#include "MTLCDefs.h"
#import "MTLCError.h"

@implementation  MTLCDelegate 


- (instancetype)initWithWindowWithErr:(MTLCError *)error
{
    self = [super init];
    if (self == nil) 
    {
        return nil;
    }
    // the default window size is 600x800 assuming the user does not specify the window size
    NSRect frame = NSMakeRect(0, 0, 600, 800);
    // the default window style mask is titled and closable
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;

    self.window = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];

    if (self.window == nil) 
    {
        MTLCSetError(error, MTLC_ERROR_NS_ALLOC, "Failed to allocate memory for the NSWindow");
        return nil;
    }

    [self.window center];
    [self.window makeKeyAndOrderFront:nil];

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
MTLCWindow* MTLCCreateWindow(const char* title, int width, int height, MTLCError* error)
{
    MTLCWindow* window = (MTLCWindow*)malloc(sizeof(MTLCWindow));
    if (window == NULL)
    {
        MTLCSetError(error, MTLC_ERROR_ALLOC, "Failed to allocate memory for the MTLCWindow");
        return NULL;
    }

    MTLCDelegate *delegate = [[MTLCDelegate alloc] initWithWindowWithErr:error];
    if (delegate == nil) 
    {
        free(window);
        MTLCSetError(error, MTLC_ERROR_NS_DELEGATE, "Failed to allocate the MTLCDelegate");
        return NULL;
    }

    window->ns.object = delegate.window;
    [window->ns.object setDelegate:delegate];
    [NSApp setDelegate:delegate];
    [delegate release];

    [window->ns.object setTitle:[NSString stringWithUTF8String:title]];
    // resize the window to the specified width and height
    if (width > 0 && height > 0)
    {
        NSRect frame = [window->ns.object frame];
        frame.size.width = width;
        frame.size.height = height;
        [window->ns.object setFrame:frame display:YES];
    } else {
        MTLCSetError(error, MTLC_ERROR_INVALID_INPUT, "Invalid window size");
        free(window);
        return NULL;
    }

    window->ns.contentView = [window->ns.object contentView];

    // set app policy
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    return window;
}

bool MTLCIsWindowOpen(MTLCWindow* window)
{
    if (window == NULL)
    {
        printf("Window is null");
        return false;
    }
    return [window->ns.object isVisible] || [window->ns.object isMiniaturized];
}

void MTLCCloseWindow(MTLCWindow* window)
{
    if (window == NULL)
    {
        printf("Window is null");
        return;
    }
    [window->ns.object close];
}

void MTLCDestroyWindow(MTLCWindow* window)
{
    if (window == NULL)
    {
        printf("Window is null");
        return;
    }
    if (window->ns.object != NULL)
    {
        [window->ns.object release];
    }
    free(window);
}