#include "MACA/mac_delegate.h"
#include "MACA/mac_window.h"
#include <MACA/maca.h>
#include <stdbool.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    // if(MAC_Init(0) != 0) {
    //     mac_printError(MAC_ERROR_INIZIALIZATION_FAILED);
    //     return 1;
    // }

    Mac_Window* mainWindow = MAC_CreateWindow(800, 600, true, "Main Window", MAC_COLOR_BLACK, 0);
    
    // Main loop
    bool running = true;
    // MAC_Event event;
    while (running) {
        runDelegate();
        if(!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Cleanup
    MAC_DestroyWindow(mainWindow);
    // MAC_Quit();

    return 0;
}
