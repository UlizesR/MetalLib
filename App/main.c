#include <MKL.h>

#include <simd/matrix.h>
#include <simd/simd.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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
    MKLClearRenderer(renderer, MKL_COLOR_MAIN);

    MKLCube cube = {
        .position = {0.0f, 0.0f, 0.0f},
        .width = 0.5f,
        .height = 0.5f,
        .depth = 0.5f,
    };

    renderer->camera;

    MKLSetCamera(&renderer->camera, (vector_float3){0.0f, 0.0f, 4.0f},(vector_float3){0.0f, 1.0f, 0.0f}, 45.0f, 600.0f / 800.0f, 0.1f, 100.0f);

    float vel = 0.0f;

    MKLColor color = MKL_COLOR_RED;

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
        if (MKLWasKeyPressed(MKL_KEY_SPACE))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, MMulVecByScalar(renderer->camera.up, vel));
        }
        if (MKLWasKeyPressed(MKL_KEY_Q))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, MMulVecByScalar(renderer->camera.up, vel));
        }

        if (MKLIsMouseButtonHeldDown(0))
        {
            color = MKL_COLOR_GREEN;
        } else {
            color = MKL_COLOR_RED;
        }

        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, color);
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