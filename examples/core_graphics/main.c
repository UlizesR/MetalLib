#include "MACA/mac_buttons.h"
#include "MACA/mac_view.h"
#include <MACA/maca.h>

#include <stdio.h>
#include <math.h>

typedef struct {
    Mac_Quadrilateral* quad;
    Mac_Renderer* renderer;
    MFPoint originalVertices[4]; // Store the original vertices
} ShapeControl;



void rotate_around_center(MFPoint* vertices, int vertex_count, MFPoint* center, float angle) 
{
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
    Mac_Quadrilateral* quad = control->quad;

    if (slider->value == 0) {
        // Reset to the original vertices
        for (int i = 0; i < 4; i++) {
            quad->vertices[i] = control->originalVertices[i];
        }
    } else {
        for (int i = 0; i < 4; i++) {
            quad->vertices[i].x += delta; // Move by the difference
        }
    }

    MAC_RemoveShape(quad->base.id, control->renderer);
    MAC_DrawQuadrilateral(quad, 2.0, control->renderer);

    previousValue = slider->value; // Update the previous value
}

void slider_rotate(Mac_Slider* slider, void* user_data)
{
    static float previousAngle = 0; // Keep track of the previous angle

    ShapeControl* control = (ShapeControl*)user_data;
    Mac_Quadrilateral* quad = control->quad;

    // Calculate the center of the shape
    MFPoint center;
    center.x = 0.0f;
    center.y = 0.0f;
    for (int i = 0; i < 4; i++) {
        center.x += quad->vertices[i].x;
        center.y += quad->vertices[i].y;
    }
    center.x /= 4;
    center.y /= 4;

    // Calculate the current rotation angle based on the slider's value
    float currentAngle = slider->value;

    // Calculate the difference between the current angle and the previous angle
    float angleDifference = currentAngle - previousAngle;

    // Rotate around the center of the quadrilateral by the angle difference
    rotate_around_center(quad->vertices, 4, &center, -angleDifference);

    MAC_RemoveShape(quad->base.id, control->renderer);
    MAC_DrawQuadrilateral(quad, 2.0, control->renderer);

    // Update the previous angle
    previousAngle = currentAngle;
}

typedef struct ViewControl
{
    Mac_View* view;
    Mac_Button* button;
} ViewControl;

void click_button1(Mac_Button* button, void* user_data)
{
    ViewControl* viewc = (ViewControl*)user_data;
    MAC_HideButton(viewc->button);
    MAC_ShowView(viewc->view);
}

void click_button2(Mac_Button* button, void* user_data)
{
    ViewControl* viewc = (ViewControl*)user_data;
    MAC_ShowButton(viewc->button);
    MAC_HideView(viewc->view);
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
    Mac_View* gui_view = MAC_AddSubView(window->content_view, MAC_VIEW_TYPE_NORMAL, 240, 150, 550, 440, 20, MAC_COLOR_MAGENTA_5, NULL);
    MAC_HideView(gui_view);

    Mac_Button* button1;
    Mac_Button* button2;

    ViewControl viewControl;
    viewControl.view = gui_view;
    // Initialize button1 later, after it's created
    viewControl.button = NULL;

    ViewControl viewControl2;
    viewControl2.view = gui_view;

    button1 = MAC_ButtonRS((MSize){25, 25}, (MPoint){765, 565}, "", "\u25B2", MAC_BUTTON_TYPE_MOMENTARY_PUSH_IN, 10, true, false, window->content_view, click_button1, &viewControl);
    viewControl.button = button1;
    viewControl2.button = button1;
    button2 = MAC_ButtonRS((MSize){25, 25}, (MPoint){210, 120}, "", "\u25BC", MAC_BUTTON_TYPE_MOMENTARY_PUSH_IN, 10, true, false, gui_view, click_button2, &viewControl2);
    

    ShapeControl control1;  
    MFPoint vertices1[4] = {
        {20, 540},
        {70, 540},
        {70, 590},
        {20, 590}
    };
    Mac_Quadrilateral* quad = MAC_Quadrilateral(vertices1, MAC_COLOR_RED);
    control1.quad = quad;
    control1.renderer = renderer;
    MAC_DrawQuadrilateral(control1.quad, 2.0, renderer);

    Mac_Slider* slider = MAC_HSlider((MSize){200, 25}, (MPoint){5, 75}, 0, 100, 0.0, MAC_COLOR_RED, gui_view, slider_action, &control1);

    ShapeControl control2;  
    MFPoint vertices2[4] = {
        {20, 480},
        {70, 480},
        {70, 530},
        {20, 530}
    };
    Mac_Quadrilateral* quad2 = MAC_Quadrilateral(vertices2, MAC_COLOR_GREEN);
    control2.quad = quad2;
    control2.renderer = renderer;
    MAC_DrawQuadrilateral(control2.quad, 2.0, renderer);

    Mac_Slider* slider2 = MAC_HSlider((MSize){200, 25}, (MPoint){5, 50}, 0, 100, 0.0, MAC_COLOR_GREEN, gui_view, slider_action, &control2);

    ShapeControl control3;
    MFPoint vertices3[4] = {
        {20, 420},
        {70, 420},
        {70, 470},
        {20, 470}
    };
    Mac_Quadrilateral* quad3 = MAC_Quadrilateral(vertices3, MAC_COLOR_BLUE);
    control3.quad = quad3;
    control3.renderer = renderer;
    MAC_DrawQuadrilateral(control3.quad, 2.0, renderer);

    Mac_Slider* slider3 = MAC_HSlider((MSize){200, 25}, (MPoint){5, 25}, 0, 100, 0.0, MAC_COLOR_BLUE, gui_view, slider_action, &control3);

    ShapeControl control4;
    MFPoint vertices4[4] = {
        {20, 360},
        {70, 360},
        {70, 410},
        {20, 410}
    };
    Mac_Quadrilateral* quad4 = MAC_Quadrilateral(vertices4, MAC_COLOR_YELLOW);
    control4.quad = quad4;
    control4.renderer = renderer;
    MAC_DrawQuadrilateral(control4.quad, 2.0, renderer);

    Mac_Slider* slider4 = MAC_HSlider((MSize){200, 25}, (MPoint){5, 0}, 0, 360, 0.0, MAC_COLOR_YELLOW, gui_view, slider_rotate, &control4);


    for (int i = 0; i < 4; i++) {
        control1.originalVertices[i] = quad->vertices[i];
        control2.originalVertices[i] = quad2->vertices[i];
        control3.originalVertices[i] = quad3->vertices[i];
        control4.originalVertices[i] = quad4->vertices[i];
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

    MAC_DestroyShape((Mac_Shape*)quad);
    MAC_DestroyShape((Mac_Shape*)quad2);
    MAC_DestroyShape((Mac_Shape*)quad3);
    MAC_DestroyShape((Mac_Shape*)quad4);
    MAC_DestroySlider(slider);
    MAC_DestroySlider(slider2);
    MAC_DestroySlider(slider3);
    MAC_DestroySlider(slider4);
    MAC_DestroyView(gui_view);
    MAC_DestroyWindow(window);
    MAC_Quit();

    return 0;
}