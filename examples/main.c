#include "MIA/m_delegate.h"
#include <MIA/m_window.h>
#include <MIA/m_init.h>

#include <stdio.h>
#include <stdbool.h>

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

    while(M_IsWindowOpen(window))
    {
        runDelegate();
    }

    M_DestroyWindow(window);
    M_Quit();

    return 0;
}