//
// shadertoy.metal
// ShaderToy-style shader converted to Metal
// Original: https://www.shadertoy.com/view/mtyGWy
//

#include <metal_stdlib>
using namespace metal;

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

// Standard uniforms
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

// Palette function from Inigo Quilez
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
    
    // For fullscreen rendering, pass through the vertex position directly
    // This creates a fullscreen quad in clip space [-1,1]
    rd.position = vIn.position;
    
    // Generate texture coordinates from vertex position (like raylib)
    rd.fragTexCoord = vIn.position.xy * 0.5 + 0.5;
    rd.fragColor = float4(1.0, 1.0, 1.0, 1.0); // White color
    
    return rd;
}

// ========== Fragment Shader ==========
fragment float4 shadertoyFragmentShader(
    RasterizerData rd [[stage_in]],
    constant ShaderToyUniforms &shaderToy [[buffer(4)]]
) {
    // Use the actual pixel coordinates (like gl_FragCoord in raylib)
    float2 fragCoord = rd.position.xy;
    
    // ShaderToy main code (exact coordinate system match)
    // Convert to normalized coordinates exactly like ShaderToy: (fragCoord * 2.0 - iResolution.xy) / iResolution.y
    float2 uv = (fragCoord * 2.0 - shaderToy.iResolution.xy) / shaderToy.iResolution.y;
    float2 uv0 = uv;
    float3 color = float3(0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        float3 col = palette(length(uv0) + i * 0.4 + shaderToy.iTime * 0.4);

        d = sin(d * 8.0 + shaderToy.iTime) / 8.0;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        color += col * d;
    }
        
    return float4(color, 1.0);
}

