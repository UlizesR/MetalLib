#ifndef _MKL_WINDOW_H_
#define _MKL_WINDOW_H_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

/**
 * @brief Application and window delegate for MKL windows.
 */
@interface MklDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

/// The NSWindow instance managed by this delegate
@property (nonatomic, strong, nonnull) NSWindow *window;
/// Associated MKL window structure
@property (nonatomic, assign, nullable) void *mklWindow;

/**
 * @brief Initializes the delegate with window parameters and flags.
 * @param title Window title
 * @param width Window width in pixels
 * @param height Window height in pixels
 * @param flags Window configuration flags
 * @return Initialized delegate instance or nil on failure
 */
- (nonnull instancetype)initWithTitle:(nonnull NSString *)title
                                width:(int)width
                               height:(int)height
                                flags:(uint32_t)flags;

@end

#endif // __OBJC__

#include <stdint.h>
#include <stdbool.h>
#include "Core/MKLCore.h"

/**
 * @brief Window configuration flags (inspired by raylib).
 */
typedef enum {
    MKL_WINDOW_RESIZABLE          = 0x00000001,  ///< Window is resizable
    MKL_WINDOW_UNDECORATED        = 0x00000002,  ///< Window has no border/titlebar
    MKL_WINDOW_HIDDEN             = 0x00000004,  ///< Window is initially hidden
    MKL_WINDOW_MINIMIZED          = 0x00000008,  ///< Window is initially minimized
    MKL_WINDOW_MAXIMIZED          = 0x00000010,  ///< Window is initially maximized
    MKL_WINDOW_UNFOCUSED          = 0x00000020,  ///< Window is initially unfocused
    MKL_WINDOW_TOPMOST            = 0x00000040,  ///< Window is always on top
    MKL_WINDOW_HIGHDPI            = 0x00000080,  ///< Window supports high DPI
    MKL_WINDOW_MOUSE_PASSTHROUGH  = 0x00000100,  ///< Mouse events pass through window
    MKL_WINDOW_BORDERLESS         = 0x00000200,  ///< Borderless fullscreen window
} MKLWindowFlags;

/**
 * @brief Window callbacks structure (inspired by GLFW).
 */
typedef struct MKLWindowCallbacks
{
    void (*windowPosCallback)(int x, int y);                    ///< Window position changed
    void (*windowSizeCallback)(int width, int height);          ///< Window size changed
    void (*windowCloseCallback)(void);                          ///< Window close requested
    void (*windowFocusCallback)(bool focused);                  ///< Window focus changed
    void (*windowIconifyCallback)(bool iconified);              ///< Window minimized/restored
    void (*framebufferSizeCallback)(int width, int height);     ///< Framebuffer size changed
} MKLWindowCallbacks;

/**
 * @brief Window structure containing window state and properties.
 */
typedef struct MKLWindow
{
    int width;                  ///< Current window width in pixels
    int height;                 ///< Current window height in pixels
    int posX;                   ///< Window X position
    int posY;                   ///< Window Y position
    const char *title;          ///< Window title
    uint32_t flags;             ///< Window configuration flags
    bool shouldClose;           ///< Should window close flag
    bool focused;               ///< Window has input focus
    bool minimized;             ///< Window is minimized
    bool maximized;             ///< Window is maximized
    bool hidden;                ///< Window is hidden
    MKLWindowCallbacks callbacks; ///< Window event callbacks
#ifdef __OBJC__
    NSWindow *_nswindow;        ///< Underlying NSWindow (Objective-C only)
    void *_delegate;            ///< Window delegate (Objective-C only)
#endif
} MKLWindow;

// ========== Window Creation & Destruction ==========

/**
 * @brief Creates a new window with the specified dimensions and title.
 * @param width Window width in pixels (must be > 0)
 * @param height Window height in pixels (must be > 0)
 * @param title Window title (must not be NULL)
 * @return Pointer to created window or NULL on failure
 */
MKLAPI MKLWindow *MKLCreateWindow(const int width, const int height, const char *title);

/**
 * @brief Creates a new window with configuration flags.
 * @param width Window width in pixels
 * @param height Window height in pixels
 * @param title Window title
 * @param flags Window configuration flags (MKLWindowFlags)
 * @return Pointer to created window or NULL on failure
 */
MKLAPI MKLWindow *MKLCreateWindowEx(const int width, const int height, const char *title, const uint32_t flags);

/**
 * @brief Destroys the window and frees associated resources.
 * @param window Pointer to the window to destroy
 */
MKLAPI void MKLDestroyWindow(MKLWindow *window);

// ========== Window State Control ==========

/**
 * @brief Closes the window (marks it for closing).
 * @param window Pointer to the window to close
 */
MKLAPI void MKLCloseWindow(MKLWindow *window);

/**
 * @brief Checks if the window should remain open.
 * @param window Pointer to the window to check
 * @return true if window should stay open, false if it should close
 */
MKLAPI bool MKLWindowShouldClose(MKLWindow *window);

/**
 * @brief Sets whether the window should close.
 * @param window Pointer to the window
 * @param shouldClose true to mark for closing, false to keep open
 */
MKLAPI void MKLSetWindowShouldClose(MKLWindow *window, const bool shouldClose);

// ========== Window State Queries (GLFW-inspired) ==========

/**
 * @brief Checks if the window is currently focused.
 * @param window Pointer to the window
 * @return true if window has input focus, false otherwise
 */
MKLAPI bool MKLIsWindowFocused(MKLWindow *window);

/**
 * @brief Checks if the window is currently minimized.
 * @param window Pointer to the window
 * @return true if window is minimized, false otherwise
 */
MKLAPI bool MKLIsWindowMinimized(MKLWindow *window);

/**
 * @brief Checks if the window is currently maximized.
 * @param window Pointer to the window
 * @return true if window is maximized, false otherwise
 */
MKLAPI bool MKLIsWindowMaximized(MKLWindow *window);

/**
 * @brief Checks if the window is currently hidden.
 * @param window Pointer to the window
 * @return true if window is hidden, false otherwise
 */
MKLAPI bool MKLIsWindowHidden(MKLWindow *window);

/**
 * @brief Checks if the window is currently visible.
 * @param window Pointer to the window
 * @return true if window is visible, false otherwise
 */
MKLAPI bool MKLIsWindowVisible(MKLWindow *window);

// ========== Window Manipulation (GLFW-inspired) ==========

/**
 * @brief Sets the window title.
 * @param window Pointer to the window
 * @param title New window title
 */
MKLAPI void MKLSetWindowTitle(MKLWindow *window, const char *title);

/**
 * @brief Sets the window position.
 * @param window Pointer to the window
 * @param x X coordinate
 * @param y Y coordinate
 */
MKLAPI void MKLSetWindowPosition(MKLWindow *window, const int x, const int y);

/**
 * @brief Gets the window position.
 * @param window Pointer to the window
 * @param x Pointer to store X coordinate (can be NULL)
 * @param y Pointer to store Y coordinate (can be NULL)
 */
MKLAPI void MKLGetWindowPosition(MKLWindow *window, int *x, int *y);

/**
 * @brief Sets the window size.
 * @param window Pointer to the window
 * @param width New width
 * @param height New height
 */
MKLAPI void MKLSetWindowSize(MKLWindow *window, const int width, const int height);

/**
 * @brief Gets the window size.
 * @param window Pointer to the window
 * @param width Pointer to store width (can be NULL)
 * @param height Pointer to store height (can be NULL)
 */
MKLAPI void MKLGetWindowSize(MKLWindow *window, int *width, int *height);

/**
 * @brief Minimizes (iconifies) the window.
 * @param window Pointer to the window
 */
MKLAPI void MKLMinimizeWindow(MKLWindow *window);

/**
 * @brief Maximizes the window.
 * @param window Pointer to the window
 */
MKLAPI void MKLMaximizeWindow(MKLWindow *window);

/**
 * @brief Restores the window from minimized/maximized state.
 * @param window Pointer to the window
 */
MKLAPI void MKLRestoreWindow(MKLWindow *window);

/**
 * @brief Shows the window if it's hidden.
 * @param window Pointer to the window
 */
MKLAPI void MKLShowWindow(MKLWindow *window);

/**
 * @brief Hides the window.
 * @param window Pointer to the window
 */
MKLAPI void MKLHideWindow(MKLWindow *window);

/**
 * @brief Focuses the window.
 * @param window Pointer to the window
 */
MKLAPI void MKLFocusWindow(MKLWindow *window);

/**
 * @brief Centers the window on the screen.
 * @param window Pointer to the window
 */
MKLAPI void MKLCenterWindow(MKLWindow *window);

// ========== Window Attributes ==========

/**
 * @brief Sets window opacity/alpha.
 * @param window Pointer to the window
 * @param opacity Opacity value (0.0 = transparent, 1.0 = opaque)
 */
MKLAPI void MKLSetWindowOpacity(MKLWindow *window, const float opacity);

/**
 * @brief Gets window opacity.
 * @param window Pointer to the window
 * @return Current opacity (0.0 to 1.0)
 */
MKLAPI float MKLGetWindowOpacity(MKLWindow *window);

/**
 * @brief Toggles window fullscreen mode.
 * @param window Pointer to the window
 */
MKLAPI void MKLToggleFullscreen(MKLWindow *window);

/**
 * @brief Checks if window is in fullscreen mode.
 * @param window Pointer to the window
 * @return true if fullscreen, false otherwise
 */
MKLAPI bool MKLIsWindowFullscreen(MKLWindow *window);

// ========== Window Callbacks ==========

/**
 * @brief Sets the window position callback.
 * @param window Pointer to the window
 * @param callback Callback function
 */
MKLAPI void MKLSetWindowPosCallback(MKLWindow *window, void (*callback)(int x, int y));

/**
 * @brief Sets the window size callback.
 * @param window Pointer to the window
 * @param callback Callback function
 */
MKLAPI void MKLSetWindowSizeCallback(MKLWindow *window, void (*callback)(int width, int height));

/**
 * @brief Sets the window close callback.
 * @param window Pointer to the window
 * @param callback Callback function
 */
MKLAPI void MKLSetWindowCloseCallback(MKLWindow *window, void (*callback)(void));

/**
 * @brief Sets the window focus callback.
 * @param window Pointer to the window
 * @param callback Callback function
 */
MKLAPI void MKLSetWindowFocusCallback(MKLWindow *window, void (*callback)(bool focused));

#endif // _MKL_WINDOW_H_
