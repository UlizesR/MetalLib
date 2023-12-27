#ifndef _MDL_APP_H_
#define _MDL_APP_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#include "MDefs.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface MAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (nonatomic, strong) NSWindow *window;
@end 

#endif

// For setting the version of the app
#define MDL_APP_VERSION(major, minor, patch) #major "." #minor "." #patch

typedef struct MAppInfo
{
    const char *_name;
    const char *_version;
    const char *_author;
    const char *_description;
    const char *_url;
    const char *_icon;
} MAppInfo;

typedef struct MAppInstance
{
    MAppInfo info;
    MWindow *main_window;
    // MView *main_view;
    void *_this;
} MAppInstance;

int MAppInit(MAppInstance *app, int argc, char **argv);

int MTerminateApp(MAppInstance *app);

#ifdef __cplusplus
}
#endif

#endif // _MDL_APP_H_