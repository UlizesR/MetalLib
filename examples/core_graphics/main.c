/*
    This example demonstrates how to render graphics using the core graphics renderer.
    It also demonstrates how to use sliders and buttons.
    
    The example draws four quadrilaterals, each with a different color. Each quadrilateral
    has a slider that controls its x position. The sliders are also colored to match the
    quadrilateral they control. The sliders are also connected to the quadrilaterals so
    that when the slider is moved, the quadrilateral moves with it. 

    The example also has a button that hides the view containing the sliders.
*/

#include "MACA/mac_text.h"
#include <MACA/maca.h>

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

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

typedef struct {
    M_Quadrilateral* quad;
    M_Renderer* renderer;
    MFPoint originalVertices[4]; // Store the original vertices
} ShapeControl;

void slider_action(M_Slider* slider, void* user_data)
{
    static float previousValue = 0; // Keep track of the previous value
    float delta = slider->value - previousValue; // Calculate the difference

    ShapeControl* control = (ShapeControl*)user_data;
    M_Quadrilateral* quad = control->quad;

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

    M_RemoveShape(quad->base.id, control->renderer);
    M_DrawQuadrilateral(quad, 2.0, control->renderer);

    previousValue = slider->value; // Update the previous value
    printf("Slider value: %f\n", slider->value);
}

void slider_rotate(M_Slider* slider, void* user_data)
{
    static float previousAngle = 0; // Keep track of the previous angle

    ShapeControl* control = (ShapeControl*)user_data;
    M_Quadrilateral* quad = control->quad;

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

    M_RemoveShape(quad->base.id, control->renderer);
    M_DrawQuadrilateral(quad, 2.0, control->renderer);

    // Update the previous angle
    previousAngle = currentAngle;
}

typedef struct ViewControl
{
    M_View* view;
    M_Button* button;
} ViewControl;

void click_button1(M_Button* button, void* user_data)
{
    ViewControl* viewc = (ViewControl*)user_data;
    M_HideButton(viewc->button);
    M_ShowView(viewc->view);
}

void click_button2(M_Button* button, void* user_data)
{
    ViewControl* viewc = (ViewControl*)user_data;
    M_ShowButton(viewc->button);
    M_HideView(viewc->view);
}

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(M_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

    M_Window* window;
    M_Renderer* renderer;

    M_CreateWindowAndRenderer(800, 600, "Window", M_RENDERER_CORE_G, M_WINDOW_MINIMIZED, &window, &renderer);
    if (!window || !renderer)
    {
        printf("ERROR: Failed to create window or renderer.\n");
        return 1;
    }

    // Set the renderer's background color
    M_SetRendererColor(renderer, M_COLOR_BLACK);
    M_View* gui_view = M_AddSubView(window->content_view, M_VIEW_TYPE_NORMAL, 240, 185, 560, 415, 0, M_COLOR_GRAY_3,  NULL);
    M_HideView(gui_view);

    M_Text* gui_text = M_AddText(gui_view, (MPoint){100, 140},(MSize){50,25}, M_COLOR_WHITE, "GUI", 20);
    
    M_Button* button1;
    M_Button* button2;

    ViewControl viewControl;
    viewControl.view = gui_view;
    // Initialize button1 later, after it's created
    viewControl.button = NULL;

    ViewControl viewControl2;
    viewControl2.view = gui_view;

    button1 = M_ButtonRS((MSize){40, 40}, (MPoint){750, 550}, "", "\u25B2", M_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, window->content_view, click_button1, &viewControl);
    viewControl.button = button1;
    viewControl2.button = button1;
    button2 = M_ButtonRS((MSize){40, 40}, (MPoint){190, 135}, "", "\u25BC", M_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, gui_view, click_button2, &viewControl2);

    ShapeControl control1;  
    MFPoint vertices1[4] = {
        {20, 540},
        {70, 540},
        {70, 590},
        {20, 590}
    };
    M_Quadrilateral* quad = M_CreateQuadrilateral(vertices1, M_COLOR_RED);
    control1.quad = quad;
    control1.renderer = renderer;
    M_DrawQuadrilateral(control1.quad, 2.0, renderer);

    M_Slider* slider = M_HRectSlider((MSize){200, 25}, (MPoint){20, 100}, 0, 100, 5.0, M_COLOR_RED, M_COLOR_BLACK, M_COLOR_WHITE, gui_view, slider_action, &control1);

    ShapeControl control2;  
    MFPoint vertices2[4] = {
        {20, 480},
        {70, 480},
        {70, 530},
        {20, 530}
    };
    M_Quadrilateral* quad2 = M_CreateQuadrilateral(vertices2, M_COLOR_GREEN);
    control2.quad = quad2;
    control2.renderer = renderer;
    M_DrawQuadrilateral(control2.quad, 2.0, renderer);

    M_Slider* slider2 = M_HRectSlider((MSize){200, 25}, (MPoint){20, 70}, 0, 100, 5.0, M_COLOR_GREEN, M_COLOR_BLACK, M_COLOR_WHITE, gui_view, slider_action, &control2);

    ShapeControl control3;
    MFPoint vertices3[4] = {
        {20, 420},
        {70, 420},
        {70, 470},
        {20, 470}
    };
    M_Quadrilateral* quad3 = M_CreateQuadrilateral(vertices3, M_COLOR_BLUE);
    control3.quad = quad3;
    control3.renderer = renderer;
    M_DrawQuadrilateral(control3.quad, 2.0, renderer);

    M_Slider* slider3 = M_HRectSlider((MSize){200, 25}, (MPoint){20, 40}, 0, 100, 5.0, M_COLOR_BLUE, M_COLOR_BLACK, M_COLOR_WHITE, gui_view, slider_action, &control3);

    ShapeControl control4;
    MFPoint vertices4[4] = {
        {20, 360},
        {70, 360},
        {70, 410},
        {20, 410}
    };
    M_Quadrilateral* quad4 = M_CreateQuadrilateral(vertices4, M_COLOR_YELLOW);
    control4.quad = quad4;
    control4.renderer = renderer;
    M_DrawQuadrilateral(control4.quad, 2.0, renderer);

    M_Slider* slider4 = M_HRectSlider((MSize){200, 25}, (MPoint){20, 10}, 0, 360, 5.0, M_COLOR_YELLOW, M_COLOR_BLACK, M_COLOR_WHITE, gui_view, slider_rotate, &control4);

    for (int i = 0; i < 4; i++) {
        control1.originalVertices[i] = quad->vertices[i];
        control2.originalVertices[i] = quad2->vertices[i];
        control3.originalVertices[i] = quad3->vertices[i];
        control4.originalVertices[i] = quad4->vertices[i];
    }


    bool running = true;
    M_Event event;
    while (running) {
        // causes window to remain open
        while (M_PollEvent(&event) != 0) { // Poll for events
            if (event.type == M_KEYBOARDEVENT)
            {
                if (event.keycode == M_KEY_ESCAPE)
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


    M_DestroyText(gui_text);
    M_DestroyShape((M_Shape*)quad);
    M_DestroyShape((M_Shape*)quad2);
    M_DestroyShape((M_Shape*)quad3);
    M_DestroyShape((M_Shape*)quad4);
    M_DestroySlider(slider);
    M_DestroySlider(slider2);
    M_DestroySlider(slider3);
    M_DestroySlider(slider4);
    M_DestroyView(gui_view);
    M_DestroyWindow(window);
    M_Quit();

    return 0;
}