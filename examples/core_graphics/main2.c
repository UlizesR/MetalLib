#include "MACA/mac_colors.h"
#include "MACA/mac_defs.h"
#include "MACA/mac_renderer.h"
#include <MACA/maca.h>
#include <stdio.h>

int main(int argc, const char * argv[])
{
    // Initialize the application
    if(M_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }
    printf("MACA initialized\n");
    // Create a window and content view
    M_Window* mainWindow;
    M_Renderer* renderer;
    M_CreateWindowAndRenderer(800, 600, "Metal", M_RENDERER_METAL, 0, &mainWindow, &renderer);
    if (!mainWindow || !renderer)
    {
        printf("ERROR: Failed to create window or renderer.\n");
        return 1;
    }
    printf("Renderer created\n");

    M_SetRendererColor(renderer, M_COLOR_RED);

    // Main loop
    bool running = true;
    M_Event event;
    while (running) {
        // causes window to remain open
        while (M_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Clean up
    M_DestroyRenderer(renderer);
    M_DestroyWindow(mainWindow);
    M_Quit();
    return 0;
}