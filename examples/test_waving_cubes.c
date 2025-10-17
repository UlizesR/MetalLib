#include "MKL.h"
#include <math.h>

// Color helper function - convert HSV to RGB
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
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - Waving Cubes (Instanced Rendering)");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    // Setup camera (matching raylib example)
    const MKLCamera camera = {
        .position = {30.0f, 20.0f, 30.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 70.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 200.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
    };
    renderer->camera = camera;
    
    printf("=== MKL Waving Cubes Demo ===\n");
    printf("Rendering %d cubes with waving animation!\n", 15 * 15 * 15);
    printf("Controls:\n");
    printf("ESC - Exit\n");
    printf("\nStarting render loop...\n");
    
    // Specify the amount of blocks in each direction
    const int numBlocks = 15;
    const int totalCubes = numBlocks * numBlocks * numBlocks; // 3,375 cubes!
    
    // Allocate arrays for instanced rendering
    MKLCube *cubes = (MKLCube *)malloc(sizeof(MKLCube) * totalCubes);
    MKLColor *colors = (MKLColor *)malloc(sizeof(MKLColor) * totalCubes);
    
    if (!cubes || !colors) {
        fprintf(stderr, "Failed to allocate cube arrays\n");
        return -1;
    }
    
    // Main loop
    int frameCount = 0;
    while (!MKLWindowShouldClose(window)) {
        MKLTicks(TARGET_FPS);
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        MKLUpdateInputState();
        
        // Update
        const double time = MKLGetTime();
        
        // Calculate time scale for cube position and size
        const float scale = (2.0f + sinf(time)) * 0.7f;
        
        // Move camera around the scene
        const double cameraTime = time * 0.3;
        renderer->camera.position.x = cosf(cameraTime) * 40.0f;
        renderer->camera.position.z = sinf(cameraTime) * 40.0f;
        
        // Update camera target to look at origin
        const vector_float3 target = {0.0f, 0.0f, 0.0f};
        renderer->camera.forward = simd_normalize(simd_make_float3(
            target.x - renderer->camera.position.x,
            target.y - renderer->camera.position.y,
            target.z - renderer->camera.position.z
        ));
        renderer->camera.right = simd_normalize(simd_cross(renderer->camera.forward, (vector_float3){0.0f, 1.0f, 0.0f}));
        renderer->camera.up = simd_normalize(simd_cross(renderer->camera.right, renderer->camera.forward));
        
        // Update all cube positions and colors
        int cubeIndex = 0;
        for (int x = 0; x < numBlocks; x++) {
            for (int y = 0; y < numBlocks; y++) {
                for (int z = 0; z < numBlocks; z++) {
                    // Scale of the blocks depends on x/y/z positions
                    const float blockScale = (x + y + z) / 30.0f;
                    
                    // Scatter makes the waving effect by adding blockScale over time
                    const float scatter = sinf(blockScale * 20.0f + (float)(time * 4.0f));
                    
                    // Calculate the cube position
                    cubes[cubeIndex].position = (vector_float3){
                        (float)(x - numBlocks/2) * (scale * 3.0f) + scatter,
                        (float)(y - numBlocks/2) * (scale * 2.0f) + scatter,
                        (float)(z - numBlocks/2) * (scale * 3.0f) + scatter
                    };
                    
                    // No rotation for waving cubes
                    cubes[cubeIndex].rotation = (vector_float3){0.0f, 0.0f, 0.0f};
                    
                    // Calculate cube size
                    const float cubeSize = (2.4f - scale) * blockScale;
                    cubes[cubeIndex].width = cubeSize;
                    cubes[cubeIndex].height = cubeSize;
                    cubes[cubeIndex].depth = cubeSize;
                    
                    // Pick a color with a hue depending on cube position for the rainbow color effect
                    colors[cubeIndex] = ColorFromHSV((float)(((x + y + z) * 18) % 360), 0.75f, 0.9f);
                    
                    cubeIndex++;
                }
            }
        }
        
        // Render
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, (MKLColor){0.231f, 0.278f, 0.322f});
        
        // Update camera matrices
        MKLCameraControls controls = {0};
        MKLUpdateCamera(&renderer->camera, controls);
        
        // Draw all cubes using instanced rendering (1 draw call for 3,375 cubes!)
        MKLDrawCubesInstanced(renderer, cubes, colors, totalCubes);
        
        MKLEndDrawing(renderer);
        
        // Print FPS every 60 frames
        frameCount++;
        if (frameCount % 60 == 0) {
            const float fps = 1000.0f / MKLTicks(TARGET_FPS);
            printf("FPS: %.1f | Cubes: %d | Memory: stable\n", fps, totalCubes);
        }
    }
    
    // Cleanup
    printf("\nCleaning up...\n");
    free(cubes);
    free(colors);
    MKLCleanupShapeCache();
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}

