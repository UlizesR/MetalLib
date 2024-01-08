#include <MKL.h>

#include <simd/vector_make.h>
#include <stdlib.h>
#include <stdio.h>

#include <simd/simd.h>

int main(int argc, char *argv[])
{
    printf("Hello World!\n");

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


    MKLTriangle triangle1 = {
        .p1 = (vector_float3){ 0.5f, 0.125f, 0.0f },
        .p2 = (vector_float3){ 0.625f, -0.125f, 0.0f },
        .p3 = (vector_float3){ 0.375f, -0.125f, 0.0f },
        .color = MKL_COLOR_RED
    };

    MKLTriangle triangle2 = {
        .p1 = (vector_float3){ -0.5f, 0.125f, 0.0f },
        .p2 = (vector_float3){ -0.625f, -0.125f, 0.0f },
        .p3 = (vector_float3){ -0.375f, -0.125f, 0.0f },
        .color = MKL_COLOR_GREEN
    };

    // print triangle1 x coordinates
    // printf("Triangle 1 x coordinates: %f, %f, %f\n", triangle1.vertices[0].x, triangle1.vertices[1].x, triangle1.vertices[2].x);

    while(MKLWindowShouldClose(window))
    {
        MKLGetPollEvents();

        if (MKLIsKeyPressed(MKL_KEY_W))
        {
            printf("W is pressed!\n");
        }

        if (MKLIsKeyPressed(MKL_KEY_ESCAPE))
        {
            MKLCloseWindow(window);
        }

        MKLBeginDrawing(renderer);
            MKLDrawTriangle(renderer, &triangle1);   
            MKLDrawTriangle(renderer, &triangle2);
        MKLEndDrawing(renderer);
    }

    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}