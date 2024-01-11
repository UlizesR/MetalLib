#include "MKLEntity.h"
#include "../Core/MKLError.h"
#include "../Input/MKLInput.h"

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

void MKLUpdateCamera(MKLCamera *camera)
{
    
}