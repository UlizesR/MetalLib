#ifndef _MKL_MATH_H_
#define _MKL_MATH_H_

#include <simd/matrix.h>
#include <simd/vector.h>

#include "../Core/MKLCore.h"

#define X_AXIS simd_make_float3(1.0f, 0.0f, 0.0f)
#define Y_AXIS simd_make_float3(0.0f, 1.0f, 0.0f)
#define Z_AXIS simd_make_float3(0.0f, 0.0f, 1.0f)

#define WORLD_ORIGIN simd_make_float4(0.0f, 0.0f, 0.0f, 1.0f)

#define IDENTITY_MATRIX matrix_identity_float4x4

MKLAPI matrix_float4x4 MTranslate(vector_float3 direction);

MKLAPI matrix_float4x4 MLookAt(vector_float3 eye, vector_float3 target, vector_float3 up);

MKLAPI matrix_float4x4 MPerspective(float fov, float aspect, float near, float far);

MKLAPI matrix_float4x4 MScale(vector_float3 scale);

MKLAPI matrix_float4x4 MRotate(vector_float3 eulers);

MKLAPI matrix_float4x4 MRotateX(float angle);

MKLAPI matrix_float4x4 MRotateY(float angle);

MKLAPI matrix_float4x4 MRotateZ(float angle);

MKLAPI vector_float3 MAddVector(vector_float3 vec1, vector_float3  vec2);

#endif // _MKL_MATH_H_