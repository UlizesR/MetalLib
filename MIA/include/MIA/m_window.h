#pragma once

#include "defs.h"

#include <stdbool.h>
#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface M_Window_Delegate : NSObject <NSWindowDelegate>
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif


typedef enum
{
    M_WINDOW_RESIZABLE = 0x00000001,
    M_WINDOW_MINIMIZED = 0x00000002,
    M_WINDOW_FULLSCREEN = 0x00000004,
} M_WindowFlags;

struct M_Window
{
    int id;                     // The id of the window
    MSize size;                 // The size of the window
    MTitle title;               // The title of the window
    UInt32 flags;               // The flags of the window
    M_View *content_view;       // The content view of the window
    bool is_main_window;        // Whether this window is the main window or not
    void *delegate;             // The delegate of this window
    
    M_Window *parent;           // The parent window of this window
    M_Window **children;        // Pointer to an array of child windows
    int num_children;           // Number of child windows
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
M_Window* M_CreateWindow(int width, int height, bool is_main_window, MTitle title, UInt32 flags);

/*!
    Close the given window.
    If window is the main window, the program will exit 
    and all child windows will be closed.
    @param window: the window to be closed
*/
void M_CloseWindow(M_Window* window);

/*!
    Checks if the given window is open or minimized.
    @param window: the window to be checked
    @return: true if the window is open, false otherwise
*/
bool M_IsWindowOpen(M_Window* window);

/*!
    Destroys the given window.  
    @param window: the window to be destroyed
*/
void M_DestroyWindow(M_Window* window);

#ifdef __cplusplus
}
#endif
