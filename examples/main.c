#include <MIA/mia.h>

#include <stdio.h>
#include <stdbool.h>

void buttonClick(void *button, void *data)
{
    printf("Button clicked\n");
}

void sliderAction(void *slider, void *data)
{
    M_Slider *sSlider = (M_Slider*)slider;
    printf("Slider value: %f\n", sSlider->value);
}

int main()
{
    if(M_Init(0) != 0)
    {
        fprintf(stderr, "Error: M_Init() failed\n");
        return 1;
    }

    M_Window* window = M_CreateWindow(800, 600, true, "MIA Window", M_WINDOW_RESIZABLE | M_WINDOW_MINIMIZED);
    if(window == NULL)
    {
        fprintf(stderr, "Error: M_CreateWindow() failed\n");
        M_Quit();
        return 1;
    }
    M_AddContentView(window, M_COLOR_CYAN_8);
    M_View *subview = M_AddSubView(window->content_view, 300, 250, 100, 100, 10, false, M_COLOR_RED_8);

    while(M_IsWindowOpen(window))
    {
        runDelegate();
    }

    M_DestroyView(subview);
    M_DestroyWindow(window);    
    M_Quit();

    return 0;
}