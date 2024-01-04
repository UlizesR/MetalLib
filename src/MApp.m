#import "MApp.h"
#import "MError.h"

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

@end

MError MApplicationInit(MApplication *appConfig, int argc, char **argv)
{
    MAppDelegate *appDelegate = [[MAppDelegate alloc] init];

    if (!appDelegate) 
    {
        NSLog(@"Failed to initialize app delegate");
        return M_ERROR_INIT;
    }

    [NSApp setDelegate:appDelegate];
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    appConfig->_this = (__bridge void *)appDelegate;

    return M_SUCCESS; 
}

void MRunApplication()
{
    [NSApp run];
}

MError MApplicationTerminate()
{
    [NSApp terminate:NSApp];

    return M_SUCCESS;
}