#ifndef _MKL_MESH_H_
#define _MKL_MESH_H_

#include <simd/vector_types.h>
#ifdef __OBJC__
#import <MetalKit/MetalKit.h>
#import <ModelIO/ModelIO.h>
#endif

#include "../Core/MKLCore.h"
#include "MKLShapes.h"
#include "../Renderer/MKLRenderer.h"

typedef struct MKLMesh 
{
    vector_float3 position;
    vector_float3 *vertices;
    vector_float3 rotation;
    int vertexCount;

#ifdef __OBJC__
    MDLMesh* _mdlMesh;
    MTKMesh *_mtkMesh;
#endif
} MKLMesh;


MKLAPI MKLMesh MKLMeshCreateWithFile(const char* path);

MKLAPI void MKLMeshPlane(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float2 dimensions, simd_uint2 segments, vector_float3 rotation);

MKLAPI void MKLDrawMesh(MKLRenderer *renderer, MKLMesh *mesh, MKLColor color);

#endif // _MKL_MESH_H_