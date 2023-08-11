#include <MACA/maca.h>

#include <stdio.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

    Mac_Window* mainWindow = MAC_CreateWindow(800, 600, true, "Main Window", 0);
    Mac_View* contentView = MAC_AddContentView(mainWindow, MAC_COLOR_WHITE, MAC_VIEW_TYPE_NORMAL, NULL);

    bool running = true;
    MAC_Event event;
    while (running) {
        // causes window to remain open
        while (MAC_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    MAC_DestroyView(contentView);
    MAC_DestroyWindow(mainWindow);
    MAC_Quit();

    return 0;
}