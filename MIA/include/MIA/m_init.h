#pragma once

#include <stdint.h>
#include <MacTypes.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    M_INIT_VIDEO = 0x00000001,
    M_INIT_AUDIO = 0x00000010,
    M_INIT_TIMER = 0x00000020,
    M_INIT_JOYSTICK = 0x00000200,
    M_INIT_HAPTIC = 0x00001000,
    M_INIT_GAMECONTROLLER = 0x00002000,
    M_INIT_EVENTS = 0x00004000,
} M_InitFlags;

/*!
    Initializes the MACA library.
    @param flags: the flags to initialize the library with
    @return: 0 on success, -1 on failure
*/
int M_Init(UInt32 flags);

/*!
    Quits the MACA library.
*/
void M_Quit();

#ifdef __cplusplus
}
#endif