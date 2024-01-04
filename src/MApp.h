#ifndef _M_APPLICATION_H_
#define _M_APPLICATION_H_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface MAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@end 

#endif // __OBJC__

#include "MError.h"
#include <stdint.h>

#define MAJOR_VERSION(x) ((x) << 16)
#define MINOR_VERSION(x) ((x) << 8)
#define PATCH_VERSION(x) (x)

#define M_APP_VERSION(major, minor, patch) (MAJOR_VERSION(major) | MINOR_VERSION(minor) | PATCH_VERSION(patch))

#define M_APP_VERSION_MAJOR(version) ((version) >> 16)
#define M_APP_VERSION_MINOR(version) (((version) >> 8) & 0xFF)
#define M_APP_VERSION_PATCH(version) ((version) & 0xFF)

#define M_APP_VERSION_STR(version) #version


#define M_APP_GUI 0x01
#define M_APP_CONSOLE 0x02

#define M_APP_TYPE(type) (type)

typedef struct MApplication
{
    const char *_name;
    const char *_version;
    const char *_author;
    const char *_description;
    const char *_url;
    const char *_icon;
    uint32_t _type;
    void *_this;
} MApplication;

/*!
    * @brief Initializes the application.
    * @param appConfig The application configuration.
    * @param argc The number of arguments passed to the application.
    * @param argv The arguments passed to the application.
    * @return MError 
*/
MError MApplicationInit(MApplication *appConfig, int argc, char **argv);

void MRunApplication();

/*!
    * @brief Terminates the application.
    * @return MError
*/
MError MApplicationTerminate();

#endif // _M_APPLICATION_H_