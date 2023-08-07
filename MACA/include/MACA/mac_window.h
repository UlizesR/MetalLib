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
Mac_Window* createWindow(int width, int height, bool is_main_window, MTitle title, Mac_Color background_color, UInt32 flags);
void closeWindow(Mac_Window* window);
bool isWindowOpen(Mac_Window* window);
void destroyWindow(Mac_Window* window);
void runWindow();
/*
    Functions for managing window hierarchies
*/
void addChildWindow(Mac_Window* parent, Mac_Window* child);
void removeChildWindow(Mac_Window* parent, Mac_Window* child);

/*
    Functions for managing window flags
*/
void setWindowFlags(Mac_Window* window, UInt32 flags);

#ifdef __cplusplus
}
#endif

#endif // mac_window_h_