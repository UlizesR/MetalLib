#import "mac_delegate.h"
#import <spawn.h>

@implementation Mac_Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Hello World");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [NSApp terminate:self];
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp terminate:self];
}

@end