// Mac_delegate.m
#import "MAC/mac_delegate.h"

Mac_Delegate* delegate = nil;

@implementation Mac_Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (delegate == nil) {
        return;
    }
    // Insert code here to initialize your application
    // This method is called when the application has finished launching
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (delegate == nil) {
        return;
    }
    // Insert code here to tear down your application
    // This method is called when the application is about to terminate
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    if (delegate == nil) {
        return NO;
    }
    return YES;
}

@end

Mac_Delegate* initDelegate() {
    delegate = [[Mac_Delegate alloc] init];
    [NSApp setDelegate:delegate];
    return delegate;
}

void terminateDelegate() {
    if (delegate == nil) {
        return;
    }
    [NSApp terminate:delegate];
    delegate = nil;
}

void runDelegate() {
    if (delegate == nil) {
        return;
    }
    NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                        untilDate:[NSDate distantPast]
                                        inMode:NSDefaultRunLoopMode
                                        dequeue:YES];
    if (event) {
        [NSApp sendEvent:event];
    }
}
