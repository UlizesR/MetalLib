#ifndef _M_APPLICATION_H_
#define _M_APPLICATION_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface MAppDelegate : NSObject <NSApplicationDelegate>
@end

@interface MWindowDelegate : NSObject <NSWindowDelegate>
@end

#endif // __OBJC__

#include "MError.h"
#include "MDefs.h"

#include <stdint.h>

typedef struct MApplication 
{
    const char *_name;
    const char *_version;
    const char *_author;
    const char *_description;
    const char *_url;
    const char *_icon;
    int _type;
#ifdef __OBJC__
    MAppDelegate *_delegate;
#endif // __OBJC__
} MApplication;

/*!
    * @brief Initializes the application.
    * @param appConfig The application configuration.
    * @param argc The number of arguments passed to the application.
    * @param argv The arguments passed to the application.
    * @return MError 
*/
MAPI MError MApplicationInit(MApplication *appConfig, int argc, char **argv);

/*!
    * @brief The main application loop.
*/
MAPI void MRunApplication();

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

#ifdef __OBJC__
    NSWindow *_window;
    MWindowDelegate *_delegate;
#endif // __OBJC__
};

typedef enum {
    MWINDOW_FLAG_NONE = 0,
    MWINDOW_FLAG_RESIZABLE = 1 << 0,
    MWINDOW_FLAG_MINIMIZABLE = 1 << 1,
    MWINDOW_FLAG_MAXIMIZABLE = 1 << 2,
    MWINDOW_FLAG_FULLSCREEN = 1 << 3,
} MWindowFlags;

/*!
    * @brief Creates The application main window.
    * @param width The width of the window.
    * @param height The height of the window.
    * @param title The title of the window.
    * @return MWindow
*/
MAPI MWindow *MMainAppWindow(int width, int height, const char *title);

/*!
    * @brief Checks if the window should close.
    * @param window The window.
*/
MAPI MBool MWindowShouldClose(MWindow *window);

/*!
    * @brief Deallocates the window from memory.
    * @param window The window.
*/
MAPI void MDestroyWindow(MWindow *window);

#ifdef __cplusplus
}
#endif

#endif // _M_APPLICATION_H_