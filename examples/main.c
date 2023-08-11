#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#include <MACA/maca.h>

typedef struct {
    Mac_Quadrilateral* trapezoid;
    Mac_Renderer* renderer;
} ShapeControl;

void move_up(Mac_Button* button, void* user_data) {
    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Quadrilateral* trapezoid = control->trapezoid;
    for (int i = 0; i < 4; i++) {
        trapezoid->vertices[i].y += 5; // Move up
    }
    MAC_RemoveShape(trapezoid->base.id, control->renderer);
    MAC_DrawQuadrilateral(trapezoid, 2.0, control->renderer);
}

void move_down(Mac_Button* button, void* user_data) {
    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Quadrilateral* trapezoid = control->trapezoid;
    for (int i = 0; i < 4; i++) {
        trapezoid->vertices[i].y -= 5; // Move down
    }
    MAC_RemoveShape(trapezoid->base.id, control->renderer);
    MAC_DrawQuadrilateral(trapezoid, 2.0, control->renderer);
}

void move_left(Mac_Button* button, void* user_data) {
    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Quadrilateral* trapezoid = control->trapezoid;
    for (int i = 0; i < 4; i++) {
        trapezoid->vertices[i].x -= 5; // Move left
    }
    MAC_RemoveShape(trapezoid->base.id, control->renderer);
    MAC_DrawQuadrilateral(trapezoid, 2.0, control->renderer);
}

void move_right(Mac_Button* button, void* user_data) {
    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Quadrilateral* trapezoid = control->trapezoid;
    for (int i = 0; i < 4; i++) {
        trapezoid->vertices[i].x += 5; // Move right
    }
    MAC_RemoveShape(trapezoid->base.id, control->renderer);
    MAC_DrawQuadrilateral(trapezoid, 2.0, control->renderer);
}

void radion_click(Mac_Button* button, void* user_data) {
    printf("Radio button clicked\n");
}

void rotate_around_center(MFPoint* vertices, int vertex_count, MFPoint* center, float angle) {
    float radian = angle * (M_PI / 180); // Convert angle to radians
    float cosTheta = cos(radian);
    float sinTheta = sin(radian);

    // Calculate the center of the shape
    center->x = 0.0f;
    center->y = 0.0f;
    for (int i = 0; i < vertex_count; i++) {
        center->x += vertices[i].x;
        center->y += vertices[i].y;
    }
    center->x /= vertex_count;
    center->y /= vertex_count;

    // Translate vertices so that the center is at the origin
    for (int i = 0; i < vertex_count; i++) {
        vertices[i].x -= center->x;
        vertices[i].y -= center->y;
    }

    // Rotate vertices
    for (int i = 0; i < vertex_count; i++) {
        float x = vertices[i].x;
        float y = vertices[i].y;
        vertices[i].x = cosTheta * x - sinTheta * y;
        vertices[i].y = sinTheta * x + cosTheta * y;
    }

    // Translate vertices back
    for (int i = 0; i < vertex_count; i++) {
        vertices[i].x += center->x;
        vertices[i].y += center->y;
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

    int* ud = 0;

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

    ShapeControl control;
    control.trapezoid = trapezoid;
    control.renderer = renderer;

    Mac_Button* button_up = mac_button_rs((MSize){50, 50}, (MPoint){60, 550}, "", "U", 0, 20, true, false, window->content_view, move_up, &control);
    Mac_Button* button_down = mac_button_rs((MSize){50, 50}, (MPoint){60, 500}, "", "D", 0, 20, true, false, window->content_view, move_down, &control);
    Mac_Button* button_left = mac_button_rs((MSize){50, 50}, (MPoint){10, 525}, "", "L", 0, 20, true, false, window->content_view, move_left, &control);
    Mac_Button* button_right = mac_button_rs((MSize){50, 50}, (MPoint){110, 525}, "", "R", 0, 20, true, false, window->content_view, move_right, &control);

    mac_button_scb_tta((MSize){0, 0}, (MPoint){500, 500}, "radio", window->content_view, radion_click, &ud);

    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        clock_t start_time = clock();

        while (MAC_PollEvent(&event) != 0) { // Poll for events
            if (event.type == MAC_KEYBOARDEVENT) {
                if (event.keycode == MAC_KEY_R) {
                    rotate_around_center(trapezoid->vertices, 4, &trapezoid->base.center_point, 10.0); // Rotate by 10 degrees
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
    destroyButton(button_up);
    destroyButton(button_down);
    destroyButton(button_left);
    destroyButton(button_right);
    MAC_DestroyShape((Mac_Shape*)trapezoid);
    MAC_DestroyRenderer(renderer);
    MAC_DestroyWindow(window);
    printf("Destroyed main window\n");
    MAC_Quit();
    return 0;
}
