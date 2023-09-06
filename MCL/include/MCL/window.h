#ifndef _mcl_window_h_
#define _mcl_window_h_

#include "defs.h"

#include <stdint.h>
#include <stdbool.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface WindowDelegate : NSObject <NSWindowDelegate>
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    M_WINDOW_RESIZABLE = 0x00000001,
    M_WINDOW_MINIMIZED = 0x00000002,
    M_WINDOW_FULLSCREEN = 0x00000004,
} MCL_WindowFlags;

struct MCL_Window {
    int id;                     // The id of the window
    int width, height;          // The width and height of the window
    const char* title;          // The title of the window
    uint32_t flags;             // The flags of the window
    MCL_Frame *window_frame;    // The content view of the window
    bool is_main_window;        // Whether this window is the main window or not
    void *_this;                // The window itself

    MCL_Window *parent;         // The parent window of this window
    MCL_Window **children;      // Pointer to an array of child windows
    int num_children;           // Number of child windows
};

/*!
    @brief Creates the app's main window with the given parameters.
    @param app: the app to create the window for
    @param width: the width of the window
    @param height: the height of the window
    @param title: the title of the window
*/
void MCL_AppWindow(MCL_App *app, int width, int height, const char* title);

/*!
    @brief Creates a child window with the given parameters.
    @param parent: the parent window of the child window
    @param width: the width of the window
    @param height: the height of the window
    @param title: the title of the window
*/
MCL_Window *MCL_ChildWindow(MCL_Window *parent, int width, int height, const char* title);

/*!
    @brief Sets the window hints for the given window.
    @param window: the window to set the hints for
    @param flags: the flags to set for the window
*/
void MCL_WindowHints(MCL_Window *window, uint32_t flags);

/*!
    @brief Closes the given window.
    @param window: the window to be closed
*/
void MCL_CloseWindow(MCL_Window *window);

/*!
    @brief Checks if the given window is open.
    @param window: the window to check
*/
bool MCL_IsWindowOpen(MCL_Window *window);

/*!
    @brief Destroys the given window. It will also destroy the window's main frame.
    @param window: the window to be destroyed
*/
void MCL_DestroyWindow(MCL_Window *window);

#ifdef __cplusplus
}
#endif

#endif // _mcl_window_h_