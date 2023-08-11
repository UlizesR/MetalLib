#include "MACA/mac_events.h"
#include <MACA/maca.h>

#include <stdio.h>
#include <math.h>

typedef struct {
    Mac_Rect* rect;
    Mac_Renderer* renderer;
    MFPoint originalVertices[4]; // Store the original vertices
} ShapeControl;



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

void slider_action(Mac_Slider* slider, void* user_data)
{
    static float previousValue = 0; // Keep track of the previous value
    float delta = slider->value - previousValue; // Calculate the difference

    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Rect* rect = control->rect;

    if (slider->value == 0) {
        // Reset to the original vertices
        for (int i = 0; i < 4; i++) {
            rect->vertices[i] = control->originalVertices[i];
        }
    } else {
        for (int i = 0; i < 4; i++) {
            rect->vertices[i].x += delta; // Move by the difference
        }
    }

    MAC_RemoveShape(rect->base.id, control->renderer);
    MAC_DrawRect(rect, 2.0, control->renderer);

    previousValue = slider->value; // Update the previous value
}

void slider_rotate(Mac_Slider* slider, void* user_data)
{
    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Rect* rect = control->rect;

    // Calculate the center of the shape
    MFPoint center;
    center.x = 0.0f;
    center.y = 0.0f;
    for (int i = 0; i < 4; i++) {
        center.x += rect->vertices[i].x;
        center.y += rect->vertices[i].y;
    }
    center.x /= 4;
    center.y /= 4;

    // Calculate the rotation angle based on the slider's value
    float angle = (slider->value / slider->maxValue) * 360.0f;

    // Rotate around the center of the rectangle
    rotate_around_center(rect->vertices, 4, &center, angle);

    MAC_RemoveShape(rect->base.id, control->renderer);
    MAC_DrawRect(rect, 2.0, control->renderer);
}

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(MAC_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

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
    Mac_View* gui_view = MAC_AddSubView(window->content_view, MAC_VIEW_TYPE_NORMAL, 200, 100, 590, 490, 0, (Mac_Color){0.1, 0, 0.3, 1.0}, NULL);

    Mac_Line* line = MAC_Line((MFPoint){20, 0}, (MFPoint){20, 600}, 2.0, MAC_COLOR_WHITE);
    MAC_DrawLine(renderer, line);

    ShapeControl control1;  
    Mac_Rect* rect = MAC_Rect((MFPoint){20, 540}, (MSize){50, 50}, MAC_COLOR_RED);
    control1.rect = rect;
    control1.renderer = renderer;
    MAC_DrawRect(control1.rect, 2.0, renderer);

    Mac_Slider* slider = MAC_HSlider((MSize){200, 25}, (MPoint){0, 75}, 0, 100, 0.0, MAC_COLOR_RED, gui_view, slider_action, &control1);

    ShapeControl control2;  
    Mac_Rect* rect2 = MAC_Rect((MFPoint){20, 480}, (MSize){50, 50}, MAC_COLOR_GREEN);
    control2.rect = rect2;
    control2.renderer = renderer;
    MAC_DrawRect(control2.rect, 2.0, renderer);

    Mac_Slider* slider2 = MAC_HSlider((MSize){200, 25}, (MPoint){0, 50}, 0, 100, 0.0, MAC_COLOR_GREEN, gui_view, slider_action, &control2);

    ShapeControl control3;
    Mac_Rect* rect3 = MAC_Rect((MFPoint){20, 420}, (MSize){50, 50}, MAC_COLOR_BLUE);
    control3.rect = rect3;
    control3.renderer = renderer;
    MAC_DrawRect(control3.rect, 2.0, renderer);

    Mac_Slider* slider3 = MAC_HSlider((MSize){200, 25}, (MPoint){0, 25}, 0, 100, 0.0, MAC_COLOR_BLUE, gui_view, slider_action, &control3);

    ShapeControl control4;
    Mac_Rect* rect4 = MAC_Rect((MFPoint){20, 300}, (MSize){50, 50}, MAC_COLOR_YELLOW);
    control4.rect = rect4;
    control4.renderer = renderer;
    MAC_DrawRect(control4.rect, 2.0, renderer);

    Mac_Slider* slider4 = MAC_HSlider((MSize){200, 25}, (MPoint){0, 0}, 0, 360, 0.0, MAC_COLOR_YELLOW, gui_view, slider_rotate, &control4);


    for (int i = 0; i < 4; i++) {
        control1.originalVertices[i] = rect->vertices[i];
        control2.originalVertices[i] = rect2->vertices[i];
        control3.originalVertices[i] = rect3->vertices[i];
        control4.originalVertices[i] = rect4->vertices[i];
    }


    bool running = true;
    MAC_Event event;
    while (running) {
        // causes window to remain open
        while (MAC_PollEvent(&event) != 0) { // Poll for events
            if (event.type == MAC_KEYBOARDEVENT)
            {
                if (event.keycode == MAC_KEY_ESCAPE)
                {
                    running = false;
                }
            }
        }
        // Check if the window is still open
        if (!isWindowOpen(window)) {
            running = false;
        }
    }

    MAC_DestroyShape((Mac_Shape*)rect);
    MAC_DestroyShape((Mac_Shape*)rect2);
    MAC_DestroyShape((Mac_Shape*)rect3);
    MAC_DestroyShape((Mac_Shape*)rect4);
    MAC_DestroySlider(slider);
    MAC_DestroySlider(slider2);
    MAC_DestroySlider(slider3);
    MAC_DestroySlider(slider4);
    MAC_DestroyView(gui_view);
    MAC_DestroyWindow(window);
    MAC_Quit();

    return 0;
}