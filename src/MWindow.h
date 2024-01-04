#ifndef _M_WINDOW_H_
#define _M_WINDOW_H_

#include "MError.h"
#include "MDefs.h"
#include <stdint.h>

struct MWindow
{
    // NS Window configuration
    int width, height;
    const char *title;
    uint32_t flags;

    // layer properties
    MView *contentView;
    
    // Child and parent windows
    MWindow *parent;
    MWindow *children;
    int childCount;

    void *_this;
};

typedef enum {
    MWINDOW_FLAG_NONE = 0,
    MWINDOW_FLAG_RESIZABLE = 1 << 0,
    MWINDOW_FLAG_MINIMIZABLE = 1 << 1,
    MWINDOW_FLAG_MAXIMIZABLE = 1 << 2,
    MWINDOW_FLAG_FULLSCREEN = 1 << 3,
} MWindowFlags;

/*!
    * @brief: Creates the application's main window.
    * @param: width: Window width.
    * @param: height: Window height.
    * @param: title: Window title.
    * @return: A pointer to the main window.
*/
MWindow *MCreateMainWindow(int width, int height, const char *title);

/*!
    * @brief: Creates a child window.
    * @param: parent: The parent window.
    * @param: width: Window width.
    * @param: height: Window height.
    * @param: title: Window title.
    * @return: A pointer to the child window.

*/
MWindow *MCreateChildWindow(MWindow *parent, int width, int height, const char *title);

/*!
    * @brief: Sets the window's flags.
    * @param: window: The window.
    * @param: flags: The flags.
*/
void MSetWindowHints(MWindow *window, uint32_t flags);

/*!
    * @brief: Checks if the window is closed.
    * @param: window: The window.
*/
int MWindowShouldClose(MWindow *window);

/*!
    * @brief: Deallocates the window and its resources.
    * @param: window: The window.
*/
void MDestroyWindow(MWindow *window);

#endif // _M_WINDOW_H_