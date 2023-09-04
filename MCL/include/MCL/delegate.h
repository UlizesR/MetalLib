/*
    File:   delegate.h
    About:
        The delegate header file for MCL.
        Contains the delegate and its functions for the MCL application.
*/

#ifndef _mcl_delegate_h_
#define _mcl_delegate_h_

#include "defs.h"

#ifdef __OBJC__

#import <Cocoa/Cocoa.h>

@interface M_Delegate : NSObject <NSApplicationDelegate>

@property(nonatomic, strong) NSWindow *main_window;
@property(nonatomic, strong) NSView *main_view;
@property(strong) NSMutableArray<NSWindow *> *child_windows;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_AppInfo {
    const char *name;
    const char *version;
    const char *author;
    const char *description;
} MCL_AppInfo;

typedef struct MCL_App {
    MCL_AppInfo app_info;
    M_Window *main_window;
    

    #ifdef __OBJC__
    M_Delegate *delegate;
    #endif
} MCL_App;

/*!
    Initializes the delegate
*/
void MCL_InitApp(MCL_App *state);

/*!
    The run loop for the app
*/
void MCL_RunApp();

/*
    Terminates the delegate
*/
void MCL_TerminateApp();

#ifdef __cplusplus
}
#endif

#endif // _mcl_delegate_h_