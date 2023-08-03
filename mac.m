// mac.m
#import "mac.h"
#import "mac_delegate.h"
#include <stdio.h>
#import <Cocoa/Cocoa.h>

// Global variables for Displays and Video Devices
Video_Display* g_displays = NULL;
int g_displayCount = 0;
Video_Device* g_devices = NULL;
int g_deviceCount = 0;

void ignoreApps()
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

}

void MAC_Quit() {
    // Clean up Displays
    if (g_displays != NULL) {
        freeDisplays(g_displays, g_displayCount);
        g_displays = NULL;
        g_displayCount = 0;
    }

    // Clean up Video Devices
    if (g_devices != NULL) {
        g_devices = NULL;
        g_deviceCount = 0;
    }

    // Terminate the delegate
    terminateDelegate();
    printf("Memory has been deallocated and freed. Quitting application\n");
}

int MAC_Init(uint32_t flags) {
    // Initialize the application delegate
    Mac_Delegate* delegate = initDelegate();
    if (delegate == NULL) {
        fprintf(stderr, MAC_ERROR_DELEGATE_INIT_FAILED);
        return -1;
    }

    // Initialize video subsystem
    if (flags & MAC_INIT_VIDEO) {
        // Add video initialization code here
    }

    // Initialize audio subsystem
    if (flags & MAC_INIT_AUDIO) {
        // Add audio initialization code here
    }

    // Initialize timer subsystem
    if (flags & MAC_INIT_TIMER) {
        // Add timer initialization code here
    }

    // Initialize joystick subsystem
    if (flags & MAC_INIT_JOYSTICK) {
        // Add joystick initialization code here
    }

    // Initialize haptic subsystem
    if (flags & MAC_INIT_HAPTIC) {
        // Add haptic initialization code here
    }

    // Initialize game controller subsystem
    if (flags & MAC_INIT_GAMECONTROLLER) {
        // Add game controller initialization code here
    }

    // Initialize events subsystem
    if (flags & MAC_INIT_EVENTS) {
        // Add events initialization code here
    }

    return 0;
}