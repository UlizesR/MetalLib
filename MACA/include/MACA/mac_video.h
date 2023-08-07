#ifndef mac_video_h_
#define mac_video_h_


#include <stdint.h>
#include <objc/objc.h>
#include <MacTypes.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef UInt32 MAC_DisplayID;

typedef struct Video_Display {
    char name[50];  // Fixed-size array for the display name
    MAC_DisplayID id;
    int width;
    int height;
    double refreshRate;
} Video_Display;

/* 
    struct for video/graphics device information 
    in this case, we will information
    for devices that support Metal
*/
typedef struct Video_Device {
    const char *name;
    void* device;
} Video_Device;

typedef enum 
{
    MAC_SYSTEM_THEME_UNKNOWN,
    MAC_SYSTEM_THEME_LIGHT,
    MAC_SYSTEM_THEME_DARK
} MAC_SystemTheme;

Video_Device* getConnectedDevices(int* count);
void printDeviceInfo(Video_Device* devices, int count);
void releaseDevices();
Video_Display* getConnectedDisplays(int* count);
void printDisplayInfo(Video_Display* displays, int count);
void freeDisplays(Video_Display* displays, int count);

#ifdef __cplusplus
}
#endif


#endif  // mac_video_h_
