#include <MKL.h>

#include <stdlib.h>
#include <stdio.h>

#include <simd/simd.h>
#include <math.h>
#include <sys/time.h>

int main(int argc, char *argv[])
{

    MKLWindow *window = MKLCreateWindow(800, 600, "MKL Window");

    if (window == NULL)
    {
        printf("Failed to create window!\n");
        return 1;
    }

    MKLRenderer *renderer = MKLCreateRenderer(window);

    if (renderer == NULL)
    {
        printf("Failed to create renderer!\n");
        return 1;
    }
    MKLClearRenderer(renderer, MKL_COLOR_MAIN);

    MKLCube cube = {
        .position = {0.0f, 0.0f, 0.0f},
        .width = 0.5f,
        .height = 0.5f,
        .depth = 0.5f,
    };

    while(MKLWindowShouldClose(window))
    {
        MKLGetPollEvents();
        
        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, MKL_COLOR_RED);
        MKLEndDrawing(renderer);
    }

    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}