#import "MCL/delegate.h"
#import "MCL/errors.h"

#import <Cocoa/Cocoa.h>

@implementation M_Delegate // Updated class name

- (id)initWithapp:(MCL_App *)app
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

int MCL_InitApp(MCL_App *app)
{
    // initialize the app
    app->nsApp = [NSApplication sharedApplication];
    MCL_ERROR_LOCATION(app->nsApp ? 1 : 0, "Failed to initialize the App!")
    // initialize the app delegate
    [[M_Delegate alloc] initWithapp:app];
    MCL_ERROR_LOCATION(app->nsDelegate ? 1 : 0, "Failed to initialize the App Delegate!")
    // set the app delegate
    [app->nsApp setDelegate:app->nsDelegate];
    // set the app to initialized
    app->is_init = YES;
    // if everything went well, return MCL_SUCCESS
    return MCL_SUCCESS;
}

void MCL_RunApp(MCL_App *app) 
{
    if(!app->is_init)
    {
        fprintf(stderr, "App not initialized!\n");
        return;
    }
    // run the app
    [app->nsApp run];
}

void MCL_TerminateApp(MCL_App *app)
{
    if(!app->is_init)
    {
        fprintf(stderr, "App not initialized!\n");
        return;
    }
    // terminate the app
    [app->nsApp terminate:app->nsApp];
    // release the app
    [app->nsApp release];
    // release the app delegate
    [app->nsDelegate release];
    // set the app to not initialized
    app->is_init = NO;
}