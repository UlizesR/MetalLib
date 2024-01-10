#ifndef _MKL_MODELS_H_
#define _MKL_MODELS_H_

#include "../Core/MKLCore.h"
#include "../MKLColors.h"
#include "../Renderer/MKLRenderer.h"

#include <simd/vector.h>
#include <simd/vector_types.h>

// void MKLDrawShape(MKLRenderer *renderer, vector_float3 *vertices, NSUInteger vertexCount, MTLPrimitiveType primitiveType)
// This is a Obj-C helper function implemented in MKLShapes.m

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

typedef struct MKLCube
{
    vector_float3 position;
    float width, height, depth;
} MKLCube;

MKLAPI void MKLDrawLine2D(MKLRenderer *renderer, MKLLine line, MKLColor color);

MKLAPI void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle triangle, MKLColor color);

MKLAPI void MKLDrawRect(MKLRenderer *renderer, MKLRect rect, MKLColor color);

MKLAPI void MKLDrawCube(MKLRenderer *renderer, MKLCube cube, MKLColor color);

#endif // _MKL_MODELS_H_