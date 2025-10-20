//
// 02_graphics/shapes_demo.c
// Demonstrates all available 2D and 3D shapes
//
// Features demonstrated:
// - 3D primitives (cube, sphere, cylinder, cone, torus)
// - 2D shapes (circle, rectangle, triangle, polygon, line)
// - Camera movement
// - Enhanced rendering with lighting
//

#include "MKL.h"
#include <stdio.h>
#include <math.h>

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "02 - Shapes Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    // Setup camera
    renderer->camera = (MKLCamera){
        .position = {0.0f, 3.0f, 10.0f},
        .target = {0.0f, 0.0f, 0.0f},
        .up = {0.0f, 1.0f, 0.0f},
        .fov = 45.0f,
        .aspect = (float)HEIGHT / (float)WIDTH,
        .near = 0.1f,
        .far = 100.0f,
        .yaw = -90.0f,
        .pitch = 0.0f,
        .mode = MKL_CAMERA_FIRST_PERSON,
        .moveSpeed = 5.0f
    };
    
    // Enable lighting for better visuals
    MKLEnableEnhancedRendering(renderer, true);
    
    MKLLight sun = MKLCreateDirectionalLight(
        (vector_float3){-0.5f, -1.0f, -0.3f},
        MKL_COLOR_WHITE, 0.7f
    );
    MKLAddLight(renderer, sun);
    
    MKLLight ambient = MKLCreateAmbientLight(MKL_COLOR_WHITE, 0.2f);
    MKLAddLight(renderer, ambient);
    
    printf("=== MKL Shapes Demo ===\n");
    printf("Controls:\n");
    printf("  ESC - Exit\n");
    printf("  WASD - Move camera\n");
    printf("  Mouse Drag - Look around\n");
    printf("  L - Toggle lighting\n");
    printf("\nRendering 3D and 2D shapes with lighting...\n");
    
    // Mouse control variables
    float lastMouseX = (float)WIDTH / 2.0f;
    float lastMouseY = (float)HEIGHT / 2.0f;
    bool firstMouse = true;
    bool lightingEnabled = true;
    
    // Main loop
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(TARGET_FPS) / 1000.0f;
        
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Toggle lighting
        if (MKLIsKeyPressed(MKL_KEY_L)) {
            lightingEnabled = !lightingEnabled;
            MKLEnableEnhancedRendering(renderer, lightingEnabled);
            printf("Lighting: %s\n", lightingEnabled ? "ON" : "OFF");
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
            
            float xOffset = (mouseX - lastMouseX) * 0.1f;
            float yOffset = (lastMouseY - mouseY) * 0.1f;
            
            lastMouseX = mouseX;
            lastMouseY = mouseY;
            
            // Update camera yaw and pitch
            renderer->camera.yaw += xOffset;
            renderer->camera.pitch += yOffset;
            
            // Constrain pitch to prevent camera flipping
            if (renderer->camera.pitch > 89.0f)
                renderer->camera.pitch = 89.0f;
            if (renderer->camera.pitch < -89.0f)
                renderer->camera.pitch = -89.0f;
            
            // Update camera vectors based on yaw and pitch
            vector_float3 forward;
            forward.x = cosf(renderer->camera.yaw * M_PI / 180.0f) * cosf(renderer->camera.pitch * M_PI / 180.0f);
            forward.y = sinf(renderer->camera.pitch * M_PI / 180.0f);
            forward.z = sinf(renderer->camera.yaw * M_PI / 180.0f) * cosf(renderer->camera.pitch * M_PI / 180.0f);
            renderer->camera.forward = simd_normalize(forward);
            
            // Update right and up vectors (cross product and normalize using SIMD)
            renderer->camera.right = simd_normalize(simd_cross(renderer->camera.forward, (vector_float3){0.0f, 1.0f, 0.0f}));
            renderer->camera.up = simd_normalize(simd_cross(renderer->camera.right, renderer->camera.forward));
        } else {
            firstMouse = true;
        }
        
        // Camera movement using new camera functions
        float moveSpeed = renderer->camera.moveSpeed * deltaTime;
        if (MKLIsKeyDown(MKL_KEY_W)) MKLCameraMoveForward(&renderer->camera, moveSpeed, true);
        if (MKLIsKeyDown(MKL_KEY_S)) MKLCameraMoveForward(&renderer->camera, -moveSpeed, true);
        if (MKLIsKeyDown(MKL_KEY_A)) MKLCameraMoveRight(&renderer->camera, -moveSpeed, true);
        if (MKLIsKeyDown(MKL_KEY_D)) MKLCameraMoveRight(&renderer->camera, moveSpeed, true);
        if (MKLIsKeyDown(MKL_KEY_SPACE)) MKLCameraMoveUp(&renderer->camera, moveSpeed);
        if (MKLIsKeyDown(MKL_KEY_Q)) MKLCameraMoveUp(&renderer->camera, -moveSpeed);
        
        MKLUpdateInputState();
        
        // Begin rendering
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_GRAY_3);
        
        // Update camera matrices
        MKLCameraControls controls = {0};
        MKLUpdateCamera(&renderer->camera, controls);
        
        // Get time for animations
        const float time = MKLGetTime();
        
        
        // 3D Shapes - Multiple shapes positioned for better visibility
        printf("Drawing 3D shapes...\n");
        
        // Cube
        MKLCube cube = {
            .position = {-3.0f, 0.0f, 0.0f},
            .rotation = {0.0f, time, 0.0f},
            .width = 1.0f,
            .height = 1.0f,
            .depth = 1.0f
        };
        MKLDrawCube(renderer, cube, MKL_COLOR_RED);
        
        // Sphere
        MKLSphere sphere = {
            .position = {-1.0f, 0.0f, 0.0f},
            .rotation = {0.0f, time, 0.0f},
            .radius = 0.8f,
            .segments = 32
        };
        MKLDrawSphere(renderer, sphere, MKL_COLOR_GREEN);
        
        // Cylinder
        MKLCylinder cylinder = {
            .position = {1.0f, 0.0f, 0.0f},
            .rotation = {0.0f, time, 0.0f},
            .radius = 0.6f,
            .height = 1.5f,
            .segments = 32
        };
        MKLDrawCylinder(renderer, cylinder, MKL_COLOR_BLUE);
        
        // Cone
        MKLCone cone = {
            .position = {3.0f, 0.0f, 0.0f},
            .rotation = {0.0f, time, 0.0f},
            .radius = 0.7f,
            .height = 1.2f,
            .segments = 32
        };
        MKLDrawCone(renderer, cone, MKL_COLOR_YELLOW);
        
        // Torus
        MKLTorus torus = {
            .position = {0.0f, 2.0f, 0.0f},
            .rotation = {time, time * 0.5f, 0.0f},
            .majorRadius = 1.0f,
            .minorRadius = 0.3f,
            .majorSegments = 32,
            .minorSegments = 16
        };
        MKLDrawTorus(renderer, torus, MKL_COLOR_MAGENTA);
        
        // 2D Shapes (rendered at z=0)
        printf("Drawing 2D shapes...\n");
        
        // Circle
        MKLCircle circle = {
            .position = {-2.0f, -2.0f},
            .radius = 0.5f,
            .segments = 32
        };
        MKLDrawCircle(renderer, circle, MKL_COLOR_YELLOW);
        
        // Rectangle
        MKLRect rect = {
            .position = {0.0f, -2.0f},
            .width = 1.0f,
            .height = 0.8f
        };
        MKLDrawRectangle(renderer, rect, MKL_COLOR_MAGENTA);
        
        // Triangle
        MKLTriangle triangle = {
            .p1 = {1.5f, -1.5f},
            .p2 = {2.5f, -1.5f},
            .p3 = {2.0f, -2.5f}
        };
        MKLDrawTriangle(renderer, triangle, MKL_COLOR_GREEN);
        
        // Polygon (hexagon)
        MKLPolygon polygon = {
            .position = {3.5f, -2.0f},
            .radius = 0.4f,
            .sides = 6,
            .rotation = time
        };
        MKLDrawPolygon(renderer, polygon, MKL_COLOR_CYAN);
        
        // Line
        MKLLine line = {
            .p1 = {-3.5f, -3.0f},
            .p2 = {-2.5f, -3.5f}
        };
        MKLDrawLine(renderer, line, MKL_COLOR_WHITE);
        
        MKLEndDrawing(renderer);
    }
    
    // Cleanup
    printf("\nCleaning up...\n");
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");
    
    return 0;
}
