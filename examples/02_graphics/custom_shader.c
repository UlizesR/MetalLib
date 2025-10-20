//
// test_shadertoy.c
// Test the custom shader system with a ShaderToy-style shader
//

#include "MKL.h"
#include <stdio.h>
#include <math.h>

// ShaderToy-style uniforms (must match the Metal shader)
typedef struct ShaderToyUniforms {
    float iTime;
    vector_float2 iResolution;
    vector_float2 iMouse;
} ShaderToyUniforms;

int main(void) {
    const int WIDTH = 800;
    const int HEIGHT = 600;
    const int TARGET_FPS = 60;
    
    // Initialize timer
    MKLInitTimer();
    
    // Create window
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - ShaderToy Shader");
    if (window == NULL) {
        fprintf(stderr, "Failed to create window\n");
        return 1;
    }
    
    // Create renderer
    MKLRenderer *renderer = MKLCreateRenderer(window);
    if (renderer == NULL) {
        fprintf(stderr, "Failed to create renderer\n");
        MKLDestroyWindow(window);
        return 1;
    }
    
    // Load custom ShaderToy shader
    printf("Loading custom shader...\n");
    MKLShader *shadertoyShader = MKLLoadShader(renderer,  "examples/shadertoy.metal", "shadertoyVertexShader", "shadertoyFragmentShader");
    
    if (!MKLIsShaderValid(shadertoyShader)) {
        fprintf(stderr, "Failed to load ShaderToy shader!\n");
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return 1;
    }
    
    
    // For fullscreen shader rendering, we don't need a 3D camera
    // The shader will handle screen coordinates directly
    
    vector_float2 mousePos = {0.0f, 0.0f};
    // Main loop
    while (!MKLWindowShouldClose(window)) {
        MKLTicks(TARGET_FPS);
        
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Get mouse position
        mousePos = MKLGetMousePosition();
        
        MKLUpdateInputState();
        
        // Set ShaderToy uniforms using render dimensions (like raylib's GetRenderWidth/GetRenderHeight)
        ShaderToyUniforms uniforms;
        uniforms.iTime = MKLGetTime(); // Use MKLGetTime() like raylib's GetTime()
        uniforms.iResolution = MKLGetRenderSize(renderer); // Use render dimensions like raylib
        uniforms.iMouse = mousePos;
        
        // Set the uniforms (buffer index 4 matches the shader)
        // Our struct has: float iTime, vector_float2 iResolution, vector_float2 iMouse
        // That's 1 float + 2 vec2s = 5 floats total
        MKLSetShaderValue(shadertoyShader, "shaderToyUniforms", &uniforms, MKL_SHADER_UNIFORM_FLOAT, 5);
        
        // Render fullscreen shader using the normal pipeline (like raylib)
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_BLACK);
        
        MKLBeginShaderMode(renderer, shadertoyShader);
        
        // Draw a fullscreen rectangle (like raylib's DrawRectangle)
        // Use render dimensions to ensure the rectangle covers the entire render area
        vector_float2 renderSize = MKLGetRenderSize(renderer);
        MKLDrawRectangle2D(renderer, 0.0f, 0.0f, renderSize.x, renderSize.y, MKL_COLOR_WHITE);
        
        MKLEndShaderMode(renderer);
        MKLEndDrawing(renderer);
        
    }
    
    // Cleanup
    printf("\nCleaning up...\n");
    MKLUnloadShader(shadertoyShader);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    
    printf("✓ Cleanup complete!\n");
    return 0;
}

