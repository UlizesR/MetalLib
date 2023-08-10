#ifndef mac_init_h_
#define mac_init_h_


#include <stdint.h>
#include <MacTypes.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MAC_INIT_VIDEO = 0x00000001,
    MAC_INIT_AUDIO = 0x00000010,
    MAC_INIT_TIMER = 0x00000020,
    MAC_INIT_JOYSTICK = 0x00000200,
    MAC_INIT_HAPTIC = 0x00001000,
    MAC_INIT_GAMECONTROLLER = 0x00002000,
    MAC_INIT_EVENTS = 0x00004000,
} MAC_InitFlags;

/*!
    Initializes the MACA library.
    @param flags: the flags to initialize the library with
    @return: 0 on success, -1 on failure
*/
int MAC_Init(UInt32 flags);

/*!
    Quits the MACA library.
*/
void MAC_Quit();

#ifdef __cplusplus
}
#endif

#endif // mac_init_h_