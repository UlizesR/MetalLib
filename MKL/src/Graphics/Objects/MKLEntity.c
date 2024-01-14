#include "MKLEntity.h"
#include "../../Core/MKLError.h"
#include "../../Input/Mouse.h"

#include <stdlib.h>
#include <stdio.h>

void MKLSetCamera(MKLCamera *camera, vector_float3 position, vector_float3 up, float fov, float aspect, float near, float far)
{
    MKL_NULL_CHECK_VOID(camera, NULL, MKL_ERROR_NULL_POINTER, "MKLCamera is NULL!");
    camera->position = position;
    camera->up = up;
    camera->forward = (vector_float3){0.0f, 0.0f, -1.0f};
    camera->right = (vector_float3){1.0f, 0.0f, 0.0f};
    camera->fov = fov;
    camera->aspect = aspect;
    camera->near = near;
    camera->far = far;
}

void MKLUpdateCamera(MKLCamera *camera, MKLCameraControls controls)
{
    MKL_NULL_CHECK_VOID(camera, NULL, MKL_ERROR_NULL_POINTER, "MKLCamera is NULL!");
    if (controls == MKL_CAMERA_ORBIT)
    {
        vector_float2 mousePos = MKLGetMouseViewportPosition(800.0f, 600.0f);

        camera->yaw += MKLGetMouseDX() * 0.05f;
        camera->pitch -= MKLGetMouseDY() * 0.05f;
        camera->pitch = fminf(89.0f, fminf(89.0f, camera->pitch));

    }
    // convert to radians
    float yaw = camera->yaw * (M_PI / 180.0f);
    float pitch = camera->pitch * (M_PI / 180.0f);

    camera->forward.x = cosf(yaw) * cosf(pitch);
    camera->forward.y = sinf(pitch);
    camera->forward.z = sinf(yaw) * cosf(pitch);

    camera->forward = simd_normalize(camera->forward);
    camera->right = simd_normalize(simd_cross(camera->forward, (vector_float3){0.0f, 1.0f, 0.0f}));
    camera->up = simd_normalize(simd_cross(camera->right, camera->forward));

}