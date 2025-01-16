# MKL Graphics Library

A C graphics library that uses Apple's Metal API to render graphics. Only works on MacOS.

Run make to see the a working example in the App directory.

## Minimal 3D Code Example

Below is a stripped-down version of the main parts needed to show a cube in 3D.

```c
#include <MKL.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SPEED 0.01f

int main()
{
    // 1. Create a window
    MKLWindow *window = MKLCreateWindow(800, 600, "MKL Window");
    if (window == NULL) {
        printf("Failed to create window!\n");
        return 1;
    }

    // 2. Create a renderer
    MKLRenderer *renderer = MKLCreateRenderer(window);
    if (renderer == NULL) {
        printf("Failed to create renderer!\n");
        return 1;
    }

    // 3. Clear the screen with a default color
    MKLClearRenderer(renderer, MKL_COLOR_MAIN);

    // 4. Create a camera
    MKLCamera camera = {
        .position = {0.0f, 0.0f, 4.0f},
        .up       = {0.0f, 1.0f, 0.0f},
        .forward  = {0.0f, 0.0f, -1.0f},
        .right    = {1.0f, 0.0f, 0.0f},
        .fov      = 45.0f,
        .aspect   = 600.0f / 800.0f, // height / width
        .near     = 0.1f,
        .far      = 100.0f,
        .yaw      = -90.0f,
        .pitch    = 0.0f,
    };
    renderer->camera = camera;

    // 5. Create a cube
    MKLCube cube = {
        .position = {0.0f, 0.0f, 0.0f},
        .rotation = {0.0f, 0.0f, 0.0f},
        .width  = 0.5f,
        .height = 0.5f,
        .depth  = 0.5f,
    };

    // Color for the cube
    MKLColor color = MKL_COLOR_ORANGE_5;

    // Main loop
    while (MKLWindowShouldClose(window))
    {

        // Handle events
        MKLGetPollEvents();

        // Press 'E' to exit
        if (MKLWasKeyPressed(MKL_KEY_E)) {
            MKLCloseWindow(window);
        }

        // 7. Drawing phase
        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, color);
            MKLDrawAxis(renderer, 2.0f); // Draw X, Y, Z axis (optional)
        MKLEndDrawing(renderer);
    }

    // Cleanup
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");
    return 0;
}
```
