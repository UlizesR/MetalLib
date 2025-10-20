//
// 01_basics/camera_controls.c
// Learn camera movement and controls
//
// Features demonstrated:
// - Camera movement (WASD)
// - Mouse look
// - Basic scene navigation
//

#include "MKL.h"
#include <math.h>

int main(void) {
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(1200, 800, "01 - Camera Controls");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) return -1;
    
    // Setup camera
    renderer->camera = (MKLCamera){
        .position = {0, 2, 8},
        .target = {0, 0, 0},
        .up = {0, 1, 0},
        .fov = 45.0f,
        .aspect = 800.0f / 1200.0f,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
        .mode = MKL_CAMERA_FIRST_PERSON,
        .moveSpeed = 5.0f,
        .mouseSensitivity = 0.003f
    };
    
    float lastMouseX = 600.0f, lastMouseY = 400.0f;
    bool firstMouse = true;
    
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(60) / 1000.0f;
        MKLPollEvents();
        
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Mouse look
        if (MKLIsMouseButtonDown(MouseCodeLeft)) {
            float mouseX = MKLGetMouseX();
            float mouseY = MKLGetMouseY();
            
            if (firstMouse) {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
                firstMouse = false;
            }
            
            float xOffset = (mouseX - lastMouseX) * 0.1f;
            float yOffset = (lastMouseY - mouseY) * 0.1f;
            lastMouseX = mouseX;
            lastMouseY = mouseY;
            
            MKLCameraYaw(&renderer->camera, xOffset * M_PI / 180.0f, false);
            MKLCameraPitch(&renderer->camera, yOffset * M_PI / 180.0f, true, false, false);
        } else {
            firstMouse = true;
        }
        
        // Keyboard movement
        float speed = renderer->camera.moveSpeed * deltaTime;
        if (MKLIsKeyDown(MKL_KEY_W)) MKLCameraMoveForward(&renderer->camera, speed, true);
        if (MKLIsKeyDown(MKL_KEY_S)) MKLCameraMoveForward(&renderer->camera, -speed, true);
        if (MKLIsKeyDown(MKL_KEY_D)) MKLCameraMoveRight(&renderer->camera, speed, true);
        if (MKLIsKeyDown(MKL_KEY_A)) MKLCameraMoveRight(&renderer->camera, -speed, true);
        if (MKLIsKeyDown(MKL_KEY_SPACE)) MKLCameraMoveUp(&renderer->camera, speed);
        if (MKLIsKeyDown(MKL_KEY_Q)) MKLCameraMoveUp(&renderer->camera, -speed);
        
        MKLUpdateInputState();
        
        // Render
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_MAIN);
        MKLUpdateCamera(&renderer->camera, 0);
        
        
        // Draw colored cubes marking axes
        MKLDrawCube(renderer, (MKLCube){.position = {0, 1, 0}, .rotation = {0, 0, 0}, 
                     .width = 1, .height = 1, .depth = 1}, MKL_COLOR_WHITE); // Origin
        MKLDrawCube(renderer, (MKLCube){.position = {3, 0.5f, 0}, .rotation = {0, 0, 0},
                     .width = 0.5f, .height = 0.5f, .depth = 0.5f}, MKL_COLOR_RED); // +X
        MKLDrawCube(renderer, (MKLCube){.position = {0, 3.5f, 0}, .rotation = {0, 0, 0},
                     .width = 0.5f, .height = 0.5f, .depth = 0.5f}, MKL_COLOR_GREEN); // +Y
        MKLDrawCube(renderer, (MKLCube){.position = {0, 0.5f, 3}, .rotation = {0, 0, 0},
                     .width = 0.5f, .height = 0.5f, .depth = 0.5f}, MKL_COLOR_BLUE); // +Z
        
        MKLEndDrawing(renderer);
    }
    
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    return 0;
}

