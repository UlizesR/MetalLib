// mac_error.c
#include "MAC/mac_error.h"
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
        case MAC_ERROR_BUTTON_CREATION_FAILED:
            fprintf(stderr, "Button creation failed.\n");
            break;
        case MAC_ERROR_BUTTON_NOT_FOUND:
            fprintf(stderr, "Button not found.\n");
            break;
        case MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED:
            fprintf(stderr, "Memory allocation for button failed.\n");
            break;
        case MAC_ERROR_BUTTON_FONT_SMALLER_THAN_HEIGHT:
            fprintf(stderr, "Button font is smaller than height.\n");
            break;
        case MAC_ERROR_LABEL_CREATION_FAILED:
            fprintf(stderr, "Label creation failed.\n");
            break;
        case MAC_ERROR_LABEL_NOT_FOUND:
            fprintf(stderr, "Label not found.\n");
            break;
        case MAC_ERROR_LABEL_MEMORY_ALLOCATION_FAILED:
            fprintf(stderr, "Memory allocation for label failed.\n");
            break;
        case MAC_ERROR_IMAGE_CREATION_FAILED:
            fprintf(stderr, "Image creation failed.\n");
            break;
        case MAC_ERROR_IMAGE_NOT_FOUND:
            fprintf(stderr, "Image not found.\n");
            break;
        case MAC_ERROR_IMAGE_MEMORY_ALLOCATION_FAILED:  
            fprintf(stderr, "Memory allocation for image failed.\n");
            break;
        default:
            fprintf(stderr, "Unknown error occurred.\n");
            break;
    }
}
