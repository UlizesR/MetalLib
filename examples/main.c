#include "MAC/mac_shapes.h"
#include <MAC/mac.h>
#include <stdbool.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        mac_printError(MAC_ERROR_INIZIALIZATION_FAILED);
        return 1;
    }


    Mac_Window* mainWindow = createWindow(800, 600, true, "Main Window", MAC_COLOR_BLACK, 0);

    // Add a content view to the window with a blue background

    Mac_Rect *rect1 = mac_rect((MFPoint){10, 10}, (MSize){50, 50}, MAC_COLOR_RED);

    mac_fill_rect(rect1, mainWindow->content_view);

    Mac_Rect *rect2 = mac_rect((MFPoint){100, 100}, (MSize){50, 50}, MAC_COLOR_RED);

    mac_draw_rect(rect2, 2.0, mainWindow->content_view);

    Mac_Triangle* triangle = mac_triangle((MFPoint){200, 200}, (MFPoint){450, 550}, (MFPoint){200, 550}, MAC_COLOR_RED);

    mac_draw_triangle(triangle, 2.0, mainWindow->content_view);

    Mac_Circle* circle = mac_circle((MFPoint){400, 400}, 50, MAC_COLOR_RED);

    mac_fill_circle(circle, mainWindow->content_view);

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
                    mac_remove_shape(rect1->base.id, mainWindow->content_view);
                    mac_fill_rect(rect1, mainWindow->content_view); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_A)
                {
                    rect1->origin.x -= 10;
                    mac_remove_shape(rect1->base.id, mainWindow->content_view);
                    mac_fill_rect(rect1, mainWindow->content_view); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_W)
                {
                    rect1->origin.y += 10;
                    mac_remove_shape(rect1->base.id, mainWindow->content_view);
                    mac_fill_rect(rect1, mainWindow->content_view); // Redraw the rectangle
                }
                if (event.keycode == MAC_KEY_S)
                {
                    rect1->origin.y -= 10;
                    mac_remove_shape(rect1->base.id, mainWindow->content_view);
                    mac_fill_rect(rect1, mainWindow->content_view); // Redraw the rectangle
                }
            }
        }
        if(!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Cleanup
    destroy_shape((Mac_Shape*)circle);
    destroy_shape((Mac_Shape*)triangle);
    destroy_shape((Mac_Shape*)rect2);
    destroy_shape((Mac_Shape*)rect1);
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
