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

    Mac_Rect *rect = mac_rect((Mac_FPoint){10, 10}, (MSize){50, 50}, MAC_COLOR_RED);

    mac_fill_rect(rect, contentView);

    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        while (MAC_PollEvent(&event))
        {
            if (event.type == MAC_KEYBOARDEVENT) {
                if (event.keycode == MAC_KEY_D)
                {
                    printf("D pressed\n");
                    rect->origin.x += 10;
                    updateView(contentView); // Update the view to reflect the changes
                    mac_fill_rect(rect, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_A)
                {
                    printf("A pressed\n");
                    rect->origin.x -= 10;
                    updateView(contentView); // Update the view to reflect the changes
                    mac_fill_rect(rect, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_W)
                {
                    printf("W pressed\n");
                    rect->origin.y += 10;
                    updateView(contentView); // Update the view to reflect the changes
                    mac_fill_rect(rect, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_S)
                {
                    printf("S pressed\n");
                    rect->origin.y -= 10;
                    updateView(contentView); // Update the view to reflect the changes
                    mac_fill_rect(rect, contentView); // Redraw the rectangle
                }
            }
        }
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