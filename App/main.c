#include <MKL.h>

#include <simd/matrix.h>
#include <simd/matrix_types.h>
#include <stdlib.h>
#include <stdio.h>

#include <simd/simd.h>
#include <math.h>
#include <sys/time.h>

#define SPEED 0.01f

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
    MKLClearRenderer(renderer, MKL_COLOR_WHITE);

    MKLCube cube = {
        .position = {0.0f, 0.0f, 0.0f},
        .width = 0.5f,
        .height = 0.5f,
        .depth = 0.5f,
    };

    renderer->camera;

    MKLSetCamera(&renderer->camera, (vector_float3){0.0f, 0.0f, 4.0f},(vector_float3){0.0f, 1.0f, 0.0f}, 45.0f, 600.0f / 800.0f, 0.1f, 100.0f);

    float vel = 0.0f;
    unsigned int dt = 0.0f;

    while(MKLWindowShouldClose(window))
    {   
       float dt = MKLTicks(60);

        MKLGetPollEvents();

        if (MKLWasKeyPressed(MKL_KEY_E))
        {
            MKLCloseWindow(window);
        }

        vel = SPEED * dt;
        if (MKLWasKeyPressed(MKL_KEY_W))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, MMulVecByScalar(renderer->camera.forward, vel));
        }
        if (MKLWasKeyPressed(MKL_KEY_S))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, MMulVecByScalar(renderer->camera.forward, vel));
        }
        if (MKLWasKeyPressed(MKL_KEY_A))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, MMulVecByScalar(renderer->camera.right, vel));
        }
        if (MKLWasKeyPressed(MKL_KEY_D))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, MMulVecByScalar(renderer->camera.right, vel));
        }

        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, MKL_COLOR_RED);
            // MKLDrawRect(renderer, rect, MKL_COLOR_RED);
            MKLDrawAxis(renderer, 2.0f);
        MKLEndDrawing(renderer);

    }

    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}



double MKLClock()
{

}