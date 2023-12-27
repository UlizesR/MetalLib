#import "MApp.h"
#import "MError.h"

#include <AppKit/AppKit.h>

@implementation MAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if (self == nil) {
		return;
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	if (self == nil) {
		return;
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp terminate:self];
}

int MAppInit(MAppInstance *app, int argc, char **argv)
{
    if (!app) 
    {
        NSLog(@"App instance is null");
        return MDL_ERROR_NULL_POINTER;
    }

    MAppDelegate *appDelegate = [[MAppDelegate alloc] init];

    if (!appDelegate) 
    {
        NSLog(@"Failed to initialize app delegate");
        return MDL_ERROR_INIT;
    }

    [NSApp setDelegate:appDelegate];
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    app->_this = (__bridge void *)appDelegate;

    return MDL_SUCESS;
}

int MTerminateApp(MAppInstance *app)
{
    if (!app) 
    {
        NSLog(@"App instance is null");
        return MDL_ERROR_NULL_POINTER;
    }

    [NSApp terminate:NSApp];

    return MDL_SUCESS;
}

@end