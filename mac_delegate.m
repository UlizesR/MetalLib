// Mac_delegate.m
#import "mac_delegate.h"

Mac_Delegate* delegate = nil;

@implementation Mac_Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // This method is called when the application has finished launching
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // This method is called when the application is about to terminate
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

Mac_Delegate* initDelegate() {
    delegate = [[Mac_Delegate alloc] init];
    [NSApp setDelegate:delegate];
    return delegate;
}

void terminateDelegate() {
    [NSApp terminate:delegate];
    delegate = nil;
}