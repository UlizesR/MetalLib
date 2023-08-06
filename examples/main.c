#include "MAC/mac_button.h"
#include <MAC/mac.h>
#include <stdbool.h>
#include <stdio.h>

void myButtonAction(Mac_Button* button) {
    printf("Button clicked: %s\n", button->title);
}

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        mac_printError(MAC_ERROR_INIZIALIZATION_FAILED);
        return 1;
    }

    // Create a window
    MAC_Window* mainWindow = createWindow(800, 600, "Main Window");

    // Add a content view to the window with a blue background
    Mac_View* contentView = addContentView(mainWindow, MAC_COLOR_GREEN_2);

    // add a subview to the content view with a red background
    // Mac_View* subView = addSubView(contentView, 200, 400, 100, 100, MAC_COLOR_RED);

    MProperties p = {
        .position = { 200, 400 },
        .dimensions = { 500, 50 },
    };
    
    // add a button to the content view
    Mac_Button* button = mac_button_rs(p, "car.png", "car", MAC_BUTTON_TYPE_RADIO, 40, true, false, contentView, myButtonAction);
    
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
    destroyButton(button);
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
