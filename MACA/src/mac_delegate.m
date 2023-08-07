// Mac_delegate.m
#import "MACA/mac_delegate.h"
#import "MACA/mac_error.h"

Mac_Delegate* delegate = nil;

@implementation Mac_Delegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (delegate == nil) {
        return;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (delegate == nil) {
        return;
    }
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

int checkDelegateInit()
{
    Mac_Delegate* delegate = initDelegate();
    if (delegate == NULL) {
        return MAC_ERROR;
    }
    return MAC_SUCCESS;
}