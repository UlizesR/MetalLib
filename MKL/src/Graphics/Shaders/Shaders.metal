#include <metal_stdlib>
using namespace metal;

/**
 * @brief Vertex input structure matching MKLVertex.
 */
struct VertexIn
{
    float4 position [[ attribute(0) ]];
};

/**
 * @brief Data passed from vertex to fragment shader.
 */
struct RasterizerData
{
    float4 position [[ position ]];
    float4 color;
};

/**
 * @brief Uniform structure matching MKLUniforms.
 */
struct Uniforms
{
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

/**
 * @brief Vertex shader - transforms vertices to clip space.
 * 
 * Matrix multiplication order: projection * view * model * position
 * This is the correct order for column-major matrices (Metal/SIMD default).
 */
vertex RasterizerData vertexShader(
    const VertexIn vIn [[ stage_in ]], 
    constant Uniforms &uniforms [[ buffer(1) ]], 
    constant float4 &color [[ buffer(2) ]],
    constant float4x4 &modelMatrix [[ buffer(3) ]]
)
{
    RasterizerData rd;
    
    // Correct matrix multiplication order for column-major matrices
    const float4 worldPos = modelMatrix * vIn.position;
    const float4 viewPos = uniforms.viewMatrix * worldPos;
    rd.position = uniforms.projectionMatrix * viewPos;
    rd.color = color;
    
    return rd;
}

/**
 * @brief Fragment shader - outputs final pixel color.
 */
fragment half4 fragmentShader(RasterizerData rd [[ stage_in ]]) 
{
    // Convert float4 to half4 for output
    return half4(rd.color);
}