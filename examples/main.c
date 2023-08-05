#include "MAC/mac_gui.h"
#include "MAC/mac_pixels.h"
#include <MAC/mac.h>
#include <stdbool.h>
#include <stdio.h>

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
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
