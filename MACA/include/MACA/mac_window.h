#ifndef mac_window_h_
#define mac_window_h_

#include "mac_defs.h"
#include "mac_colors.h"

#include <stdbool.h>
#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>


@interface Mac_Window_Delegate : NSObject <NSWindowDelegate>
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    MAC_WINDOW_RESIZABLE = 0x00000001,
    MAC_WINDOW_MINIMIZED = 0x00000002,
    MAC_WINDOW_FULLSCREEN = 0x00000004,
} Mac_WindowFlags;

struct Mac_Window
{
    MSize size;                 // The size of the window
    MTitle title;               // The title of the window
    int id;                     // The id of the window
    UInt32 flags;               // The flags of the window
    Mac_Window *parent;         // The parent window of this window
    Mac_Window **children;     // Pointer to an array of child windows
    Mac_View *content_view;     // The content view of the window
    int num_children;           // Number of child windows
    bool is_main_window;        // Whether this window is the main window or not
    void *delegate;             // The delegate of this window
};

/*!
    Creates a window with the given parameters.
    The window content view is created after the window is created.
    @param width: the width of the window
    @param height: the height of the window
    @param is_main_window: whether the window is the main window or not
    @param title: the title of the window
    @param flags: the flags of the window
    @return: the created window
*/
Mac_Window* MAC_CreateWindow(int width, int height, bool is_main_window, MTitle title, UInt32 flags);

/*!
    Close the given window.
    If window is the main window, the program will exit 
    and all child windows will be closed.
    @param window: the window to be closed
*/
void MAC_CloseWindow(Mac_Window* window);

/*!
    Checks if the given window is open or minimized.
    @param window: the window to be checked
    @return: true if the window is open, false otherwise
*/
bool isWindowOpen(Mac_Window* window);

/*!
    Destroys the given window.  
    @param window: the window to be destroyed
*/
void MAC_DestroyWindow(Mac_Window* window);

#ifdef __cplusplus
}
#endif

#endif // mac_window_h_