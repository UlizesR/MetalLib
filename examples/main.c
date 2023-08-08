#include "MACA/mac_shapes.h"
#include "MACA/mac_window.h"
#include <MACA/maca.h>
#include <stdbool.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        mac_printError(MAC_ERROR_INIZIALIZATION_FAILED);
        return 1;
    }

    Mac_Window* mainWindow = createWindow(800, 600, true, "Main Window", MAC_COLOR_BLACK, 0);

     // Define vertices for the polygon
    MFPoint vertices[6];
    vertices[0] = (MFPoint){100, 100};
    vertices[1] = (MFPoint){200, 100};
    vertices[2] = (MFPoint){250, 200};
    vertices[3] = (MFPoint){200, 300};
    vertices[4] = (MFPoint){100, 300};
    vertices[5] = (MFPoint){50, 200};
    
    MFPoint verticesq[] = {{100, 100}, {200, 150}, {150, 250}, {50, 200}};
    Mac_Quadrilateral* myQuad = mac_quadrilateral(verticesq, MAC_COLOR_RED);
    mac_draw_quadrilateral(myQuad, 2, mainWindow->content_view);

    Mac_Ellipse* myEllipse = mac_ellipse((MFPoint){400, 300}, 100, 50, MAC_COLOR_RED);
    mac_draw_ellipse(myEllipse, 2, mainWindow->content_view);
    // Create a polygon
    // Mac_Polygon* polygon = mac_polygon(vertices, 6, MAC_COLOR_RED);
    // // Draw the polygon
    // mac_fill_polygon(polygon, mainWindow->content_view);

    Mac_Rect* rect = mac_rect((MFPoint){100, 100}, (MSize){50, 50}, MAC_COLOR_RED);
    mac_draw_rect(rect, 2.0, mainWindow->content_view);

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
    destroy_shape((Mac_Shape*)myQuad);
    destroy_shape((Mac_Shape*)rect);
    destroy_shape((Mac_Shape*)myEllipse);
    destroyWindow(mainWindow);
    MAC_Quit();

    return MAC_SUCCESS;
}
