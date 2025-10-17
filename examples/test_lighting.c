//
// test_lighting.c  
// Demonstrates lighting system with enhanced shaders
//

#include "MKL.h"
#include <stdio.h>
#include <math.h>

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    printf("=== MKL Lighting Demo ===\n");
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - Lighting System Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
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
    
    printf("\n--- Setting up lighting ---\n");
    
    // ENABLE ENHANCED RENDERING (this makes lighting visible!)
    MKLEnableEnhancedRendering(renderer, true);
    
    // Create ambient light for base illumination
    MKLLight ambient = MKLCreateAmbientLight(MKL_COLOR_WHITE, 0.15f);
    MKLAddLight(renderer, ambient);
    printf("✓ Ambient light added\n");
    
    // Create directional light (sun) for clear directional shadows
    MKLLight sun = MKLCreateDirectionalLight(
        (vector_float3){-0.5f, -1.0f, -0.3f},
        MKL_COLOR_WHITE,
        0.7f
    );
    MKLAddLight(renderer, sun);
    printf("✓ Directional light added\n");
    
    // Create moving point light for dynamic lighting
    MKLLight pointLight = MKLCreatePointLight(
        (vector_float3){0, 2, 0},
        (MKLColor){0.2f, 0.6f, 1.0f, 1.0f},  // Bright blue
        5.0f,  // Increased intensity
        15.0f
    );
    int pointIdx = MKLAddLight(renderer, pointLight);
    printf("✓ Point light added (bright blue)\n");
    
    printf("Total lights: %d\n", MKLGetLightCount(renderer));
    
    // Enable lighting
    MKLEnableLighting(renderer, true);
    
    printf("\nControls:\n");
    printf("ESC - Exit\n");
    printf("WASD - Move camera\n");
    printf("Mouse Drag - Look around\n");
    printf("Space/Q - Move up/down\n");
    printf("L - Toggle enhanced rendering (lighting) on/off\n");
    printf("\nWhat to look for:\n");
    printf("- Cubes will have SHINY HIGHLIGHTS from directional light\n");
    printf("- Moving blue sphere shows POINT LIGHT position\n");
    printf("- Cubes near the blue light will have BLUE TINT\n");
    printf("- Dark sides vs bright sides show DIRECTIONAL LIGHTING\n");
    printf("- Specular highlights show REFLECTIVE surfaces\n");
    printf("\nStarting render loop...\n");
    
    // Mouse control variables
    float lastMouseX = (float)WIDTH / 2.0f;
    float lastMouseY = (float)HEIGHT / 2.0f;
    bool firstMouse = true;
    const float mouseSensitivity = 0.1f;
    bool lightingOn = true;
    
    // Main loop
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(TARGET_FPS) / 1000.0f;
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Toggle enhanced rendering (lighting)
        if (MKLIsKeyPressed(MKL_KEY_L)) {
            lightingOn = !lightingOn;
            MKLEnableEnhancedRendering(renderer, lightingOn);
            printf("Enhanced Rendering (Lighting): %s\n", lightingOn ? "ON" : "OFF");
            if (lightingOn) {
                printf("  → You should see shiny highlights and directional shading!\n");
            } else {
                printf("  → Back to flat shading\n");
            }
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
        if (MKLIsKeyDown(MKL_KEY_SPACE)) {
            renderer->camera.position = MAddVector(renderer->camera.position, 
                                                   MMulVecByScalar((vector_float3){0, 1, 0}, moveSpeed));
        }
        if (MKLIsKeyDown(MKL_KEY_Q)) {
            renderer->camera.position = MSubVector(renderer->camera.position, 
                                                   MMulVecByScalar((vector_float3){0, 1, 0}, moveSpeed));
        }
        
        MKLUpdateInputState();
        
        // Animate point light in a circle
        float time = MKLGetTime();
        MKLLight *light = MKLGetLight(renderer, pointIdx);
        if (light) {
            light->position = (vector_float3){
                cosf(time * 0.8f) * 6.0f,
                2.5f + sinf(time * 1.5f) * 1.5f,
                sinf(time * 0.8f) * 6.0f
            };
            MKLUpdateLight(renderer, pointIdx, *light);
        }
        
        // Begin rendering
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, (MKLColor){0.1f, 0.1f, 0.15f, 1.0f});
        
        // Update camera
        MKLCameraControls controls = {0};
        MKLUpdateCamera(&renderer->camera, controls);
        
        // Draw floor
        MKLDrawPlane(renderer, (MKLPlane){
            .position = {0, 0, 0},
            .dimensions = {20, 20},
            .segments = {1, 1},
            .rotation = {0, 0, 0}
        }, MKL_COLOR_GRAY_7);
        
        // Draw cubes in a grid
        float rotation = time * 30.0f;
        
        for (int x = -2; x <= 2; x++) {
            for (int z = -1; z <= 1; z++) {
                float xPos = x * 2.5f;
                float zPos = z * 2.5f;
                float height = 1.0f + sinf(time + x + z) * 0.3f;
                
                // Color varies by position
                MKLColor color = (MKLColor){
                    0.5f + 0.5f * sinf(x * 0.5f),
                    0.5f + 0.5f * cosf(z * 0.5f),
                    0.5f + 0.5f * sinf((x + z) * 0.3f),
                    1.0f
                };
                
                MKLDrawCube(renderer, (MKLCube){
                    .position = {xPos, height, zPos},
                    .rotation = {rotation * 0.5f, rotation, rotation * 0.3f},
                    .width = 1.2f, .height = 1.2f, .depth = 1.2f
                }, color);
            }
        }
        
        // Draw sphere at point light position
        if (light) {
            MKLDrawSphere(renderer, (MKLSphere){
                .position = light->position,
                .rotation = {0, 0, 0},
                .radius = 0.3f,
                .segments = 16
            }, light->color);
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

