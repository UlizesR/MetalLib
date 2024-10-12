#include <MKL.h>

#include <simd/conversion.h>
#include <simd/matrix.h>
#include <simd/simd.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SPEED 0.01f
#define SENSITIVITY 0.05f

#import <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

double calculateCPUUsage()
{
    processor_cpu_load_info_t cpuLoad;
    mach_msg_type_number_t processorMsgCount;
    natural_t processorCount;

    kern_return_t kr = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, (processor_info_array_t *)&cpuLoad, &processorMsgCount);
    if (kr != KERN_SUCCESS) {
        return -1.0;
    }

    double totalUser = 0.0, totalSystem = 0.0, totalIdle = 0.0;

    for (natural_t i = 0; i < processorCount; i++) {
        totalUser += cpuLoad[i].cpu_ticks[CPU_STATE_USER];
        totalSystem += cpuLoad[i].cpu_ticks[CPU_STATE_SYSTEM];
        totalIdle += cpuLoad[i].cpu_ticks[CPU_STATE_IDLE];
    }

    vm_deallocate(mach_task_self(), (vm_address_t)cpuLoad, processorMsgCount);

    double total = totalUser + totalSystem + totalIdle;
    return (totalUser + totalSystem) / total;
}

natural_t getMemoryUsageInBytes() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    } else {
        printf("Error with task_info(): %s\n", mach_error_string(kerr));
        return 0;
    }
}

int main(int argc, char *argv[])
{
    printf("Starting MKL...\n");
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

   
    MKLPlane plane2 = {
        .position = {0.0f, 0.0f, 0.0f},
        .dimensions = {100, 100},
        .segments = {100, 100},
        .rotation = {-90.0f, 0.0f, 00.0f},
    };

    MKLGetPlaneVertices(&plane2);

    float a = 2.0f;
    float f = 0.05f;

    printf("Entering main loop...\n");

    while(MKLWindowShouldClose(window))
    {   
        float dt = MKLTicks(60);

        MKLGetPollEvents();

        for (int i = 0; i < plane2.segments.x + 2; i++)
        {
            for (int j = 0; j < plane2.segments.y + 2; j++)
            {
                float x = (float)i - (float)plane2.segments.x / 2.0f;
                float y = (float)j - (float)plane2.segments.y / 2.0f;
                float z = a * sinf(f * (x * x + y * y) + MKLGetTicks() * 0.001);
                plane2.vertices[i * (plane2.segments.x + 1) + j].z = z;
            }
        }

        MKLUpdateCamera(&renderer->camera, MKL_CAMERA_ORBIT);

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


        // // box.rotation.y += SPEED * dt * 10;

        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, color);
            MKLDrawPlane(renderer, plane2, MKL_COLOR_PURPLE_4);
            MKLDrawAxis(renderer, 2.0f);
        MKLEndDrawing(renderer);

        // Get the memory usage in bytes
        natural_t memoryUsageInBytes = getMemoryUsageInBytes();
        double cpuUsage = calculateCPUUsage();
        // printf("CPU usage: %.2f%%\n", cpuUsage * 100.0);
        // Convert to megabytes
        double memoryUsageInMB = (double)memoryUsageInBytes / 1024 / 1024;
        printf("Memory usage: %.2f MB \t CPU usage: %.2f%%\n", memoryUsageInMB, cpuUsage * 100.0);
    }

    // MKLMeshRelease(&plane);
    free(plane2.vertices);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("Window and renderer destroyed!\n");

    return 0;
}