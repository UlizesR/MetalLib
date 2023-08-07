#ifndef mac_window_h_
#define mac_window_h_


#include "mac_internals.h"
#include "mac_pixels.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface Mac_WindowDelegate : NSObject <NSWindowDelegate>
@property (nonatomic, strong) NSView *content_view;
@end
#endif

#include <stdint.h>
#include <stdbool.h>
#include <MacTypes.h>

#ifdef __cplusplus
extern "C" {
#endif


typedef enum
{
    MAC_WINDOW_RESIZABLE = 0x00000001,
    MAC_WINDOW_MINIMIZED = 0x00000002,
    MAC_WINDOW_MAXIMIZED = 0x00000004,
    MAC_WINDOW_FULLSCREEN = 0x00000008,
    MAC_WINDOW_METAL = 0x00000010,
} Mac_WindowFlags;

struct Mac_Window
{
    MSize size;
    MTitle title;
    Mac_WindowID id;
    Mac_Window *parent;
    Mac_Window *children;
    Mac_View *content_view;
    Mac_Color background_color;
    UInt32 flags;
    bool is_main_window;
    void *delegate;
};

/*
    Functions for creating and managing windows
    Window default Functionalities:
        - Closable
        - Minimizable
*/

/*!
    Creates a window with the given parameters.
    @param width: the width of the window
    @param height: the height of the window
    @param is_main_window: whether the window is the main window or not
    @param title: the title of the window
    @param background_color: the background color of the window
    @param flags: the flags of the window
    @return: the created window
*/
Mac_Window* createWindow(int width, int height, bool is_main_window, MTitle title, Mac_Color background_color, UInt32 flags);

/*!
    Close the given window.
    @param window: the window to be closed
*/
void closeWindow(Mac_Window* window);

/*!
    Checks if the given window is open.
    @param window: the window to be checked
*/
bool isWindowOpen(Mac_Window* window);

/*!
    Destroys the given window.
    @param window: the window to be destroyed
*/
void destroyWindow(Mac_Window* window);

/*!
    Run loop for the window.
*/
void runWindow();

/*
    Functions for managing window hierarchies
*/

/*!
    Adds a child window to the given parent window.
    @param parent: the parent window
    @param child: the child window
*/
void addChildWindow(Mac_Window* parent, Mac_Window* child);

/*!
    Removes a child window from the given parent window.
    @param parent: the parent window
    @param child: the child window
*/
void removeChildWindow(Mac_Window* parent, Mac_Window* child);

/*
    Functions for managing window flags
*/

/*!
    Sets the given window's flags.
    @param window: the window to set the flags for
    @param flags: the flags to set
*/
void setWindowFlags(Mac_Window* window, UInt32 flags);

#ifdef __cplusplus
}
#endif

#endif // mac_window_h_