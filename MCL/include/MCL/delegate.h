/*
    File:   delegate.h
    About:
        The delegate header file for MCL.
        Contains the delegate and its functions for the MCL application.
*/

#ifndef _mcl_delegate_h_
#define _mcl_delegate_h_

#include "defs.h"
#include "mcl_sys/sys_info.h"
#include "mcl_sys/gpu.h"

#define MCL_APP_VERSION(major, minor, patch) #major "." #minor "." #patch

#ifdef __OBJC__

#import <Cocoa/Cocoa.h>

@interface M_Delegate : NSObject <NSApplicationDelegate>

@property(nonatomic, strong) NSWindow *app_window;
@property(strong) NSMutableArray<NSWindow *> *child_windows;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_AppInfo {
    const char *name;               // The name of the app
    const char *version;            // The version of the app
    const char *author;             // The author of the app
    const char *description;        // The description of the app
} MCL_AppInfo;

struct MCL_App {
    MCL_AppInfo app_info;           // Information about the app
    MCL_Window *app_window;         // The main window
    MCL_VDevice *device;            // The device the app can use

    #ifdef __OBJC__
    /*
        This is use for the Objective-C files.
        This way, we don't have to translate the C structs to Objective-C objects.
    */
    BOOL is_init;
    M_Delegate *nsDelegate;         // The delegate for the app (Objective-C)
    NSApplication *nsApp;           // The app (Objective-C)
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

#endif // _mcl_delegate_h_