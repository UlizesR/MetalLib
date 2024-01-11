#ifndef _MKL_ENTITY_H_
#define _MKL_ENTITY_H_

#include <simd/matrix_types.h>
#include <simd/simd.h>

#include "../Renderer/MKLTypes.h"
#include "../Core/MKLCore.h"

typedef struct MKLCamera {
    vector_float3 position;
    vector_float3 up;
    vector_float3 forward;
    vector_float3 right;
    float fov;
    float aspect;
    float near;
    float far;
} MKLCamera;

MKLAPI void MKLSetCamera(MKLCamera *camera, vector_float3 position, vector_float3 up, float fov, float aspect, float near, float far);

MKLAPI void MKLUpdateCamera(MKLCamera *camera);

#endif // _MKL_ENTITY_H_