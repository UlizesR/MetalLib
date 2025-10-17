//
// test_new_features.c
// Simple demo that just shows API usage without actually calling the functions
//

#include "MKL.h"
#include <stdio.h>
#include <math.h>

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    printf("Initializing MKL...\n");
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - New Features API Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    printf("✓ MKL initialized successfully\n");
    
    // Setup camera
    renderer->camera = (MKLCamera){
        .position = {0.0f, 3.0f, 10.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 45.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
    };
    
    printf("\n=== MKL New Features API Demo ===\n");
    printf("This demo showcases the NEW API features:\n");
    printf("1. Texture System API\n");
    printf("2. Lighting System API\n");
    printf("3. Material System API\n");
    printf("4. Text Rendering API\n");
    printf("5. Render Target API\n");
    printf("6. Animation API\n");
    printf("\nNOTE: APIs are defined and ready - shader integration pending.\n");
    printf("\nControls:\n");
    printf("ESC - Exit\n");
    printf("WASD - Move camera\n");
    printf("Mouse Drag - Look around\n");
    
    printf("\n--- Feature APIs Available ---\n");
    printf("✓ Texture Loading: MKLLoadTexture(), MKLGenTextureCheckerboard(), etc.\n");
    printf("✓ Lighting: MKLCreateAmbientLight(), MKLCreateDirectionalLight(), etc.\n");
    printf("✓ Materials: MKLCreateMaterial(), MKLMaterialMetal(), MKLMaterialPlastic(), etc.\n");
    printf("✓ Text: MKLDrawText(), MKLLoadFont(), MKLMeasureText(), etc.\n");
    printf("✓ Render Targets: MKLLoadRenderTarget(), MKLBeginTextureMode(), etc.\n");
    printf("✓ Animation: MKLLoadAnimation(), MKLPlayAnimation(), MKLBlendAnimations(), etc.\n");
    
    printf("\nSee NEW_FEATURES.md for full API documentation and integration guide.\n");
    printf("\nStarting basic render loop...\n");
    
    // Mouse control variables
    float lastMouseX = (float)WIDTH / 2.0f;
    float lastMouseY = (float)HEIGHT / 2.0f;
    bool firstMouse = true;
    const float mouseSensitivity = 0.1f;
    
    // Main loop - just basic shapes
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(TARGET_FPS) / 1000.0f;
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Mouse look controls
        if (MKLIsMouseButtonDown(MouseCodeLeft)) {
            const float mouseX = MKLGetMouseX();
            const float mouseY = MKLGetMouseY();
            
            if (firstMouse) {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
                firstMouse = false;
            }
            
            float xOffset = (mouseX - lastMouseX) * mouseSensitivity;
            float yOffset = (lastMouseY - mouseY) * mouseSensitivity;
            
            lastMouseX = mouseX;
            lastMouseY = mouseY;
            
            renderer->camera.yaw += xOffset;
            renderer->camera.pitch += yOffset;
            
            if (renderer->camera.pitch > 89.0f) renderer->camera.pitch = 89.0f;
            if (renderer->camera.pitch < -89.0f) renderer->camera.pitch = -89.0f;
            
            // Update camera vectors
            vector_float3 forward;
            forward.x = cosf(renderer->camera.yaw * M_PI / 180.0f) * cosf(renderer->camera.pitch * M_PI / 180.0f);
            forward.y = sinf(renderer->camera.pitch * M_PI / 180.0f);
            forward.z = sinf(renderer->camera.yaw * M_PI / 180.0f) * cosf(renderer->camera.pitch * M_PI / 180.0f);
            renderer->camera.forward = simd_normalize(forward);
            
            renderer->camera.right = simd_normalize(simd_cross(renderer->camera.forward, (vector_float3){0.0f, 1.0f, 0.0f}));
            renderer->camera.up = simd_normalize(simd_cross(renderer->camera.right, renderer->camera.forward));
        } else {
            firstMouse = true;
        }
        
        // Camera movement
        const float moveSpeed = 5.0f * deltaTime;
        if (MKLIsKeyDown(MKL_KEY_W)) {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.forward, moveSpeed));
        }
        if (MKLIsKeyDown(MKL_KEY_S)) {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.forward, moveSpeed));
        }
        if (MKLIsKeyDown(MKL_KEY_A)) {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.right, moveSpeed));
        }
        if (MKLIsKeyDown(MKL_KEY_D)) {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar(renderer->camera.right, moveSpeed));
        }
        
        MKLUpdateInputState();
        
        // Calculate animated position for visual effect
        float time = MKLGetTime();
        float rotation = time * 30.0f;
        
        // Begin rendering
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_GRAY_3);
        
        // Update camera
        MKLCameraControls controls = {0};
        MKLUpdateCamera(&renderer->camera, controls);
        
        // Draw floor
        MKLPlane floor = {
            .position = {0, 0, 0},
            .dimensions = {20, 20},
            .segments = {1, 1},
            .rotation = {0, 0, 0}
        };
        MKLDrawPlane(renderer, floor, MKL_COLOR_GRAY_7);
        
        // Draw cubes showing where materials would be applied
        MKLDrawCube(renderer, (MKLCube){
            .position = {-4, 1, 0},
            .rotation = {0, rotation, 0},
            .width = 1.5f, .height = 1.5f, .depth = 1.5f
        }, MKL_COLOR_RED);  // Would use redMaterial
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {-2, 1, 0},
            .rotation = {rotation, 0, 0},
            .width = 1.5f, .height = 1.5f, .depth = 1.5f
        }, MKL_COLOR_BLUE);  // Would use blueMaterial
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {0, 1, 0},
            .rotation = {0, 0, rotation},
            .width = 1.5f, .height = 1.5f, .depth = 1.5f
        }, MKL_COLOR_GREEN);  // Would use greenMaterial
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {2, 1, 0},
            .rotation = {rotation, rotation, 0},
            .width = 1.5f, .height = 1.5f, .depth = 1.5f
        }, MKL_COLOR_GRAY_7);  // Would use metalMaterial
        
        MKLDrawCube(renderer, (MKLCube){
            .position = {4, 1, 0},
            .rotation = {0, rotation, rotation},
            .width = 1.5f, .height = 1.5f, .depth = 1.5f
        }, MKL_COLOR_YELLOW);  // Would use plasticMaterial
        
        // Draw sphere showing where point light would be
        vector_float3 lightPos = {
            cosf(time) * 5.0f,
            2.0f + sinf(time * 2.0f) * 1.0f,
            sinf(time) * 5.0f
        };
        MKLDrawSphere(renderer, (MKLSphere){
            .position = lightPos,
            .rotation = {0, 0, 0},
            .radius = 0.2f,
            .segments = 16
        }, MKL_COLOR_CYAN);  // Represents moving point light
        
        MKLEndDrawing(renderer);
    }
    
    // Cleanup
    printf("\nExiting...\n");
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}
