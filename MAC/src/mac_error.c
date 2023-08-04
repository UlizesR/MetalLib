// mac_error.c
#include "mac_error.h"
#include <stdio.h>

void mac_printError(MAC_Error error) {
    switch (error) {
        case MAC_ERROR_INIZIALIZATION_FAILED:
            fprintf(stderr, "Initialization failed.\n");
            break;
        case MAC_ERROR_WINDOW_CREATION_FAILED:
            fprintf(stderr, "Window creation failed.\n");
            break;
        case MAC_ERROR_WINDOW_NOT_FOUND:
            fprintf(stderr, "Window not found.\n");
            break;
        case MAC_ERROR_WINDOW_MEMORY_ALLOCATION_FAILED:
            fprintf(stderr, "Memory allocation for window failed.\n");
            break;
        case MAC_ERROR_DELEGATE_INIT_FAILED:
            fprintf(stderr, "Delegate initialization failed.\n");
            break;
        case MAC_ERROR_VIDEO_INIT_FAILED:
            fprintf(stderr, "Video initialization failed.\n");
            break;
        case MAC_ERROR_AUDIO_INIT_FAILED:
            fprintf(stderr, "Audio initialization failed.\n");
            break;
        case MAC_ERROR_TIMER_INIT_FAILED:
            fprintf(stderr, "Timer initialization failed.\n");
            break;
        case MAC_ERROR_JOYSTICK_INIT_FAILED:
            fprintf(stderr, "Joystick initialization failed.\n");
            break;
        case MAC_ERROR_HAPTIC_INIT_FAILED:
            fprintf(stderr, "Haptic initialization failed.\n");
            break;
        case MAC_ERROR_GAMECONTROLLER_INIT_FAILED:
            fprintf(stderr, "Game controller initialization failed.\n");
            break;
        case MAC_ERROR_EVENTS_INIT_FAILED:
            fprintf(stderr, "Events initialization failed.\n");
            break;
        case MAC_ERROR_NO_METAL_DEVICE_FOUND:
            fprintf(stderr, "No Metal device found.\n");
            break;
        default:
            fprintf(stderr, "Unknown error occurred.\n");
            break;
    }
}
