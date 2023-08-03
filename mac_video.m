#include "mac_video.h"
#import <Cocoa/Cocoa.h>
#include <stdio.h>

Video_Display* getConnectedDisplays(int* count) {
    NSArray<NSScreen *> *screens = [NSScreen screens];
    *count = (int)[screens count];
    
    Video_Display* displays = (Video_Display*)malloc(sizeof(Video_Display) * (*count));
    
    for (int i = 0; i < *count; i++) {
        NSScreen *screen = screens[i];
        NSDictionary *description = [screen deviceDescription];
        NSSize displayPixelSize = [[description objectForKey:NSDeviceSize] sizeValue];
        
        char *displayName = malloc(50);  // Allocate memory for the display name
        sprintf(displayName, "Display %d", i);  // Create the display name with the index

        NSRect frame = [screen frame];  // Get the frame of the screen

        float width = frame.size.width;  // Get the width of the screen
        float height = frame.size.height;  // Get the height of the screen
        
        displays[i].name = displayName;
        displays[i].width = width;
        displays[i].height = height;
        displays[i].refreshRate = 60.0;  // Default to 60Hz, you might need additional APIs to get the actual refresh rate
    }
    
    return displays;
}

void printDisplayInfo(Video_Display* displays, int count) {
    for (int i = 0; i < count; i++) {
        printf("%s:\n", displays[i].name);
        printf("Resolution: %dx%d\n", displays[i].width, displays[i].height);
        printf("Refresh Rate: %.2lfHz\n", displays[i].refreshRate);
        printf("\n");
    }
}

void freeDisplays(Video_Display* displays, int count) {
    for (int i = 0; i < count; i++) {
        free((void*)displays[i].name);  // Free the memory allocated for the display name
    }
    free(displays);  // Free the memory allocated for the displays array
    printf("Freed memory for displays\n");
}