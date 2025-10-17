#include <MKL.h>

#include <simd/conversion.h>
#include <simd/matrix.h>
#include <simd/simd.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#import <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

// Movement and camera constants
#define CAMERA_SPEED 0.01f
#define CAMERA_SENSITIVITY 0.05f

// Window dimensions
#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600

// Target framerate
#define TARGET_FPS 60

/**
 * @brief Calculates current CPU usage as a percentage.
 * @return CPU usage (0.0 to 1.0), or -1.0 on error
 */
static double calculateCPUUsage(void)
{
    processor_cpu_load_info_t cpuLoad;
    mach_msg_type_number_t processorMsgCount;
    natural_t processorCount;

    const kern_return_t kr = host_processor_info(mach_host_self(), 
                                                  PROCESSOR_CPU_LOAD_INFO, 
                                                  &processorCount, 
                                                  (processor_info_array_t *)&cpuLoad, 
                                                  &processorMsgCount);
    if (kr != KERN_SUCCESS)
    {
        fprintf(stderr, "Warning: Failed to get CPU info\n");
        return -1.0;
    }

    double totalUser = 0.0;
    double totalSystem = 0.0;
    double totalIdle = 0.0;

    for (natural_t i = 0; i < processorCount; i++)
    {
        totalUser += cpuLoad[i].cpu_ticks[CPU_STATE_USER];
        totalSystem += cpuLoad[i].cpu_ticks[CPU_STATE_SYSTEM];
        totalIdle += cpuLoad[i].cpu_ticks[CPU_STATE_IDLE];
    }

    vm_deallocate(mach_task_self(), (vm_address_t)cpuLoad, processorMsgCount);

    const double total = totalUser + totalSystem + totalIdle;
    if (total == 0.0)
    {
        return 0.0;
    }
    
    return (totalUser + totalSystem) / total;
}

/**
 * @brief Gets current memory usage in bytes.
 * @return Memory usage in bytes, or 0 on error
 */
static natural_t getMemoryUsageInBytes(void)
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    const kern_return_t kerr = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&info,
                                         &size);
    if (kerr == KERN_SUCCESS)
    {
        return info.resident_size;
    }
    else
    {
        fprintf(stderr, "Error with task_info(): %s\n", mach_error_string(kerr));
        return 0;
    }
}

int main(int argc, char *argv[])
{
    (void)argc; // Suppress unused parameter warning
    (void)argv;

    printf("Starting MKL Graphics Library...\n");
    
    // Create window
    MKLWindow *window = MKLCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "MKL Graphics Demo");
    if (!window)
    {
        fprintf(stderr, "ERROR: Failed to create window!\n");
        return EXIT_FAILURE;
    }
    printf("✓ Window created (%dx%d)\n", WINDOW_WIDTH, WINDOW_HEIGHT);

    // Create renderer
    MKLRenderer *renderer = MKLCreateRenderer(window);
    if (!renderer)
    {
        fprintf(stderr, "ERROR: Failed to create renderer!\n");
        MKLDestroyWindow(window);
        return EXIT_FAILURE;
    }
    printf("✓ Renderer initialized\n");
    
    MKLClearRenderer(renderer, MKL_COLOR_MAIN);

    // Initialize scene objects
    const MKLCube cube = {
        .position = {0.0f, 0.0f, 0.0f},
        .rotation = {0.0f, 0.0f, 0.0f},
        .width = 0.5f,
        .height = 0.5f,
        .depth = 0.5f,
    };

    // Initialize camera
    const MKLCamera camera = {
        .position = {0.0f, 0.0f, 4.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 45.0f,
        .aspect = (float)WINDOW_HEIGHT / (float)WINDOW_WIDTH,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
    };
    renderer->camera = camera;
    printf("✓ Camera initialized\n");

    // Movement velocity
    float velocity = 0.0f;

    // Object colors
    const MKLColor cubeColor = MKL_COLOR_ORANGE_5;
    const MKLColor planeColor = MKL_COLOR_PURPLE_4;

    // NOTE: Mesh creation temporarily disabled due to ARC/ModelIO compatibility issues
    // The simple plane/cube drawing works fine
    // MKLMesh plane;
    // MKLMeshPlane(&plane, renderer, 
    //              (vector_float3){0.0f, 0.0f, 0.0f}, 
    //              (vector_float2){10.0f, 10.0f}, 
    //              (simd_uint2){10, 10}, 
    //              (vector_float3){0.0f, 0.0f, 0.0f});

    // MKLMesh sphere;
    // MKLMeshSphere(&sphere, renderer, 
    //               (vector_float3){0.0f, 0.0f, 0.0f}, 
    //               (vector_float3){1.0f, 1.0f, 1.0f}, 
    //               (simd_uint2){32, 32}, 
    //               (vector_float3){0.0f, 0.0f, 0.0f});

    // Animated plane
    MKLPlane plane2 = {
        .position = {0.0f, 0.0f, 0.0f},
        .dimensions = {100.0f, 100.0f},
        .segments = {100, 100},
        .rotation = {-90.0f, 0.0f, 0.0f},
    };
    MKLGetPlaneVertices(&plane2);

    // Wave animation parameters
    const float waveAmplitude = 2.0f;
    const float waveFrequency = 0.05f;

    printf("✓ Scene initialized\n");
    printf("Entering main loop...\n");

    // Main render loop
    while (!MKLWindowShouldClose(window))
    {   
        const float deltaTime = MKLTicks(TARGET_FPS);

        // Poll input events (following GLFW/raylib pattern)
        MKLPollEvents();

        // Update animated plane with wave effect
        for (unsigned int i = 0; i < plane2.segments.x + 2; i++)
        {
            for (unsigned int j = 0; j < plane2.segments.y + 2; j++)
            {
                const float x = (float)i - (float)plane2.segments.x / 2.0f;
                const float y = (float)j - (float)plane2.segments.y / 2.0f;
                const float distance = x * x + y * y;
                const float time = MKLGetTicks() * 0.001f;
                const float z = waveAmplitude * sinf(waveFrequency * distance + time);
                
                const unsigned int index = i * (plane2.segments.x + 1) + j;
                plane2.vertices[index].z = z;
            }
        }

        // Update camera controls
        MKLUpdateCamera(&renderer->camera, MKL_CAMERA_ORBIT);

        // Handle keyboard input for camera movement
        velocity = CAMERA_SPEED * deltaTime;

        // Exit on 'E' key
        if (MKLIsKeyPressed(MKL_KEY_E))
        {
            MKLCloseWindow(window);
        }

        // Camera movement controls (WASD + Space/Q for up/down)
        if (MKLIsKeyDown(MKL_KEY_W))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.forward, velocity));
        }
        if (MKLIsKeyDown(MKL_KEY_S))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.forward, velocity));
        }
        if (MKLIsKeyDown(MKL_KEY_A))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.right, velocity));
        }
        if (MKLIsKeyDown(MKL_KEY_D))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.right, velocity));
        }
        if (MKLIsKeyDown(MKL_KEY_SPACE))
        {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.up, velocity));
        }
        if (MKLIsKeyDown(MKL_KEY_Q))
        {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.up, velocity));
        }

        // Render scene
        MKLBeginDrawing(renderer);
            MKLDrawCube(renderer, cube, cubeColor);
            MKLDrawPlane(renderer, plane2, planeColor);
            MKLDrawAxis(renderer, 2.0f);
        MKLEndDrawing(renderer);

        // Display performance metrics
        const natural_t memoryUsageBytes = getMemoryUsageInBytes();
        const double cpuUsage = calculateCPUUsage();
        const double memoryUsageMB = (double)memoryUsageBytes / (1024.0 * 1024.0);
        printf("Memory: %.2f MB | CPU: %.2f%%\n", memoryUsageMB, cpuUsage * 100.0);
        
        // Update input state for next frame (following raylib pattern)
        MKLUpdateInputState();
    }

    // Cleanup
    printf("\nShutting down...\n");
    
    if (plane2.vertices)
    {
        free(plane2.vertices);
    }
    
    MKLDestroyRenderer(renderer);
    printf("✓ Renderer destroyed\n");
    
    MKLDestroyWindow(window);
    printf("✓ Window destroyed\n");
    
    printf("Goodbye!\n");
    return EXIT_SUCCESS;
}
