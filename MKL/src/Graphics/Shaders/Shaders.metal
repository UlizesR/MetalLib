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

// ========== ENHANCED SHADERS WITH LIGHTING AND TEXTURES ==========

#define MAX_LIGHTS 8

enum LightType : uint {
    LightTypeAmbient = 0,
    LightTypeDirectional = 1,
    LightTypePoint = 2,
    LightTypeSpot = 3
};

/**
 * @brief Enhanced vertex input with normals and UVs
 */
struct VertexInEnhanced {
    float4 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

/**
 * @brief Enhanced rasterizer data
 */
struct RasterizerDataEnhanced {
    float4 position   [[position]];
    float3 worldPos;
    float3 normal;
    float2 texCoords;
    float4 color;
};

/**
 * @brief Light data structure
 */
struct Light {
    float3 color;
    float intensity;
    float3 position;
    float padding1;
    float3 direction;
    float padding2;
    float constantAtten;
    float linearAtten;
    float quadraticAtten;
    uint type;
    float innerConeAngle;
    float outerConeAngle;
    float2 padding3;
};

/**
 * @brief Material properties
 */
struct Material {
    float4 albedo;
    float metallic;
    float roughness;
    float shininess;
    float opacity;
};

/**
 * @brief Lighting uniforms
 */
struct LightingUniforms {
    uint lightCount;
    float3 cameraPos;
};

/**
 * @brief Enhanced vertex shader with normal transformation
 */
vertex RasterizerDataEnhanced vertexShaderEnhanced(
    const VertexInEnhanced vIn [[stage_in]],
    constant Uniforms &uniforms [[buffer(1)]],
    constant float4 &color [[buffer(2)]],
    constant float4x4 &modelMatrix [[buffer(3)]]
)
{
    RasterizerDataEnhanced out;

    float4 worldPos = modelMatrix * vIn.position;
    float4 viewPos = uniforms.viewMatrix * worldPos;
    out.position = uniforms.projectionMatrix * viewPos;
    out.worldPos = worldPos.xyz;

    float3x3 normalMatrix = float3x3(modelMatrix[0].xyz,
                                      modelMatrix[1].xyz,
                                      modelMatrix[2].xyz);
    out.normal = normalize(normalMatrix * vIn.normal);
    out.texCoords = vIn.texCoords;
    out.color = color;

    return out;
}

/**
 * @brief Calculate attenuation for point/spot lights
 */
float calculateAttenuation(float distance, Light light) {
    return 1.0 / (light.constantAtten +
                  light.linearAtten * distance +
                  light.quadraticAtten * distance * distance);
}

/**
 * @brief Calculate lighting (Blinn-Phong with optimizations)
 */
float3 calculateLighting(
    Light light,
    float3 worldPos,
    float3 normal,
    float3 viewDir,
    float3 albedo,
    float shininess
)
{
    float3 result = float3(0.0);

    if (light.type == LightTypeAmbient) {
        result = light.color * light.intensity * albedo;
    }
    else if (light.type == LightTypeDirectional) {
        float3 lightDir = normalize(-light.direction);
        float NdotL = max(dot(normal, lightDir), 0.0);

        // OPTIMIZATION: Early exit if surface facing away from light
        if (NdotL <= 0.0) return float3(0.0);

        float3 diffuse = NdotL * light.color * light.intensity * albedo;

        float3 halfwayDir = normalize(lightDir + viewDir);
        float NdotH = max(dot(normal, halfwayDir), 0.0);
        float spec = fast::pow(NdotH, shininess);
        float3 specular = spec * light.color * light.intensity;

        result = diffuse + specular;
    }
    else if (light.type == LightTypePoint) {
        float3 toLight = light.position - worldPos;
        float distance = length(toLight);
        float3 lightDir = toLight / distance;  // Normalize by division (1 less op)

        float attenuation = calculateAttenuation(distance, light);

        float NdotL = max(dot(normal, lightDir), 0.0);


        if (NdotL <= 0.0 || attenuation <= 0.001) return float3(0.0);

        float3 diffuse = NdotL * light.color * light.intensity * albedo * attenuation;

        float3 halfwayDir = normalize(lightDir + viewDir);
        float NdotH = max(dot(normal, halfwayDir), 0.0);
        float spec = fast::pow(NdotH, shininess);
        float3 specular = spec * light.color * light.intensity * attenuation;

        result = diffuse + specular;
    }

    return result;
}

/**
 * @brief Enhanced fragment shader with lighting and textures
 */
fragment half4 fragmentShaderEnhanced(
    RasterizerDataEnhanced in [[stage_in]],
    constant LightingUniforms &lightingUniforms [[buffer(0)]],
    constant Light *lights [[buffer(1)]],
    constant Material &material [[buffer(2)]],
    texture2d<float> albedoTexture [[texture(0)]],
    sampler textureSampler [[sampler(0)]]
)
{
    float4 texColor = albedoTexture.sample(textureSampler, in.texCoords);
    float3 albedo = texColor.rgb * in.color.rgb * material.albedo.rgb;

    float3 viewDir = normalize(lightingUniforms.cameraPos - in.worldPos);
    float3 normal = normalize(in.normal);

    float3 finalColor = float3(0.0);

    uint maxLights = min(lightingUniforms.lightCount, uint(MAX_LIGHTS));
    for (uint i = 0; i < maxLights; i++) {
        finalColor += calculateLighting(
            lights[i],
            in.worldPos,
            normal,
            viewDir,
            albedo,
            material.shininess
        );
    }

    float alpha = texColor.a * in.color.a * material.opacity;
    return half4(half3(finalColor), half(alpha));
}

/**
 * @brief Textured fragment shader (no lighting)
 */
fragment half4 fragmentShaderTextured(
    RasterizerDataEnhanced in [[stage_in]],
    texture2d<float> albedoTexture [[texture(0)]],
    sampler textureSampler [[sampler(0)]]
)
{
    float4 texColor = albedoTexture.sample(textureSampler, in.texCoords);
    float4 finalColor = texColor * in.color;
    return half4(finalColor);
}

/**
 * @brief Lit fragment shader (no texture)
 */
fragment half4 fragmentShaderLit(
    RasterizerDataEnhanced in [[stage_in]],
    constant LightingUniforms &lightingUniforms [[buffer(0)]],
    constant Light *lights [[buffer(1)]],
    constant Material &material [[buffer(2)]]
)
{
    float3 albedo = in.color.rgb * material.albedo.rgb;
    float3 viewDir = normalize(lightingUniforms.cameraPos - in.worldPos);
    float3 normal = normalize(in.normal);

    float3 finalColor = float3(0.0);

    uint maxLights = min(lightingUniforms.lightCount, uint(MAX_LIGHTS));
    for (uint i = 0; i < maxLights; i++) {
        finalColor += calculateLighting(
            lights[i],
            in.worldPos,
            normal,
            viewDir,
            albedo,
            material.shininess
        );
    }

    return half4(half3(finalColor), half(in.color.a * material.opacity));
}
