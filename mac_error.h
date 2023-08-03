#ifndef MAC_ERROR_H_
#define MAC_ERROR_H_


#ifdef __cplusplus
extern "C" {
#endif

#define MAC_SUCCESS 0
#define MAC_ERROR -1

#define MAC_ERROR_INIZIALIZATION_FAILED "Initialization failed"
#define MAC_ERROR_WINDOW_CREATION_FAILED "Window creation failed"
#define MAC_ERROR_WINDOW_NOT_FOUND "Window not found"
#define MAC_ERROR_WINDOW_MEMORY_ALLOCATION_FAILED "Window memory allocation failed"
#define MAC_ERROR_DELEGATE_INIT_FAILED "Delegate initialization failed"
#define MAC_ERROR_VIDEO_INIT_FAILED "Video initialization failed"
#define MAC_ERROR_AUDIO_INIT_FAILED "Audio initialization failed"
#define MAC_ERROR_TIMER_INIT_FAILED "Timer initialization failed"
#define MAC_ERROR_JOYSTICK_INIT_FAILED "Joystick initialization failed"
#define MAC_ERROR_HAPTIC_INIT_FAILED "Haptic initialization failed"
#define MAC_ERROR_GAMECONTROLLER_INIT_FAILED "Gamecontroller initialization failed"
#define MAC_ERROR_EVENTS_INIT_FAILED "Events initialization failed"
#define MAC_ERROR_NO_METAL_DEVICE_FOUND "No Metal device found"

#ifdef __cplusplus
}
#endif

#endif // MAC_ERROR_H_