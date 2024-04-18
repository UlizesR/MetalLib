#ifndef _MTLC_MATH_H_
#define _MTLC_MATH_H_

#include <simd/matrix.h>
#include <simd/vector.h>

#define X_AXIS simd_make_float3(1.0f, 0.0f, 0.0f)
#define Y_AXIS simd_make_float3(0.0f, 1.0f, 0.0f)
#define Z_AXIS simd_make_float3(0.0f, 0.0f, 1.0f)

#define WORLD_ORIGIN simd_make_float4(0.0f, 0.0f, 0.0f, 1.0f)

#define IDENTITY_MATRIX matrix_identity_float4x4

matrix_float4x4 MTranslate(vector_float3 direction);

matrix_float4x4 MLookAt(vector_float3 eye, vector_float3 target, vector_float3 up);

matrix_float4x4 MPerspective(float fov, float aspect, float near, float far);

matrix_float4x4 MScale(vector_float3 scale);

matrix_float4x4 MRotate(vector_float3 eulers);

matrix_float4x4 MRotateX(float angle);

matrix_float4x4 MRotateY(float angle);

matrix_float4x4 MRotateZ(float angle);

vector_float3 MAddVector(vector_float3 vec1, vector_float3  vec2);

vector_float3 MSubVector(vector_float3 vec1, vector_float3  vec2);

vector_float3 MMulVecByScalar(vector_float3 vec1, float  vec2);

#endif // _MTLC_MATH_H_