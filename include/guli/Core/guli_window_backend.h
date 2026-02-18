#pragma once

/* Backend-agnostic window API. Implemented via GLFW for now; swap backend in one place below. */

#define GLFW_INCLUDE_NONE
#include "GLFW/glfw3.h"

typedef struct GLFWwindow GuliWindow;

/* ---------------------------------------------------------------------------
 * Input: enums (values match GLFW; change when swapping backend) + wrapper functions
 * --------------------------------------------------------------------------- */

/* Action (key/button state). Returned by GuliGetKey / GuliGetMouseButton (see guli_core.h). */
typedef enum GuliAction {
    GULI_RELEASE = GLFW_RELEASE,
    GULI_PRESS   = GLFW_PRESS,
    GULI_REPEAT  = GLFW_REPEAT
} GuliAction;

/* Key code. Values match GLFW; swap to MWSL_KEY_* etc. when changing backend. */
typedef enum GuliKey {
    GULI_KEY_UNKNOWN       = GLFW_KEY_UNKNOWN,
    GULI_KEY_SPACE         = GLFW_KEY_SPACE,
    GULI_KEY_APOSTROPHE    = GLFW_KEY_APOSTROPHE,
    GULI_KEY_COMMA         = GLFW_KEY_COMMA,
    GULI_KEY_MINUS         = GLFW_KEY_MINUS,
    GULI_KEY_PERIOD        = GLFW_KEY_PERIOD,
    GULI_KEY_SLASH         = GLFW_KEY_SLASH,
    GULI_KEY_0             = GLFW_KEY_0,
    GULI_KEY_1             = GLFW_KEY_1,
    GULI_KEY_2             = GLFW_KEY_2,
    GULI_KEY_3             = GLFW_KEY_3,
    GULI_KEY_4             = GLFW_KEY_4,
    GULI_KEY_5             = GLFW_KEY_5,
    GULI_KEY_6             = GLFW_KEY_6,
    GULI_KEY_7             = GLFW_KEY_7,
    GULI_KEY_8             = GLFW_KEY_8,
    GULI_KEY_9             = GLFW_KEY_9,
    GULI_KEY_SEMICOLON     = GLFW_KEY_SEMICOLON,
    GULI_KEY_EQUAL         = GLFW_KEY_EQUAL,
    GULI_KEY_A             = GLFW_KEY_A,
    GULI_KEY_B             = GLFW_KEY_B,
    GULI_KEY_C             = GLFW_KEY_C,
    GULI_KEY_D             = GLFW_KEY_D,
    GULI_KEY_E             = GLFW_KEY_E,
    GULI_KEY_F             = GLFW_KEY_F,
    GULI_KEY_G             = GLFW_KEY_G,
    GULI_KEY_H             = GLFW_KEY_H,
    GULI_KEY_I             = GLFW_KEY_I,
    GULI_KEY_J             = GLFW_KEY_J,
    GULI_KEY_K             = GLFW_KEY_K,
    GULI_KEY_L             = GLFW_KEY_L,
    GULI_KEY_M             = GLFW_KEY_M,
    GULI_KEY_N             = GLFW_KEY_N,
    GULI_KEY_O             = GLFW_KEY_O,
    GULI_KEY_P             = GLFW_KEY_P,
    GULI_KEY_Q             = GLFW_KEY_Q,
    GULI_KEY_R             = GLFW_KEY_R,
    GULI_KEY_S             = GLFW_KEY_S,
    GULI_KEY_T             = GLFW_KEY_T,
    GULI_KEY_U             = GLFW_KEY_U,
    GULI_KEY_V             = GLFW_KEY_V,
    GULI_KEY_W             = GLFW_KEY_W,
    GULI_KEY_X             = GLFW_KEY_X,
    GULI_KEY_Y             = GLFW_KEY_Y,
    GULI_KEY_Z             = GLFW_KEY_Z,
    GULI_KEY_LEFT_BRACKET  = GLFW_KEY_LEFT_BRACKET,
    GULI_KEY_BACKSLASH     = GLFW_KEY_BACKSLASH,
    GULI_KEY_RIGHT_BRACKET = GLFW_KEY_RIGHT_BRACKET,
    GULI_KEY_GRAVE_ACCENT  = GLFW_KEY_GRAVE_ACCENT,
    GULI_KEY_ESCAPE        = GLFW_KEY_ESCAPE,
    GULI_KEY_ENTER         = GLFW_KEY_ENTER,
    GULI_KEY_TAB           = GLFW_KEY_TAB,
    GULI_KEY_BACKSPACE     = GLFW_KEY_BACKSPACE,
    GULI_KEY_INSERT        = GLFW_KEY_INSERT,
    GULI_KEY_DELETE        = GLFW_KEY_DELETE,
    GULI_KEY_RIGHT         = GLFW_KEY_RIGHT,
    GULI_KEY_LEFT          = GLFW_KEY_LEFT,
    GULI_KEY_DOWN          = GLFW_KEY_DOWN,
    GULI_KEY_UP            = GLFW_KEY_UP,
    GULI_KEY_PAGE_UP       = GLFW_KEY_PAGE_UP,
    GULI_KEY_PAGE_DOWN     = GLFW_KEY_PAGE_DOWN,
    GULI_KEY_HOME          = GLFW_KEY_HOME,
    GULI_KEY_END           = GLFW_KEY_END,
    GULI_KEY_CAPS_LOCK     = GLFW_KEY_CAPS_LOCK,
    GULI_KEY_SCROLL_LOCK   = GLFW_KEY_SCROLL_LOCK,
    GULI_KEY_NUM_LOCK      = GLFW_KEY_NUM_LOCK,
    GULI_KEY_PRINT_SCREEN  = GLFW_KEY_PRINT_SCREEN,
    GULI_KEY_PAUSE         = GLFW_KEY_PAUSE,
    GULI_KEY_F1            = GLFW_KEY_F1,
    GULI_KEY_F2            = GLFW_KEY_F2,
    GULI_KEY_F3            = GLFW_KEY_F3,
    GULI_KEY_F4            = GLFW_KEY_F4,
    GULI_KEY_F5            = GLFW_KEY_F5,
    GULI_KEY_F6            = GLFW_KEY_F6,
    GULI_KEY_F7            = GLFW_KEY_F7,
    GULI_KEY_F8            = GLFW_KEY_F8,
    GULI_KEY_F9            = GLFW_KEY_F9,
    GULI_KEY_F10           = GLFW_KEY_F10,
    GULI_KEY_F11           = GLFW_KEY_F11,
    GULI_KEY_F12           = GLFW_KEY_F12,
    GULI_KEY_LEFT_SHIFT    = GLFW_KEY_LEFT_SHIFT,
    GULI_KEY_LEFT_CONTROL  = GLFW_KEY_LEFT_CONTROL,
    GULI_KEY_LEFT_ALT      = GLFW_KEY_LEFT_ALT,
    GULI_KEY_LEFT_SUPER    = GLFW_KEY_LEFT_SUPER,
    GULI_KEY_RIGHT_SHIFT   = GLFW_KEY_RIGHT_SHIFT,
    GULI_KEY_RIGHT_CONTROL = GLFW_KEY_RIGHT_CONTROL,
    GULI_KEY_RIGHT_ALT     = GLFW_KEY_RIGHT_ALT,
    GULI_KEY_RIGHT_SUPER   = GLFW_KEY_RIGHT_SUPER,
    GULI_KEY_MENU          = GLFW_KEY_MENU
} GuliKey;

/* Modifier flags */
typedef enum GuliMod {
    GULI_MOD_SHIFT     = GLFW_MOD_SHIFT,
    GULI_MOD_CONTROL   = GLFW_MOD_CONTROL,
    GULI_MOD_ALT       = GLFW_MOD_ALT,
    GULI_MOD_SUPER     = GLFW_MOD_SUPER,
    GULI_MOD_CAPS_LOCK = GLFW_MOD_CAPS_LOCK,
    GULI_MOD_NUM_LOCK  = GLFW_MOD_NUM_LOCK
} GuliMod;

/* Mouse button */
typedef enum GuliMouseButton {
    GULI_MOUSE_BUTTON_1    = GLFW_MOUSE_BUTTON_1,
    GULI_MOUSE_BUTTON_2    = GLFW_MOUSE_BUTTON_2,
    GULI_MOUSE_BUTTON_3    = GLFW_MOUSE_BUTTON_3,
    GULI_MOUSE_BUTTON_4    = GLFW_MOUSE_BUTTON_4,
    GULI_MOUSE_BUTTON_5    = GLFW_MOUSE_BUTTON_5,
    GULI_MOUSE_BUTTON_6    = GLFW_MOUSE_BUTTON_6,
    GULI_MOUSE_BUTTON_7    = GLFW_MOUSE_BUTTON_7,
    GULI_MOUSE_BUTTON_8    = GLFW_MOUSE_BUTTON_8,
    GULI_MOUSE_BUTTON_LAST = GLFW_MOUSE_BUTTON_LAST,
    GULI_MOUSE_BUTTON_LEFT   = GLFW_MOUSE_BUTTON_LEFT,
    GULI_MOUSE_BUTTON_RIGHT  = GLFW_MOUSE_BUTTON_RIGHT,
    GULI_MOUSE_BUTTON_MIDDLE = GLFW_MOUSE_BUTTON_MIDDLE
} GuliMouseButton;

/* Window hints: use with GuliWindowHint before GuliWindowCreate. Values match GLFW. */
typedef enum GuliHint {
    /* Window attributes */
    GULI_FOCUSED                  = GLFW_FOCUSED,
    GULI_ICONIFIED                = GLFW_ICONIFIED,
    GULI_RESIZABLE                = GLFW_RESIZABLE,
    GULI_VISIBLE                  = GLFW_VISIBLE,
    GULI_DECORATED                = GLFW_DECORATED,
    GULI_AUTO_ICONIFY             = GLFW_AUTO_ICONIFY,
    GULI_FLOATING                 = GLFW_FLOATING,
    GULI_MAXIMIZED                = GLFW_MAXIMIZED,
    GULI_CENTER_CURSOR            = GLFW_CENTER_CURSOR,
    GULI_TRANSPARENT_FRAMEBUFFER  = GLFW_TRANSPARENT_FRAMEBUFFER,
    GULI_HOVERED                  = GLFW_HOVERED,
    GULI_FOCUS_ON_SHOW            = GLFW_FOCUS_ON_SHOW,
    /* Framebuffer hints */
    GULI_RED_BITS                 = GLFW_RED_BITS,
    GULI_GREEN_BITS               = GLFW_GREEN_BITS,
    GULI_BLUE_BITS                = GLFW_BLUE_BITS,
    GULI_ALPHA_BITS               = GLFW_ALPHA_BITS,
    GULI_DEPTH_BITS               = GLFW_DEPTH_BITS,
    GULI_STENCIL_BITS             = GLFW_STENCIL_BITS,
    GULI_ACCUM_RED_BITS           = GLFW_ACCUM_RED_BITS,
    GULI_ACCUM_GREEN_BITS         = GLFW_ACCUM_GREEN_BITS,
    GULI_ACCUM_BLUE_BITS          = GLFW_ACCUM_BLUE_BITS,
    GULI_ACCUM_ALPHA_BITS         = GLFW_ACCUM_ALPHA_BITS,
    GULI_AUX_BUFFERS              = GLFW_AUX_BUFFERS,
    GULI_STEREO                   = GLFW_STEREO,
    GULI_SAMPLES                  = GLFW_SAMPLES,
    GULI_SRGB_CAPABLE             = GLFW_SRGB_CAPABLE,
    GULI_REFRESH_RATE             = GLFW_REFRESH_RATE,
    GULI_DOUBLEBUFFER             = GLFW_DOUBLEBUFFER,
    /* Context hints */
    GULI_CLIENT_API               = GLFW_CLIENT_API,
    GULI_CONTEXT_VERSION_MAJOR    = GLFW_CONTEXT_VERSION_MAJOR,
    GULI_CONTEXT_VERSION_MINOR    = GLFW_CONTEXT_VERSION_MINOR,
    GULI_CONTEXT_REVISION         = GLFW_CONTEXT_REVISION,
    GULI_CONTEXT_ROBUSTNESS       = GLFW_CONTEXT_ROBUSTNESS,
    GULI_OPENGL_FORWARD_COMPAT    = GLFW_OPENGL_FORWARD_COMPAT,
    GULI_OPENGL_DEBUG_CONTEXT     = GLFW_OPENGL_DEBUG_CONTEXT,
    GULI_OPENGL_PROFILE           = GLFW_OPENGL_PROFILE,
    GULI_CONTEXT_RELEASE_BEHAVIOR = GLFW_CONTEXT_RELEASE_BEHAVIOR,
    GULI_CONTEXT_NO_ERROR         = GLFW_CONTEXT_NO_ERROR,
    GULI_CONTEXT_CREATION_API     = GLFW_CONTEXT_CREATION_API,
    GULI_SCALE_TO_MONITOR         = GLFW_SCALE_TO_MONITOR,
    /* Platform-specific (macOS) */
    GULI_COCOA_RETINA_FRAMEBUFFER = GLFW_COCOA_RETINA_FRAMEBUFFER,
    GULI_COCOA_FRAME_NAME         = GLFW_COCOA_FRAME_NAME,
    GULI_COCOA_GRAPHICS_SWITCHING = GLFW_COCOA_GRAPHICS_SWITCHING,
    /* Platform-specific (X11) */
    GULI_X11_CLASS_NAME           = GLFW_X11_CLASS_NAME,
    GULI_X11_INSTANCE_NAME        = GLFW_X11_INSTANCE_NAME,
} GuliHint;

/* Common hint values (for GULI_CLIENT_API, booleans, etc.) */
typedef enum GuliHintValue {
    GULI_TRUE   = GLFW_TRUE,
    GULI_FALSE  = GLFW_FALSE,
    GULI_NO_API = GLFW_NO_API,
    GULI_OPENGL_API     = GLFW_OPENGL_API,
    GULI_OPENGL_ES_API  = GLFW_OPENGL_ES_API,
} GuliHintValue;

/* Input mode (for GuliSetInputMode, see guli_core.h) */
typedef enum GuliInputMode {
    GULI_CURSOR                = GLFW_CURSOR,
    GULI_STICKY_KEYS           = GLFW_STICKY_KEYS,
    GULI_STICKY_MOUSE_BUTTONS  = GLFW_STICKY_MOUSE_BUTTONS,
    GULI_LOCK_KEY_MODS         = GLFW_LOCK_KEY_MODS,
    GULI_RAW_MOUSE_MOTION      = GLFW_RAW_MOUSE_MOTION
} GuliInputMode;

/* Cursor mode (value for GULI_CURSOR input mode) */
typedef enum GuliCursorMode {
    GULI_CURSOR_NORMAL   = GLFW_CURSOR_NORMAL,
    GULI_CURSOR_HIDDEN   = GLFW_CURSOR_HIDDEN,
    GULI_CURSOR_DISABLED = GLFW_CURSOR_DISABLED,
    GULI_CURSOR_CAPTURED = GLFW_CURSOR_CAPTURED
} GuliCursorMode;

/* Input API (backend: take window). Use GuliGetKey/GuliGetMouseButton etc. from guli_core.h for window-less API. */
static inline int GuliBackendGetKey(GuliWindow* window, GuliKey key)
{
    return glfwGetKey(window, (int)key);
}

static inline int GuliBackendGetMouseButton(GuliWindow* window, GuliMouseButton button)
{
    return glfwGetMouseButton(window, (int)button);
}

static inline void GuliBackendGetCursorPos(GuliWindow* window, double* xpos, double* ypos)
{
    glfwGetCursorPos(window, xpos, ypos);
}

static inline void GuliBackendSetInputMode(GuliWindow* window, GuliInputMode mode, int value)
{
    glfwSetInputMode(window, (int)mode, value);
}

/* ---------------------------------------------------------------------------
 * Window API
 * --------------------------------------------------------------------------- */

/* Wrapper functions: type-safe, debuggable, single place to switch backend (e.g. #ifdef GULI_USE_MWSL). */

/* Lifecycle: call before/after any other GULI window functions. */
static inline int GuliBackendInit(void)
{
    return glfwInit();
}

static inline void GuliTerminate(void)
{
    glfwTerminate();
}

/* Window hints: call before GuliWindowCreate. Use GULI_* hints and values. */
static inline void GuliWindowHint(GuliHint hint, int value)
{
    glfwWindowHint((int)hint, value);
}

static inline GuliWindow* GuliWindowCreate(int width, int height, const char* title)
{
    return glfwCreateWindow(width, height, title, NULL, NULL);
}

static inline void GuliBackendWindowDestroy(GuliWindow* window)
{
    glfwDestroyWindow(window);
}

static inline int GuliBackendWindowShouldClose(GuliWindow* window)
{
    return glfwWindowShouldClose(window);
}

static inline void GuliBackendSetWindowShouldClose(GuliWindow* window, int value)
{
    glfwSetWindowShouldClose(window, value);
}

static inline void GuliBackendGetFramebufferSize(GuliWindow* window, int* width, int* height)
{
    glfwGetFramebufferSize(window, width, height);
}

static inline void GuliBackendGetWindowSize(GuliWindow* window, int* width, int* height)
{
    glfwGetWindowSize(window, width, height);
}

static inline void GuliBackendSetWindowTitle(GuliWindow* window, const char* title)
{
    glfwSetWindowTitle(window, title);
}

static inline void GuliWindowPollEvents(void)
{
    glfwPollEvents();
}

static inline double GuliGetTime(void)
{
    return glfwGetTime();
}

static inline void GuliSetTime(double time)
{
    glfwSetTime(time);
}

static inline void GuliBackendSwapBuffers(GuliWindow* window)
{
    glfwSwapBuffers(window);
}

static inline void GuliPollEvents(void)
{
    glfwPollEvents();
}

static inline void GuliSetFPS(int fps)
{
    glfwSwapInterval(fps);
}

static inline void GuliBackendSetKeyCallback(GuliWindow* window, void (*callback)(GuliWindow* window, int key, int scancode, int action, int mods))
{
    glfwSetKeyCallback(window, callback);
}