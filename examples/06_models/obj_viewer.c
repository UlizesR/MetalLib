#include "MKL.h"
#include <math.h>

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - OBJ Model Viewer");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    // Setup camera
    const MKLCamera camera = {
        .position = {0.0f, 5.0f, 15.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .forward = {0.0f, 0.0f, -1.0f},
        .right = {1.0f, 0.0f, 0.0f},
        .fov = 45.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 1000.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
    };
    renderer->camera = camera;
    
    printf("=== MKL OBJ Model Viewer ===\n");
    printf("Loading 3D model from OBJ file...\n");
    
    // Load OBJ file
    MKLMesh mesh = MKLMeshCreateWithFile(renderer, "examples/assets/FinalBaseMesh.obj");
    
    if (mesh.vertexCount == 0) {
        fprintf(stderr, "Failed to load OBJ file!\n");
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return -1;
    }
    
    printf("✓ Model loaded successfully!\n");
    printf("  Vertices: %d\n", mesh.vertexCount);
    
    // Setup lighting for the OBJ model
    printf("\n--- Setting up lighting for OBJ model ---\n");
    MKLEnableEnhancedRendering(renderer, true);
    
    MKLLight ambient = MKLCreateAmbientLight(MKL_COLOR_WHITE, 0.2f);
    MKLAddLight(renderer, ambient);
    
    MKLLight sun = MKLCreateDirectionalLight(
        (vector_float3){-0.5f, -1.0f, -0.3f},
        MKL_COLOR_WHITE,
        0.8f
    );
    MKLAddLight(renderer, sun);
    
    MKLLight key = MKLCreatePointLight(
        (vector_float3){5.0f, 5.0f, 5.0f},
        MKL_COLOR_WHITE,
        3.0f,
        20.0f
    );
    MKLAddLight(renderer, key);
    
    printf("✓ Lighting enabled with 3 lights\n");
    
    printf("\nControls:\n");
    printf("  Left-click & drag - Look around\n");
    printf("  WASD - Move camera\n");
    printf("  Space/Q - Move up/down\n");
    printf("  L - Toggle lighting on/off\n");
    printf("  ESC - Exit\n");
    printf("\nLook for:\n");
    printf("  ✨ Shiny highlights on the model\n");
    printf("  🌞 Shaded surfaces showing 3D depth\n");
    printf("\nRendering...\n");
    
    // Model transform
    mesh.position = (vector_float3){0.0f, 0.0f, 0.0f};
    mesh.rotation = (vector_float3){0.0f, 0.0f, 0.0f};
    mesh.dimensions = (vector_float3){0.1f, 0.1f, 0.1f}; // Scale down the model
    
    // Mouse control variables
    float lastMouseX = (float)WIDTH / 2.0f;
    float lastMouseY = (float)HEIGHT / 2.0f;
    bool firstMouse = true;
    const float mouseSensitivity = 0.1f;
    
    // Main loop

    while (!MKLWindowShouldClose(window)) {
        MKLTicks(TARGET_FPS);
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Toggle lighting
        static bool lightingOn = true;
        if (MKLIsKeyPressed(MKL_KEY_L)) {
            lightingOn = !lightingOn;
            MKLEnableEnhancedRendering(renderer, lightingOn);
            printf("Lighting: %s\n", lightingOn ? "ON (see highlights!)" : "OFF (flat)");
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
            
            // Constrain pitch
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
        const float moveSpeed = 10.0f * MKLTicks(TARGET_FPS) / 1000.0f;
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
                                                   MMulVecByScalar(renderer->camera.up, moveSpeed));
        }
        if (MKLIsKeyDown(MKL_KEY_Q)) {
            renderer->camera.position = MSubVector(renderer->camera.position, MMulVecByScalar(renderer->camera.up, moveSpeed));
        }
        
        MKLUpdateInputState();
        
        // Rotate model slowly
        const float time = MKLGetTime();
        mesh.rotation.y = time * 0.3f;
        
        // Render
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_GRAY_2);
        
        // Update camera
        MKLCameraControls controls = {0};
        MKLUpdateCamera(&renderer->camera, controls);
        
        // Draw the OBJ model
        MKLDrawMesh(renderer, &mesh, MKL_COLOR_CYAN);
        
        MKLEndDrawing(renderer);
        
    }
    
    // Cleanup
    printf("\nCleaning up...\n");
    MKLCleanupShapeCache();
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}
