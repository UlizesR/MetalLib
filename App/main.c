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


    MKLTriangle triangle1 = {
        .p1 = (vector_float2){ 0.5f, 0.125f},
        .p2 = (vector_float2){ 0.625f, -0.125f},
        .p3 = (vector_float2){ 0.375f, -0.125f},
    };

    MKLTriangle triangle2 = {
        .p1 = (vector_float2){ -0.5f, 0.125f},
        .p2 = (vector_float2){ -0.625f, -0.125f},
        .p3 = (vector_float2){ -0.375f, -0.125f},
    };

    MKLRect rect1 = {
        .origin = (vector_float2){ -0.125f, -0.125f },
        .width = 0.25f,
        .height = 0.25f,
    };

    MKLLine line = {
        .p1 = (vector_float2){ 0.0f, 0.0f },
        .p2 = (vector_float2){ 0.5f, 0.5f },
    };

    bool show = false;
    // print triangle1 x coordinates
    // printf("Triangle 1 x coordinates: %f, %f, %f\n", triangle1.vertices[0].x, triangle1.vertices[1].x, triangle1.vertices[2].x);

    int t = 0;

    

    float speed = 0.01f;  // Speed of movement
float direction = 1.0f;  // Direction of movement

    int fps;

    while(MKLWindowShouldClose(window))
    {
        MKLGetPollEvents();

        t++;
        if (MKLWasKeyPressed(MKL_KEY_E))
        {
            MKLCloseWindow(window);
        }

        if (MKLWasKeyPressed(MKL_KEY_SPACE))
        {
            printf("Space pressed! %d\n", t);
        }

        rect1.origin.x += speed * direction;

    // Reverse direction if the rectangle reaches a boundary
    if (rect1.origin.x > 0.75f)
    {
        rect1.origin.x = 0.75f;
        direction = -1.0f;
    }
    else if (rect1.origin.x < -0.75f)
    {
        rect1.origin.x = -0.75f;
        direction = 1.0f;
    }
        
        MKLBeginDrawing(renderer);
            MKLDrawRect(renderer, rect1, MKL_COLOR_RED);
        MKLEndDrawing(renderer);
}

    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}