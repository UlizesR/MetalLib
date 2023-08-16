#include <MIA/mia.h>

#include <stdio.h>
#include <stdbool.h>

void buttonClick(void *button, void *data)
{
    printf("Button clicked\n");
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
    M_View *view = M_AddContentView(window, M_COLOR_CYAN_8);
    M_View *subview = M_AddSubView(view, 300, 250, 100, 100, 10, M_COLOR_RED_8);
    M_Button *button = M_ButtonSpb1((MSize){100, 25}, (MPoint){100, 100}, "button", "dot.png", subview, buttonClick, NULL);

    while(M_IsWindowOpen(window))
    {
        runDelegate();
    }

    M_DestroyView(subview);
    M_DestroyWindow(window);    
    M_Quit();

    return 0;
}