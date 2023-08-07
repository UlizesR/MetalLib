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

    Mac_Rect *rect1 = mac_rect((Mac_FPoint){10, 10}, (MSize){50, 50}, MAC_COLOR_RED);

    mac_fill_rect(rect1, contentView);

    Mac_Rect *rect2 = mac_rect((Mac_FPoint){100, 100}, (MSize){50, 50}, MAC_COLOR_RED);

    mac_fill_rect(rect2, contentView);

    MProperties p = {
        .position = {100, 500},
        .size = {100, 50},
    };

    Mac_Slider* Slider = mac_slider(p, 0, 100, 5, contentView, mySliderAction);
    
    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        while (MAC_PollEvent(&event))
        {
            if (event.type == MAC_KEYBOARDEVENT) {
                if (event.keycode == MAC_KEY_D)
                {
                    rect1->origin.x += 10;
                    mac_remove_shape(rect1->base.id, contentView);
                    mac_fill_rect(rect1, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_A)
                {
                    rect1->origin.x -= 10;
                    mac_remove_shape(rect1->base.id, contentView);
                    mac_fill_rect(rect1, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_W)
                {
                    rect1->origin.y += 10;
                    mac_remove_shape(rect1->base.id, contentView);
                    mac_fill_rect(rect1, contentView); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_S)
                {
                    rect1->origin.y -= 10;
                    mac_remove_shape(rect1->base.id, contentView);
                    mac_fill_rect(rect1, contentView); // Redraw the rectangle
                }
            }
        }
        if(!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Cleanup
    destroy_slider(Slider);
    destroy_shape((Mac_Shape*)rect2);
    destroy_shape((Mac_Shape*)rect1);
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
