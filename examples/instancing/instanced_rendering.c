//
// instanced_rendering.c
// High-performance instanced rendering demo for MetalLib (MKL)
//
// Demonstrates:
// - Instanced rendering with MKLDrawCubesInstanced (rendering thousands of cubes in 1 draw call)
// - Dynamic camera movement and auto-rotation
// - Per-instance positioning, rotation, sizing, and coloring
// - Real-time animation with sine wave effects
// - Efficient memory management for large-scale rendering
//
// This example showcases MKL's ability to render thousands of objects efficiently
// using Metal's instancing capabilities, achieving 60+ FPS with 3,375 animated cubes.
//

#include "MKL.h"
#include <math.h>
#include <stdlib.h>

// Color helper function - convert HSV to RGB for rainbow colors
static MKLColor ColorFromHSV(float hue, float saturation, float value) {
    float h = hue / 60.0f;
    float s = saturation;
    float v = value;
    
    int i = (int)floorf(h);
    float f = h - i;
    float p = v * (1.0f - s);
    float q = v * (1.0f - s * f);
    float t = v * (1.0f - s * (1.0f - f));
    
    switch (i % 6) {
        case 0: return (MKLColor){v, t, p, 1.0f};
        case 1: return (MKLColor){q, v, p, 1.0f};
        case 2: return (MKLColor){p, v, t, 1.0f};
        case 3: return (MKLColor){p, q, v, 1.0f};
        case 4: return (MKLColor){t, p, v, 1.0f};
        case 5: return (MKLColor){v, p, q, 1.0f};
        default: return (MKLColor){1.0f, 1.0f, 1.0f, 1.0f};
    }
}

int main(void) {
    const int WIDTH = 1280;
    const int HEIGHT = 720;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - Instanced Rendering Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "❌ Failed to initialize MKL\n");
        return 1;
    }
    
    // Setup camera with perspective projection
    MKLCamera camera = {
        .position = {30.0f, 20.0f, 30.0f},
        .target = {0.0f, 0.0f, 0.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 70.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 200.0f,
        .projection = MKL_CAMERA_PERSPECTIVE,
        .mode = MKL_CAMERA_CUSTOM,  // Custom mode for manual camera control
    };
    renderer->camera = camera;
    
    // Configure cube grid
    const int numBlocks = 15;
    const int totalCubes = numBlocks * numBlocks * numBlocks; // 15³ = 3,375 cubes!
    
    // Allocate arrays for instanced rendering
    MKLCube *cubes = (MKLCube *)malloc(sizeof(MKLCube) * totalCubes);
    MKLColor *colors = (MKLColor *)malloc(sizeof(MKLColor) * totalCubes);
    
    if (!cubes || !colors) {
        fprintf(stderr, "❌ Failed to allocate cube arrays\n");
        return 1;
    }
    
    // Main loop
    
    while (!MKLWindowShouldClose(window)) {
        MKLTicks(TARGET_FPS);
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        MKLUpdateInputState();
        
        // Update animation
        const double time = MKLGetTime();
        
        // Calculate time-based scale for breathing effect
        const float scale = (2.0f + sinf(time)) * 0.7f;
        
        // Rotate camera around the scene
        const double cameraTime = time * 0.3;
        renderer->camera.position.x = cosf(cameraTime) * 40.0f;
        renderer->camera.position.z = sinf(cameraTime) * 40.0f;
        
        // Update camera to look at origin
        vector_float3 target = {0.0f, 0.0f, 0.0f};
        renderer->camera.forward = simd_normalize(simd_make_float3(
            target.x - renderer->camera.position.x,
            target.y - renderer->camera.position.y,
            target.z - renderer->camera.position.z
        ));
        renderer->camera.right = simd_normalize(
            simd_cross(renderer->camera.forward, (vector_float3){0.0f, 1.0f, 0.0f})
        );
        renderer->camera.up = simd_normalize(
            simd_cross(renderer->camera.right, renderer->camera.forward)
        );
        
        // Update all cube positions, sizes, and colors
        int cubeIndex = 0;
        for (int x = 0; x < numBlocks; x++) {
            for (int y = 0; y < numBlocks; y++) {
                for (int z = 0; z < numBlocks; z++) {
                    // Scale of blocks depends on x/y/z positions
                    const float blockScale = (x + y + z) / 30.0f;
                    
                    // Create waving effect using sine wave based on position and time
                    const float scatter = sinf(blockScale * 20.0f + (float)(time * 4.0f));
                    
                    // Calculate cube position with wave effect
                    cubes[cubeIndex].position = (vector_float3){
                        (float)(x - numBlocks/2) * (scale * 3.0f) + scatter,
                        (float)(y - numBlocks/2) * (scale * 2.0f) + scatter,
                        (float)(z - numBlocks/2) * (scale * 3.0f) + scatter
                    };
                    
                    // No rotation (cubes stay axis-aligned)
                    cubes[cubeIndex].rotation = (vector_float3){0.0f, 0.0f, 0.0f};
                    
                    // Calculate cube size with breathing effect
                    const float cubeSize = (2.4f - scale) * blockScale;
                    cubes[cubeIndex].width = cubeSize;
                    cubes[cubeIndex].height = cubeSize;
                    cubes[cubeIndex].depth = cubeSize;
                    
                    // Rainbow color based on position (creates beautiful gradient)
                    colors[cubeIndex] = ColorFromHSV(
                        (float)((x + y + z) * 18 % 360), 
                        0.75f, 
                        0.9f
                    );
                    
                    cubeIndex++;
                }
            }
        }
        
        // Render
        MKLBeginDrawing(renderer);
            MKLClearRenderer(renderer, (MKLColor){0.12f, 0.14f, 0.16f, 1.0f}); // Dark gray background
            
            // Update camera matrices
            MKLCameraControls controls = {0};
            MKLUpdateCamera(&renderer->camera, controls);
            
            // Draw all cubes using instanced rendering
            // This is where the magic happens - 3,375 cubes in ONE draw call!
            MKLDrawCubesInstanced(renderer, cubes, colors, totalCubes);
            
        MKLEndDrawing(renderer);
        
    }
    
    // Cleanup
    printf("\n🧹 Cleaning up...\n");
    free(cubes);
    free(colors);
    MKLCleanupShapeCache();
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}

