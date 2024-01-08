#ifndef _MKL_MODELS_H_
#define _MKL_MODELS_H_

#include "../MKLCore.h"
#include "../MKLColors.h"
#include "MKLRenderer.h"

#include <simd/vector.h>
#include <simd/vector_types.h>

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>
#endif

typedef enum MKLModelType
{
    MKLModelTypeTriangle,
    MKLModelTypeSquare,
    MKLModelTypeSphere,
    MKLModelTypeCube,
    MKLModelTypeCylinder,
    MKLModelTypeCone,
    MKLModelTypeTorus,
    MKLModelTypePlane,
} MKLModelType;

typedef struct MKLVertex
{
    vector_float3 position;
} MKLVertex;

// typedef struct MKLModel 
// {
//     MKLModelType type;
//     MKLColor color;
//     MKLVertex *vertices;
// #ifdef __OBJC__
//     id<MTLBuffer> _vertexBuffer;
// #endif
// } MKLModel;

typedef struct MKLTriangle
{
    MKLColor color;
    vector_float3 p1;
    vector_float3 p2;
    vector_float3 p3;
} MKLTriangle;


MKLAPI void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle *triangle);

#endif // _MKL_MODELS_H_