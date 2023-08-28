#pragma once

#include <stdint.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface M_Delegate : NSObject <NSApplicationDelegate>

@property(nonatomic, strong) NSWindow *mainWindow;
@property(nonatomic, strong) NSView *mainWindowContentView;
@property(strong) NSMutableArray<NSWindow *> *childWindows;

@end

/*!
    initializes the delegate for the entire app
    @return the delegate
*/
M_Delegate *initDelegate();

extern M_Delegate *globalDelegate;

#endif

#ifdef __cplusplus
extern "C" {
#endif

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
