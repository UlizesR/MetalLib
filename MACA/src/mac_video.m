// mac_video.m
#include "MACA/mac_video.h"
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>

// Global variable to hold a strong reference to the Metal devices
static NSArray<id<MTLDevice>>* g_devices = nil;

Video_Display* getConnectedDisplays(int* count) {
    NSArray<NSScreen *> *screens = [NSScreen screens];
    *count = (int)[screens count];
    
    Video_Display* displays = (Video_Display*)malloc(sizeof(Video_Display) * (*count));
    
    for (int i = 0; i < *count; i++) {
        NSScreen *screen = screens[i];
        NSDictionary *description = [screen deviceDescription];
        NSNumber *screenNumber = [description objectForKey:@"NSScreenNumber"];
        
        NSRect frame = [screen frame];  // Get the frame of the screen

        float width = frame.size.width;  // Get the width of the screen
        float height = frame.size.height;  // Get the height of the screen
        
        displays[i].id = [screenNumber unsignedIntValue];
        snprintf(displays[i].name, sizeof(displays[i].name), "Display %d", i);
        displays[i].width = width;
        displays[i].height = height;
        displays[i].refreshRate = 60.0;  // Default to 60Hz, 
    }
    
    return displays;
}

Video_Device* getConnectedDevices(int* count) {
    g_devices = MTLCopyAllDevices();
    *count = (int)[g_devices count];
    
    Video_Device* videoDevices = (Video_Device*)malloc(sizeof(Video_Device) * (*count));
    
    for (int i = 0; i < *count; i++) {
        id<MTLDevice> device = g_devices[i];
        
        videoDevices[i].device = (__bridge void*)device;
        videoDevices[i].name = [[device name] UTF8String];
    }
    
    return videoDevices;
}

void printDisplayInfo(Video_Display* displays, int count) {
    for (int i = 0; i < count; i++) {
        printf("%s:\n", displays[i].name);
        printf("Resolution: %dx%d\n", displays[i].width, displays[i].height);
        printf("Refresh Rate: %.2lfHz\n", displays[i].refreshRate);
        printf("\n");
    }
}

void printDeviceInfo(Video_Device* devices, int count) {
    for (int i = 0; i < count; i++) {
        printf("Device %d:\n", i);
        printf("Name: %s\n", devices[i].name);
        printf("\n");
    }
}

void freeDisplays(Video_Display* displays, int count) {
    free(displays);  // Free the memory allocated for the displays array
    displays = NULL;  // Set the pointer to NULL to avoid dangling pointers
    printf("Freed memory for displays\n");
}

void releaseDevices() {
    g_devices = nil;
}
