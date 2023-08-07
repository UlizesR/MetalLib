#include "MAC/mac_shapes.h"
#include <MAC/mac.h>
#include <stdbool.h>
#include <stdio.h>

void myButtonAction(Mac_Button* button) {
    printf("Button clicked: %s\n", button->title);
}

void mySliderAction(Mac_Slider* slider) {
    printf("Slider value changed: %f\n", slider->value);
}

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        mac_printError(MAC_ERROR_INIZIALIZATION_FAILED);
        return 1;
    }

    // Create a window
    Mac_Window* mainWindow = createWindow(800, 600, "Main Window");

    // Add a content view to the window with a blue background
    Mac_View* contentView = addContentView(mainWindow, MAC_COLOR_GREEN_2);

    // mac_draw_line(contentView, (Mac_FPoint){100, 10}, (Mac_FPoint){500, 500}, 4.0, MAC_COLOR_RED);

    Mac_Rect *rect = mac_rect((Mac_FPoint){100, 100}, (MSize){200, 300}, MAC_COLOR_RED);

    mac_fill_rect(rect, contentView);

    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        runWindow();
        if(!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Cleanup
    destroy_rect(rect);
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
