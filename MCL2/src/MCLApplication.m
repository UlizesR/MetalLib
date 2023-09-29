#include "MCLCore/MCLApplication.h"

#if TARGET_OS_MACCATALYST || TARGET_OS_IPHONE || TARGET_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@implementation MNSDelegate // Updated class name

- (id)initWithapp:(MCL_App *)app {
  self = [super init];
  if (!self) {
    return nil;
  }
    app->_delegate = (__bridge void *)self;
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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)sender {
  if (self == nil) {
    return NO;
  }
  return YES;
}

@end

int MCL_InitApp(MCL_App *app) 
{
    #if TARGET_OS_MACCATALYST || TARGET_OS_IPHONE || TARGET_OS_IOS
    UIApplication *uiApp = [UIApplication sharedApplication];
    app->_this = [[UIApplication sharedApplication] delegate];
    #else
    app->_this = [[NSApplication sharedApplication] delegate];
    NSApplication *nsApp = [NSApplication sharedApplication];
    #endif

    // Check that the app is initialized
    if (!app->_this)
    {
        fprintf(stderr, "Failed to initialize the App!\n");
        return 1;
    }

    // initialized and set the delegate
    MNSDelegate *delegate = [[MNSDelegate alloc] initWithapp:app];
    // Check that the delegate is initialized
    if (!app->_delegate)
    {
        fprintf(stderr, "Failed to initialize the App Delegate!\n");
        return 1;
    }
    // Set the app delegate and other properties
    #if TARGET_OS_MACCATALYST || TARGET_OS_IPHONE || TARGET_OS_IOS
    [uiApp setDelegate:delegate];
    [uiApp setActivationPolicy:UIApplicationActivationPolicyRegular];
    [uiApp activateIgnoringOtherApps:YES];
    #else
    [nsApp setDelegate:delegate];
    [nsApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [nsApp activateIgnoringOtherApps:YES];
    #endif

    // Set the app to initialized
    app->is_init = true;

    return 0;
}

void MCL_RunApp(MCL_App *app)
{
    if (!app->is_init) {
        fprintf(stderr, "App not initialized!\n");
        return;
    }
    // run the app
    #if TARGET_OS_MACCATALYST || TARGET_OS_IPHONE || TARGET_OS_IOS
    UIApplication *uiApp = (UIApplication *)app->_this;
    [uiApp run];
    #else
    NSApplication *nsApp = (NSApplication *)app->_this;
    [nsApp run];
    #endif
}