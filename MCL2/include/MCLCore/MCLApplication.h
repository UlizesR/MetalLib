/*
    File:   MCLDelegate.h
    About:
        The delegate header file for MCL.
        Contains the delegate and its functions for the MCL application.
*/

#ifndef mcl_delegate_h
#define mcl_delegate_h

#include "stdbool.h"

#define MCL_APP_VERSION(major, minor, patch) #major "." #minor "." #patch

#ifdef __OBJC__
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface MNSDelegate : NSObject <UIApplicationDelegate>

@property(nonatomic, strong) UIWindow *app_window;

@end
#endif // TARGET_OS_IPHONE

#import <Cocoa/Cocoa.h>

@interface MNSDelegate : NSObject <NSApplicationDelegate>

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

typedef struct MCL_App {
    MCL_AppInfo app_info;   // Information about the app
    bool is_init;           // Whether the app is initialized or not
    void* _delegate;        // The delegate for the app
    void* _this;            // The app itself
} MCL_App;

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

#endif // mcl_delegate_h 