#ifndef _MKL_ENTITY_H_
#define _MKL_ENTITY_H_

#include <simd/matrix_types.h>
#include <simd/simd.h>
#include <simd/types.h>

#include "../Renderer/MKLTypes.h"
#include "../Core/MKLCore.h"

typedef struct MKLCamera {
    vector_float3 position;
    vector_float3 up;
    vector_float3 forward;
    vector_float3 right;
    simd_quatf rotation;
    float fov, aspect, near, far;
    float yaw, pitch;
} MKLCamera;

typedef enum MKLCameraControls
{
    MKL_CAMERA_ORBIT = 0x01,
} MKLCameraControls;

MKLAPI void MKLUpdateCamera(MKLCamera *camera, MKLCameraControls controls);

#endif // _MKL_ENTITY_H_