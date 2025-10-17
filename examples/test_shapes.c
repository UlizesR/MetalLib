#include "MKL.h"

int main(void) {
    const int WIDTH = 1200;
    const int HEIGHT = 800;
    const int TARGET_FPS = 60;
    
    // Initialize MKL
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - Shape Rendering Demo");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize MKL\n");
        return -1;
    }
    
    // Setup camera (same as main.c)
    const MKLCamera camera = {
        .position = {0.0f, 2.0f, 8.0f},
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
    renderer->camera = camera;
    
    printf("=== MKL Shape Rendering Demo ===\n");
    printf("Controls:\n");
    printf("ESC - Exit\n");
    printf("WASD - Move camera\n");
    printf("Mouse - Look around (drag to rotate view)\n");
    printf("\nRendering various 3D and 2D shapes...\n");
    
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
            float yOffset = (lastMouseY - mouseY) * mouseSensitivity; // Reversed: y-coordinates go from bottom to top
            
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
        
        // Camera movement
        const float moveSpeed = 5.0f * MKLTicks(TARGET_FPS) / 1000.0f;
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
