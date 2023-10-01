#import "MCL2/MCLCore/MCLApplication.h"

#import <Cocoa/Cocoa.h>

@implementation AppDelegate

- (instancetype)initWithApp:(MCL_App *)app;
{
	self = [super init];
	if (!self) {
		return nil;
	}
	app->nsDelegate = self;
	return self;
}
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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    if (self == nil) {
      return NO;
    }
    return YES;
}
@end

int MCL_InitApp(MCL_App *app) {
    // initialize the app
    app->nsApp = [NSApplication sharedApplication];
    if (!app->nsApp) {
        fprintf(stderr, "Failed to initialize the App!\n");
        return 1;
    }
    // initialize the app delegate
    [[AppDelegate alloc] initWithApp:app];
    if (!app->nsDelegate) {
        fprintf(stderr, "Failed to initialize the App Delegate!\n");
        return 1;
    }
    // set the app delegate
    [app->nsApp setDelegate:app->nsDelegate];
    // set the app activation policy
    [app->nsApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [app->nsApp activateIgnoringOtherApps:YES];
    // set the app to initialized
    app->is_init = YES;
    // if everything went well, return MCL_SUCCESS
    return 0;
}

void MCL_RunApp(MCL_App *app) {
    if (!app->is_init) {
        fprintf(stderr, "App not initialized!\n");
        return;
    }
	// terminate the app if there are no windows 
	while ([app->nsApp windows].count != 0) 	
    	[app->nsApp run];
}

void MCL_TerminateApp(MCL_App *app) {
    if (!app->is_init) {
        fprintf(stderr, "Error: App not initialized\n");
        return;
    }

    NSError *error = nil;

    // Terminate the app
    // Terminate the app
    if (error != nil) {
        fprintf(stderr, "Error: %s\n", [[error localizedDescription] UTF8String]);
    }
    [app->nsApp terminate:app->nsApp];

    // Release the app
    [app->nsApp release];

    // Release the app delegate
    [app->nsDelegate release];

    // Set the app to not initialized
    app->is_init = NO;
}