#include <MACA/maca.h>

#include <stdio.h>

typedef struct {
    Mac_Rect* rect;
    Mac_Renderer* renderer;
} ShapeControl;

void slider_action(Mac_Slider* slider, void* user_data)
{
    static float previousValue = 0; // Keep track of the previous value
    float delta = slider->value - previousValue; // Calculate the difference

    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Rect* rect = control->rect;
    for (int i = 0; i < 4; i++) {
        rect->vertices[i].x += delta; // Move by the difference
    }

    MAC_RemoveShape(rect->base.id, control->renderer);
    MAC_DrawRect(rect, 2.0, control->renderer);

    previousValue = slider->value; // Update the previous value
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
    Mac_View* subView = MAC_AddSubView(window->content_view, MAC_VIEW_TYPE_NORMAL, 200, 100, 590, 490, 0, (Mac_Color){0.1, 0, 0.3, 1.0}, NULL);

    ShapeControl control1;  
    Mac_Rect* rect = MAC_Rect((MFPoint){20, 540}, (MSize){50, 50}, MAC_COLOR_RED);
    control1.rect = rect;
    control1.renderer = renderer;
    MAC_DrawRect(control1.rect, 2.0, renderer);

    Mac_Slider* slider = MAC_HSlider((MSize){200, 25}, (MPoint){0, 0}, 0, 100, 0.0, MAC_COLOR_RED, subView, slider_action, &control1);
    bool running = true;
    MAC_Event event;
    while (running) {
        // causes window to remain open
        while (MAC_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(window)) {
            running = false;
        }
    }

    MAC_DestroyShape((Mac_Shape*)rect);
    MAC_DestroySlider(slider);
    MAC_DestroyView(subView);
    MAC_DestroyWindow(window);
    MAC_Quit();

    return 0;
}