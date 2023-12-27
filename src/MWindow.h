#ifndef _MDL_WINDOW_H_
#define _MDL_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#include "MDefs.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif 

struct MWindow
{
    // NS Window configuration
    int width, height;
    const char *title;
    uint32_t flags;

    // layer properties
    MView *content_view;
    
    // Child and parent windows
    MWindow *parent;
    MWindow *children;
    int child_count;

    void *_this;
};

/*!
    * @brief: Initialize the application and creates the main window.
    * @param: width: Window width.
    * @param: height: Window height.
    * @param: title: Window title.
    * @return: A pointer to the main window.
*/
MWindow *MCreateMainWindow(int width, int height, const char *title);

MWindow *MCreateChildWindow(MWindow *parent, int width, int height, const char *title);

void MSetWindowHints(MWindow *window, uint32_t flags);

int MWindowShouldClose(MWindow *window);

void MShowWindow(MWindow *window);

void MCloseWindow(MWindow *window);

void MDestroyWindow(MWindow *window);

#ifdef __cplusplus
}
#endif

#endif // _MDL_WINDOW_H_