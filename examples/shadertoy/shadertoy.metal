//
// shadertoy.metal
// ShaderToy-style shader converted to Metal
//
// This shader creates beautiful procedural graphics using the palette technique
// by Inigo Quilez: https://iquilezles.org/articles/palettes/
//
// Original ShaderToy: https://www.shadertoy.com/view/mtyGWy
//

#include <metal_stdlib>
using namespace metal;

// ========== Data Structures ==========

// Vertex input
struct VertexIn {
    float4 position [[attribute(0)]];
};

// Vertex output / Fragment input
struct RasterizerData {
    float4 position [[position]];
    float2 fragTexCoord;
    float4 fragColor;
};

// Standard MKL uniforms
struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
};

// ShaderToy-style uniforms
struct ShaderToyUniforms {
    float iTime;           // Time in seconds
    float2 iResolution;    // Viewport resolution (in pixels)
    float2 iMouse;         // Mouse position (in pixels)
};

// ========== Palette Function ==========

// Palette function by Inigo Quilez
// Creates beautiful color gradients from simple parameters
// https://iquilezles.org/articles/palettes/
float3 palette(float t) {
    float3 a = float3(0.5, 0.5, 0.5);
    float3 b = float3(0.5, 0.5, 0.5);
    float3 c = float3(1.0, 1.0, 1.0);
    float3 d = float3(0.263, 0.416, 0.557);
    
    return a + b * cos(6.28318 * (c * t + d));
}

// ========== Vertex Shader ==========

vertex RasterizerData shadertoyVertexShader(
    const VertexIn vIn [[stage_in]],
    constant Uniforms &uniforms [[buffer(1)]],
    constant float4x4 &modelMatrix [[buffer(3)]]
) {
    RasterizerData rd;
    
    // For fullscreen rendering, pass through vertex position directly
    // This creates a fullscreen quad in clip space [-1, 1]
    rd.position = vIn.position;
    
    // Generate texture coordinates from vertex position
    rd.fragTexCoord = vIn.position.xy * 0.5 + 0.5;
    rd.fragColor = float4(1.0, 1.0, 1.0, 1.0);
    
    return rd;
}

// ========== Fragment Shader ==========

fragment float4 shadertoyFragmentShader(
    RasterizerData rd [[stage_in]],
    constant ShaderToyUniforms &shaderToy [[buffer(4)]]
) {
    // Get pixel coordinates (like gl_FragCoord in GLSL)
    float2 fragCoord = rd.position.xy;
    
    // Normalize coordinates to ShaderToy style:
    // Center at (0,0), aspect-corrected, range approximately [-1, 1]
    float2 uv = (fragCoord * 2.0 - shaderToy.iResolution.xy) / shaderToy.iResolution.y;
    float2 uv0 = uv;
    float3 finalColor = float3(0.0);
    
    // Create fractal-like pattern with multiple iterations
    for (float i = 0.0; i < 4.0; i++) {
        // Create repeating pattern
        uv = fract(uv * 1.5) - 0.5;
        
        // Calculate distance with exponential falloff
        float d = length(uv) * exp(-length(uv0));
        
        // Generate color based on position and time
        float3 col = palette(length(uv0) + i * 0.4 + shaderToy.iTime * 0.4);
        
        // Create animated rings
        d = sin(d * 8.0 + shaderToy.iTime) / 8.0;
        d = abs(d);
        
        // Create glow effect
        d = pow(0.01 / d, 1.2);
        
        // Accumulate color
        finalColor += col * d;
    }
    
    return float4(finalColor, 1.0);
}

