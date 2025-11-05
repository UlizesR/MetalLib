// Instancing shaders - uses structs from Shaders.metal
// Note: This file is concatenated with Shaders.metal at runtime

/**
 * @brief Per-instance data structure.
 */
struct InstanceData
{
    float4x4 modelMatrix;
    float4 color;
};

/**
 * @brief Instanced vertex shader - transforms vertices to clip space with per-instance data.
 *
 * This shader supports rendering multiple instances of the same geometry with different
 * transforms and colors in a single draw call.
 */
vertex RasterizerData vertexShaderInstanced(
    const VertexIn vIn [[ stage_in ]],
    constant Uniforms &uniforms [[ buffer(1) ]],
    constant InstanceData *instanceData [[ buffer(2) ]],
    uint instanceID [[ instance_id ]]
)
{
    RasterizerData rd;

    // Get per-instance data
    constant InstanceData &instance = instanceData[instanceID];

    // Transform vertex using per-instance model matrix
    const float4 worldPos = instance.modelMatrix * vIn.position;
    const float4 viewPos = uniforms.viewMatrix * worldPos;
    rd.position = uniforms.projectionMatrix * viewPos;
    rd.color = instance.color;

    return rd;
}

/**
 * @brief Fragment shader - outputs final pixel color.
 * (Same as regular shader)
 */
fragment half4 fragmentShaderInstanced(RasterizerData rd [[ stage_in ]])
{
    return half4(rd.color);
}

