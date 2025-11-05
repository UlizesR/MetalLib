//
// shadertoy.c
// ShaderToy-style shader demo for MetalLib (MKL)
//
// Demonstrates:
// - Custom shader loading with MKLLoadShader
// - Shader uniform management with MKLSetShaderValue
// - Fullscreen shader rendering with MKLDrawRectangle2D
// - Real-time mouse and time uniforms (ShaderToy-style)
//
// This example showcases MKL's raylib-inspired shader API for creating
// beautiful procedural graphics using Metal shaders.
//

#include "MKL.h"
#include <stdio.h>

// ShaderToy-style uniforms (must match the Metal shader)
typedef struct ShaderToyUniforms {
    float iTime;           // Time in seconds
    vector_float2 iResolution; // Viewport resolution (in pixels)
    vector_float2 iMouse;     // Mouse position (in pixels)
} ShaderToyUniforms;

int main(void) {
    const int WIDTH = 1280;
    const int HEIGHT = 720;
    const int TARGET_FPS = 60;

    // Initialize timer
    MKLInitTimer();

    // Create window
    MKLWindow *window = MKLCreateWindow(WIDTH, HEIGHT, "MKL - ShaderToy Demo");
    if (!window) {
        fprintf(stderr, "❌ Failed to create window\n");
        return 1;
    }

    // Create renderer
    MKLRenderer *renderer = MKLCreateRenderer(window);
    if (!renderer) {
        fprintf(stderr, "❌ Failed to create renderer\n");
        MKLDestroyWindow(window);
        return 1;
    }

    // Load custom ShaderToy shader
    MKLShader *shadertoyShader = MKLLoadShader(
        renderer,
        "examples/shadertoy/shadertoy.metal",
        "shadertoyVertexShader",
        "shadertoyFragmentShader"
    );

    if (!MKLIsShaderValid(shadertoyShader)) {
        fprintf(stderr, "❌ Failed to load ShaderToy shader!\n");
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return 1;
    }

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

        // Prepare ShaderToy uniforms
        ShaderToyUniforms uniforms;
        uniforms.iTime = (float)MKLGetTime();
        uniforms.iResolution = MKLGetRenderSize(renderer);
        uniforms.iMouse = mousePos;

        // Set shader uniforms (buffer index 4 for custom data)
        MKLSetShaderValue(shadertoyShader, "shaderToyUniforms", &uniforms, MKL_SHADER_UNIFORM_FLOAT, 5);

        // Render
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_BLACK);

        // Begin custom shader mode
        MKLBeginShaderMode(renderer, shadertoyShader);

        // Draw fullscreen rectangle (shader will process every pixel)
        vector_float2 renderSize = MKLGetRenderSize(renderer);
        MKLDrawRectangle2D(renderer, 0.0f, 0.0f, renderSize.x, renderSize.y, MKL_COLOR_WHITE);

        // End shader mode
        MKLEndShaderMode(renderer);
        MKLEndDrawing(renderer);

    }

    // Cleanup
    printf("\n🧹 Cleaning up...\n");
    MKLUnloadShader(shadertoyShader);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");

    return 0;
}

