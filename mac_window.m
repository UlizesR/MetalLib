#import <Cocoa/Cocoa.h>

#import "mac_window.h"
#import "mac_delegate.h"
#import "mac_view.h"

#import <Metal/Metal.h>

Mac_Delegate *delegate;

Window createWindow(int width, int height, const char *title)
{
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        delegate = [[Mac_Delegate alloc] init];

        NSRect frame = NSMakeRect(0, 0, width, height);

        NSWindow *window = [
                [NSWindow alloc] initWithContentRect:frame
                styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                backing:NSBackingStoreBuffered 
                defer:NO
            ];

        Mac_View *view = [[Mac_View alloc] initWithFrame:frame];
        [window setContentView:view];

        [window center];
        [window setTitle:[NSString stringWithUTF8String:title]];
        [window makeKeyAndOrderFront:app];

        [window setDelegate:delegate];
        [app setDelegate:delegate];
        return (Window)window;
    }
}

void runWindow()
{
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app run];
    }
}