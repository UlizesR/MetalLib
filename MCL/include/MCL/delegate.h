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

typedef struct MCL_State {
    const char* app_name;
    const char* app_version;
    const char* app_author;
    const char* app_description;

    M_Window* main_window;
    

    #ifdef __OBJC__
    M_Delegate* delegate;
    #endif
} MCL_State;

/*!
    The run loop for the app
*/
void runDelegate();

/*
    Terminates the delegate
*/
void terminateDelegate();

/*!
    Initializes the MCL library.
    @param flags: the flags to initialize the library with
    @return: 0 on success, -1 on failure
*/
int M_Init(uint32_t flags);

/*!
    Quits the MACA library.
*/
void M_Quit();

#ifdef __cplusplus
}
#endif

#endif // _mcl_delegate_h_