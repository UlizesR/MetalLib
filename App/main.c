#include <MKL.h>

#include <simd/conversion.h>
#include <simd/matrix.h>
#include <simd/simd.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SPEED 0.01f
#define SENSITIVITY 0.05f

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
        .rotation = {0.0f, 0.0f, 0.0f},
        .width = 0.5f,
        .height = 0.5f,
        .depth = 0.5f,
    };

    MKLCamera camera = {
        .position = {0.0f, 0.0f, 4.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 45.0f,
        .aspect = 600.0f / 800.0f,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
    };

    renderer->camera = camera;

    float vel = 0.0f;

    MKLColor color = MKL_COLOR_ORANGE_5;

    MKLMesh plane;
    MKLMeshPlane(&plane, renderer, (vector_float3){0.0f, 0.0f, 0.0f}, (vector_float2){10, 10}, (simd_uint2){10, 10}, (vector_float3){0.0f, 0.0f, 0.0f});

    MKLMesh sphere;
    MKLMeshSphere(&sphere, renderer, (vector_float3){0.0f, 0.0f, 0.0f}, (vector_float3){1.0f, 1.0f, 1.0f}, (simd_uint2){32.0f, 32.0f}, (vector_float3){0.0f, 0.0f, 0.0f});

    MKLMesh capsule;
    MKLMeshCapsule(&capsule, renderer, (vector_float3){0.0f, 0.0f, 0.0f}, (vector_float3){1.0f, 1.0f, 1.0f}, (simd_uint2){32.0f, 4.0f}, (vector_float3){0.0f, 0.0f, 0.0f});
    // MKLPlane plane2 = {
    //     .position = {0.0f, 0.0f, 0.0f},
    //     .dimensions = {100, 100},
    //     .segments = {200, 200},
    //     .rotation = {-90.0f, 0.0f, 00.0f},
    // };

    // MKLGetPlaneVertices(&plane2);

    float a = 2.0f;
    float f = 0.005f;

    while(MKLWindowShouldClose(window))
    {   
        float dt = MKLTicks(60);
        
        // sine wave
        // for (int i = 0; i < plane2.segments.x + 2; i++)
        // {
        //     for (int j = 0; j < plane2.segments.y + 2; j++)
        //     {
        //         float x = (float)i - ((float)(plane2.segments.y) / 2.0f);
        //         float y = (float)j - ((float)(plane2.segments.y) / 2.0f);
        //         float z = a * sinf(f * (x * x + y * y) + MKLGetTicks() * 0.001);
        //         plane2.vertices[i * (plane2.segments.x + 1) + j].z = z;
        //     }
        // }

        MKLUpdateCamera(&renderer->camera, MKL_CAMERA_ORBIT);

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


        // box.rotation.y += SPEED * dt * 10;

        MKLBeginDrawing(renderer);
            // MKLDrawCube(renderer, cube, color);
            MKLDrawMesh(renderer, &plane, MKL_COLOR_PURPLE_4);
            MKLDrawMesh(renderer, &capsule, MKL_COLOR_ORANGE_6);
            // MKLDrawPlane(renderer, plane2, MKL_COLOR_PURPLE_4);
            MKLDrawAxis(renderer, 2.0f);
        MKLEndDrawing(renderer);

    }

    // MKLMeshRelease(&plane);
    // free(plane2.vertices);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}