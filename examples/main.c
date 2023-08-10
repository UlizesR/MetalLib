#include "MACA/mac_render.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include <MACA/maca.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

    // Create a window and renderer
    Mac_Window* window;
    Mac_Renderer* renderer;

    MAC_CreateWindowAndRenderer(800, 600, "Window", MAC_RENDERER_CORE_G, MAC_WINDOW_MINIMIZED | MAC_WINDOW_RESIZABLE, &window, &renderer);
    if (!window || !renderer)
    {
        printf("ERROR: Failed to create window or renderer.\n");
        return 1;
    }

    // Set the renderer's background color
    MAC_SetRendererColor(renderer, MAC_COLOR_BLACK);

    // Define the vertices of a trapezoid
    MFPoint vertices[4];
    vertices[0] = (MFPoint){100, 100}; // Top left
    vertices[1] = (MFPoint){300, 100}; // Top right
    vertices[2] = (MFPoint){250, 200}; // Bottom right
    vertices[3] = (MFPoint){150, 200}; // Bottom left

    // Create a quadrilateral with the trapezoid vertices
    Mac_Quadrilateral* trapezoid = mac_quadrilateral(vertices, MAC_COLOR_WHITE);

    // Draw the trapezoid
    mac_draw_quadrilateral(trapezoid, 2.0, renderer);

    MAC_ClearRenderer(renderer);

    // Main loop
    bool running = true;
    // MAC_Event event;
    while (running) {
        runDelegate();
        if(!isWindowOpen(window)) {
            running = false;
        }
    }

    // Clean up
    free(trapezoid);
    MAC_DestroyRenderer(renderer);
    MAC_DestroyWindow(window);
    printf("Destroyed main window\n");
    MAC_Quit();
    return 0;
}
