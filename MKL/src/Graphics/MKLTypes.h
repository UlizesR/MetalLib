#ifndef _MKL_TYPES_H_
#define _MKL_TYPES_H_

#include <simd/vector.h>
#include <simd/matrix.h>

typedef struct MKLVertex
{
    vector_float4 position;
} MKLVertex;

typedef struct MKLVertexEnhanced
{
    vector_float4 position;
    vector_float3 normal;
    vector_float2 texCoords;
} MKLVertexEnhanced;

typedef struct MKLUniforms
{
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} MKLUniforms;

// Shader data structures (must match Metal shader definitions)
typedef struct MKLShaderLight
{
    vector_float3 color;
    float intensity;
    vector_float3 position;
    float padding1;
    vector_float3 direction;
    float padding2;
    float constantAtten;
    float linearAtten;
    float quadraticAtten;
    uint32_t type;
    float innerConeAngle;
    float outerConeAngle;
    vector_float2 padding3;
} MKLShaderLight;

typedef struct MKLShaderMaterial
{
    vector_float4 albedo;
    float metallic;
    float roughness;
    float shininess;
    float opacity;
} MKLShaderMaterial;

typedef struct MKLLightingUniforms
{
    uint32_t lightCount;
    vector_float3 cameraPos;
} MKLLightingUniforms;

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

@interface MklDefs : NSObject

+ (MKLVertex *)cubeVertices;
+ (ushort *)cubeIndices;

@end

#endif


#endif // _MKL_TYPES_H_
