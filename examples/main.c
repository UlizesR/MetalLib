#include "MACA/mac_shapes.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <MACA/maca.h>

void rotate_around_center(MFPoint* vertices, float angle) {
    float radian = angle * (M_PI / 180); // Convert angle to radians
    float cosTheta = cos(radian);
    float sinTheta = sin(radian);

    // Calculate the center of the shape
    float centerX = 0.0f;
    float centerY = 0.0f;
    for (int i = 0; i < 4; i++) {
        centerX += vertices[i].x;
        centerY += vertices[i].y;
    }
    centerX /= 4;
    centerY /= 4;

    // Translate vertices so that the center is at the origin
    for (int i = 0; i < 4; i++) {
        vertices[i].x -= centerX;
        vertices[i].y -= centerY;
    }

    // Rotate vertices
    for (int i = 0; i < 4; i++) {
        float x = vertices[i].x;
        float y = vertices[i].y;
        vertices[i].x = cosTheta * x - sinTheta * y;
        vertices[i].y = sinTheta * x + cosTheta * y;
    }

    // Translate vertices back
    for (int i = 0; i < 4; i++) {
        vertices[i].x += centerX;
        vertices[i].y += centerY;
    }
}


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
    Mac_Quadrilateral* trapezoid = MAC_Quadrilateral(vertices, MAC_COLOR_WHITE);

    // Draw the trapezoid
    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);

    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        while (MAC_PollEvent(&event) != 0) { // Poll for events
            if (event.type == MAC_KEYBOARDEVENT) {
                if (event.keycode == MAC_KEY_R) {
                    rotate_around_center(trapezoid->vertices, 10.0); // Rotate by 10 degrees
                    MAC_RemoveShape(trapezoid->base.id, renderer);
                    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);
                }
                if (event.keycode == MAC_KEY_W) {
                    for (int i = 0; i < 4; i++) {
                        trapezoid->vertices[i].y += 5; // Move up
                    }
                    MAC_RemoveShape(trapezoid->base.id, renderer);
                    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);
                }
                if (event.keycode == MAC_KEY_D) {
                    for (int i = 0; i < 4; i++) {
                        trapezoid->vertices[i].x += 5; // Move right         
                    }
                    MAC_RemoveShape(trapezoid->base.id, renderer);
                    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);
                }
                if (event.keycode == MAC_KEY_S) {
                    for (int i = 0; i < 4; i++) {
                        trapezoid->vertices[i].y -= 5; // Move down
                    }
                    MAC_RemoveShape(trapezoid->base.id, renderer);
                    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);
                }
                if (event.keycode == MAC_KEY_A) {
                    for (int i = 0; i < 4; i++) {
                        trapezoid->vertices[i].x -= 5; // Move left
                    }
                    MAC_RemoveShape(trapezoid->base.id, renderer);
                    MAC_DrawQuadrilateral(trapezoid, 2.0, renderer);
                }
            }
        }
       
        // runDelegate();
        if(!isWindowOpen(window)) {
            running = false;
        }
    }

    // Clean up
    MAC_DestroyShape((Mac_Shape*)trapezoid);
    MAC_DestroyRenderer(renderer);
    MAC_DestroyWindow(window);
    printf("Destroyed main window\n");
    MAC_Quit();
    return 0;
}
