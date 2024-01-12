#ifndef _MKL_MODELS_H_
#define _MKL_MODELS_H_

#include "../Core/MKLCore.h"
#include "../MKLColors.h"
#include "../Renderer/MKLRenderer.h"

#include <simd/vector.h>
#include <simd/vector_types.h>

typedef struct MKLLine
{
    vector_float2 p1;
    vector_float2 p2;
} MKLLine;

typedef struct MKLTriangle
{
    vector_float2 p1;
    vector_float2 p2;
    vector_float2 p3;
} MKLTriangle;

typedef struct MKLRect
{
    vector_float2 position;
    float width, height;
} MKLRect;

typedef struct MKLPlane
{
    vector_float3 position;
    vector_float2 dimensions;
    simd_uint2 segments;
    vector_float3 rotation;
    vector_float3 *vertices;
    int vertexCount;
} MKLPlane;

typedef struct MKLCube
{
    vector_float3 position;
    vector_float3 rotation;
    float width, height, depth;
} MKLCube;

MKLAPI void MKLDrawCube(MKLRenderer *renderer, MKLCube cube, MKLColor color);

MKLAPI void MKLDrawPlane(MKLRenderer *renderer, MKLPlane plane, MKLColor color);

MKLAPI void MKLGetPlaneVertices(MKLPlane *plane);

#endif // _MKL_MODELS_H_