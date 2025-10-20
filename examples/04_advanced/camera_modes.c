//
// test_camera_modes.c
// Demonstrates different camera modes (Free, Orbital, First Person, Third Person)
//

#include "MKL.h"
#include <stdio.h>
#include <math.h>

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - Camera Modes Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    // Setup camera (start in First Person mode)
    renderer->camera = (MKLCamera){
        .position = {0.0f, 2.0f, 10.0f},
        .target = {0.0f, 0.0f, 0.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 45.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
        .roll = 0.0f,
        .mode = MKL_CAMERA_FIRST_PERSON,
        .projection = MKL_CAMERA_PERSPECTIVE,
        .moveSpeed = 5.0f,
        .rotationSpeed = 90.0f,
        .mouseSensitivity = 0.003f
    };
    
    // Enable lighting for better depth perception
    MKLEnableEnhancedRendering(renderer, true);
    
    MKLLight sun = MKLCreateDirectionalLight(
        (vector_float3){-0.5f, -1.0f, -0.3f},
        MKL_COLOR_WHITE,
        0.8f
    );
    MKLAddLight(renderer, sun);
    
    MKLLight ambient = MKLCreateAmbientLight(MKL_COLOR_WHITE, 0.2f);
    MKLAddLight(renderer, ambient);
    
    printf("=== MKL Camera Modes Demo ===\n\n");
    printf("Camera Modes:\n");
    printf("  1 - FREE MODE (fly anywhere, full 6-DOF)\n");
    printf("  2 - FIRST PERSON (FPS-style, locked to ground)\n");
    printf("  3 - ORBITAL (rotate around center point)\n");
    printf("  4 - THIRD PERSON (follow target from behind)\n");
    printf("\nControls:\n");
    printf("  WASD - Move\n");
    printf("  Space/Q - Up/Down\n");
    printf("  Mouse Drag - Look around\n");
    printf("  Mouse Wheel - Zoom (orbital/third person)\n");
    printf("  ESC - Exit\n");
    printf("\nCurrent Mode: FIRST PERSON\n");
    printf("Press 1-4 to switch camera modes!\n\n");
    
    // Mouse control
    float lastMouseX = (float)WIDTH / 2.0f;
    float lastMouseY = (float)HEIGHT / 2.0f;
    bool firstMouse = true;
    
    // Main loop
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(TARGET_FPS) / 1000.0f;
        MKLPollEvents();
        
        // Handle mode switching
        if (MKLIsKeyPressed(MKL_KEY_1)) {
            MKLSetCameraMode(&renderer->camera, MKL_CAMERA_FREE);
            printf("\n→ Camera Mode: FREE (fly anywhere)\n");
        }
        if (MKLIsKeyPressed(MKL_KEY_2)) {
            MKLSetCameraMode(&renderer->camera, MKL_CAMERA_FIRST_PERSON);
            printf("\n→ Camera Mode: FIRST PERSON (FPS)\n");
        }
        if (MKLIsKeyPressed(MKL_KEY_3)) {
            MKLSetCameraMode(&renderer->camera, MKL_CAMERA_ORBITAL);
            renderer->camera.target = (vector_float3){0, 0, 0}; // Set orbit center
            printf("\n→ Camera Mode: ORBITAL (rotate around center)\n");
        }
        if (MKLIsKeyPressed(MKL_KEY_4)) {
            MKLSetCameraMode(&renderer->camera, MKL_CAMERA_THIRD_PERSON);
            renderer->camera.target = (vector_float3){0, 0, 0};
            printf("\n→ Camera Mode: THIRD PERSON\n");
        }
        
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Mouse look (for all modes except orbital)
        if (MKLIsMouseButtonDown(MouseCodeLeft) && renderer->camera.mode != MKL_CAMERA_ORBITAL) {
            const float mouseX = MKLGetMouseX();
            const float mouseY = MKLGetMouseY();
            
            if (firstMouse) {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
                firstMouse = false;
            }
            
            float xOffset = (mouseX - lastMouseX) * renderer->camera.mouseSensitivity * 100.0f;
            float yOffset = (lastMouseY - mouseY) * renderer->camera.mouseSensitivity * 100.0f;
            
            lastMouseX = mouseX;
            lastMouseY = mouseY;
            
            bool rotateAroundTarget = (renderer->camera.mode == MKL_CAMERA_THIRD_PERSON);
            
            MKLCameraYaw(&renderer->camera, xOffset * M_PI / 180.0f, rotateAroundTarget);
            MKLCameraPitch(&renderer->camera, yOffset * M_PI / 180.0f, true, rotateAroundTarget, false);
        } else {
            firstMouse = true;
        }
        
        // Keyboard movement
        float moveSpeed = renderer->camera.moveSpeed * deltaTime;
        bool moveInWorldPlane = (renderer->camera.mode == MKL_CAMERA_FIRST_PERSON || 
                                  renderer->camera.mode == MKL_CAMERA_THIRD_PERSON);
        
        if (MKLIsKeyDown(MKL_KEY_W)) {
            MKLCameraMoveForward(&renderer->camera, moveSpeed, moveInWorldPlane);
        }
        if (MKLIsKeyDown(MKL_KEY_S)) {
            MKLCameraMoveForward(&renderer->camera, -moveSpeed, moveInWorldPlane);
        }
        if (MKLIsKeyDown(MKL_KEY_D)) {
            MKLCameraMoveRight(&renderer->camera, moveSpeed, moveInWorldPlane);
        }
        if (MKLIsKeyDown(MKL_KEY_A)) {
            MKLCameraMoveRight(&renderer->camera, -moveSpeed, moveInWorldPlane);
        }
        if (MKLIsKeyDown(MKL_KEY_SPACE)) {
            MKLCameraMoveUp(&renderer->camera, moveSpeed);
        }
        if (MKLIsKeyDown(MKL_KEY_Q)) {
            MKLCameraMoveUp(&renderer->camera, -moveSpeed);
        }
        
        // Orbital mode - auto-rotate
        if (renderer->camera.mode == MKL_CAMERA_ORBITAL) {
            MKLCameraYaw(&renderer->camera, 0.5f * deltaTime, true);
        }
        
        MKLUpdateInputState();
        
        // Rendering
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, (MKLColor){0.1f, 0.1f, 0.15f, 1.0f});
        
        MKLUpdateCamera(&renderer->camera, 0);
        
        // Draw ground grid
        for (int x = -10; x <= 10; x += 2) {
            for (int z = -10; z <= 10; z += 2) {
                MKLColor color = ((x + z) % 4 == 0) ? MKL_COLOR_GRAY_6 : MKL_COLOR_GRAY_5;
                MKLDrawCube(renderer, (MKLCube){
                    .position = {x, -0.5f, z},
                    .rotation = {0, 0, 0},
                    .width = 1.8f, .height = 0.1f, .depth = 1.8f
                }, color);
            }
        }
        
        // Draw central reference cubes
        float time = MKLGetTime();
        
        // Red cube at origin (orbit target)
        MKLDrawCube(renderer, (MKLCube){
            .position = {0, 1, 0},
            .rotation = {0, time * 20.0f, 0},
            .width = 2, .height = 2, .depth = 2
        }, MKL_COLOR_RED);
        
        // Blue cubes marking axes
        MKLDrawCube(renderer, (MKLCube){
            .position = {5, 0.5f, 0},
            .rotation = {0, 0, 0},
            .width = 1, .height = 1, .depth = 1
        }, MKL_COLOR_BLUE); // +X axis
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {0, 0.5f, 5},
            .rotation = {0, 0, 0},
            .width = 1, .height = 1, .depth = 1
        }, MKL_COLOR_GREEN); // +Z axis
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {0, 5.5f, 0},
            .rotation = {0, 0, 0},
            .width = 1, .height = 1, .depth = 1
        }, MKL_COLOR_YELLOW); // +Y axis
        
        // Draw camera target indicator (for orbital/third person modes)
        if (renderer->camera.mode == MKL_CAMERA_ORBITAL || 
            renderer->camera.mode == MKL_CAMERA_THIRD_PERSON) {
            MKLDrawSphere(renderer, (MKLSphere){
                .position = renderer->camera.target,
                .rotation = {0, 0, 0},
                .radius = 0.3f,
                .segments = 16
            }, MKL_COLOR_CYAN);
        }
        
        MKLEndDrawing(renderer);
    }
    
    // Cleanup
    printf("\nCleaning up...\n");
    MKLClearLights(renderer);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}

