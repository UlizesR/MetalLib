#pragma once

#include <stdbool.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M_Display {
    int id;                     // The id of the display
    const char* name;           // The name of the display
    int refresh_rate;           // The refresh rate of the display
    bool is_default_display;    // Whether or not the display is the default display
    float scale_factor;         // The backing scale factor of the display
    int resolution_width;       // The resolution width of the display
    int resolution_height;      // The resolution height of the display
    float dpi;                  // The dpi of the display
    int bits_per_pixel;         // The bits per pixel of the display
    const char* color_space;    // The color space of the display
} M_Display;

typedef struct M_DisplayList {
    M_Display* displays;        // The list of displays
    int count;                  // The number of displays
} M_DisplayList;

/*!
    Gets all the displays
    @return the list of displays
*/
M_DisplayList M_GetDisplays();

/*!
    Gets the default display
    @return the default display
*/
M_Display M_GetDefaultDisplay();

/*!
    Gets the display with the given id
    @param id the id of the display
    @return the display with the given id
*/
M_Display M_GetDisplay(int id);

/*!
    Prints the display data to the console
    @param display the display to print
*/
void M_PrintDisplayData(M_Display display);

/*!
    Destroys the display list
    @param list the display list to destroy
*/
void M_DestroyDisplayList(M_DisplayList list);

#ifdef __cplusplus
}
#endif
