/*
    File:   MCLApplication.h
    About:
        The application header file for MCL.
        Containts the application configuration and functions for the MCL application.
*/

#ifndef _mcl_application_h_
#define _mcl_application_h_

// Include the core header file
#include "MCLCore.h"
#include "MCLWindow.h"

// Include std headers
#include <stdint.h>

// For setting the version of the app
#define MCL_APP_VERSION(major, minor, patch) #major "." #minor "." #patch

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

// The delegate for the app
@interface AppDelegate : NSObject <NSApplicationDelegate>
- (instancetype)initWithApp:(MCL_App *)app;
@property(nonatomic, strong) NSWindow *app_window;
@end
#endif 

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_AppInfo {
    const char *name;        // The name of the app
    const char *version;     // The version of the app
    const char *author;      // The author of the app
    const char *description; // The description of the app
} MCL_AppInfo;

struct MCL_App {
    MCL_AppInfo app_info;   // Information about the app
    MCL_Window *app_window; // The main window
    void *_this;            // The app itself (for C/C++)

#ifdef __OBJC__
    /*
        This is use for the Objective-C files.
        This way, we don't have to translate the C structs to Objective-C objects.
    */
    BOOL is_init;
    AppDelegate *nsDelegate; // The delegate for the app (Objective-C)
    NSApplication *nsApp;   // The app (Objective-C)
#endif
};

/*!
    @brief Initializes the delegate for the app
    @param app: the app to initialize the delegate for
*/
int MCL_InitApp(MCL_App *app);

/*!
    @brief Runs the delegate
    @param app: the app to run the delegate for
*/
void MCL_RunApp(MCL_App *app);

/*!
    @brief Terminates the delegate
    @param app: the app to terminate the delegate for
*/
void MCL_TerminateApp(MCL_App *app);

#ifdef __cplusplus
}
#endif

#endif // _mcl_application_h_