#ifndef MAC_ERROR_H_
#define MAC_ERROR_H_


#ifdef __cplusplus
extern "C" {
#endif

#define MAC_SUCCESS 0
#define MAC_ERROR -1

typedef enum 
{
    MAC_ERROR_INIZIALIZATION_FAILED ,
    MAC_ERROR_WINDOW_CREATION_FAILED,
    MAC_ERROR_WINDOW_NOT_FOUND,
    MAC_ERROR_WINDOW_MEMORY_ALLOCATION_FAILED,
    MAC_ERROR_DELEGATE_INIT_FAILED,
    MAC_ERROR_VIDEO_INIT_FAILED,
    MAC_ERROR_AUDIO_INIT_FAILED,
    MAC_ERROR_TIMER_INIT_FAILED,
    MAC_ERROR_JOYSTICK_INIT_FAILED,
    MAC_ERROR_HAPTIC_INIT_FAILED,
    MAC_ERROR_GAMECONTROLLER_INIT_FAILED,
    MAC_ERROR_EVENTS_INIT_FAILED,
    MAC_ERROR_NO_METAL_DEVICE_FOUND,
    MAC_ERROR_BUTTON_CREATION_FAILED
} MAC_Error;

void mac_printError(MAC_Error error);

#ifdef __cplusplus
}
#endif

#endif // MAC_ERROR_H_