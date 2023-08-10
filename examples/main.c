#include "MACA/mac_colors.h"
#include "MACA/mac_defs.h"
#include "MACA/mac_view.h"
#include <stdbool.h>
#include <stdio.h>

#include <MACA/maca.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

    Mac_Window* mainWindow = MAC_CreateWindow(800, 600, true, "Main Window", MAC_WINDOW_MINIMIZED | MAC_WINDOW_RESIZABLE);
    if(mainWindow == NULL) {
        fprintf(stderr, "Failed to create main window\n");
        return 1;
    }

    // Create a content view for the main window
    Mac_View* contentView = MAC_AddContentView(mainWindow, MAC_COLOR_BLUE_3, MAC_VIEW_TYPE_NORMAL, NULL);
    if(contentView == NULL) {
        fprintf(stderr, "Failed to create content view\n");
        return 1;
    }

    Mac_View* subView = MAC_AddSubView(contentView, MAC_VIEW_TYPE_NORMAL, 300, 200, 100, 100, 0, MAC_COLOR_GREEN_2, NULL);
    if(subView == NULL) {
        fprintf(stderr, "Failed to create sub view\n");
        return 1;
    }
    // Main loop
    bool running = true;
    // MAC_Event event;
    while (running) {
        runDelegate();
        if(!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    printf("Closing application\n");
    // Cleanup
    MAC_DestroyView(contentView); // Destroy the content view
    MAC_DestroyView(subView); // Destroy the sub view
    printf("Destroyed content view\n");
    MAC_DestroyWindow(mainWindow);
    printf("Destroyed main window\n");
    MAC_Quit();
    return 0;
}