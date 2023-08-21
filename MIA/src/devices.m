#import "MIA/devices.h"
#import <Cocoa/Cocoa.h>
#include <stdio.h>

M_DisplayList M_GetDisplays() {
    NSArray<NSScreen *> *screens = [NSScreen screens];
    NSInteger count = [screens count];
    
    M_Display* displays = (M_Display*)malloc(sizeof(M_Display) * count);
    
    for (int i = 0; i < count; i++) {
        NSScreen *screen = screens[i];
        NSRect frame = [screen frame];
        
        displays[i].id = (int)i;
        displays[i].resolution_width = (int)frame.size.width;
        displays[i].resolution_height = (int)frame.size.height;
        
        displays[i].name = screen.colorSpace.localizedName.UTF8String;;
        
        // Get the refresh rate if available
        if ([screen respondsToSelector:@selector(maximumFramesPerSecond)]) {
            displays[i].refresh_rate = (int)screen.maximumFramesPerSecond;
        } else {
            displays[i].refresh_rate = 0; // Default value
        }

        displays[i].color_space = [screen.deviceDescription[@"NSDeviceColorSpaceName"] UTF8String];
        displays[i].bits_per_pixel = [screen.deviceDescription[@"NSDeviceBitsPerPixel"] intValue];
        displays[i].scale_factor = (float)screen.backingScaleFactor;
        displays[i].dpi = displays[i].scale_factor * 96.0f;
        displays[i].is_default_display = (i == 0); // Assuming the first screen is the default
    }

    M_DisplayList list;
    list.displays = displays;
    list.count = (int)count;
    return list;
}

M_Display M_GetDefaultDisplay() {
    M_DisplayList list = M_GetDisplays();
    M_Display defaultDisplay = list.displays[0]; // Assuming the first display is the default
    return defaultDisplay;
}

M_Display M_GetDisplay(int id) {
    M_DisplayList list = M_GetDisplays();
    if (id < 0 || id >= list.count) {
        fprintf(stderr, "Error: Invalid display ID\n");
        M_Display invalidDisplay = {0};
        return invalidDisplay;
    }
    M_Display display = list.displays[id];
    return display;
}

void M_PrintDisplayData(M_Display display)
{
    printf("Display ID: %d\n", display.id);
    printf("Display Name: %s\n", display.name);
    printf("Display Resolution: %dx%d\n", display.resolution_width, display.resolution_height);
    printf("Display Refresh Rate: %d\n", display.refresh_rate);
    printf("Display Color Space: %s\n", display.color_space);
    printf("Display Bits Per Pixel: %d\n", display.bits_per_pixel);
    printf("Display Scale Factor: %f\n", display.scale_factor);
    printf("Display DPI: %f\n", display.dpi);
    printf("Display Is Default: %s\n", display.is_default_display ? "true" : "false");
}

void M_DestroyDisplayList(M_DisplayList list) {
    free(list.displays);
}
