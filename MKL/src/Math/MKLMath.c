#include "MKLMath.h"


#include <simd/matrix.h>
#include <simd/matrix_types.h>
#include <simd/vector_types.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

matrix_float4x4 MTranslate(vector_float3 direction)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(1, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, 1, 0, 0);
    result.columns[2] = simd_make_float4(0, 0, 1, 0);
    result.columns[3] = simd_make_float4(direction.x, direction.y, direction.z, 1);

    return result;
}

matrix_float4x4 MLookAt(vector_float3 eye, vector_float3 target, vector_float3 up)
{
    vector_float3 forwards = simd_normalize(target - eye);
    vector_float3 right = simd_normalize(simd_cross(up, forwards));
    vector_float3 upVector = simd_cross(forwards, right);

    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(right.x, upVector.x, forwards.x, 0);
    result.columns[1] = simd_make_float4(right.y, upVector.y, forwards.y, 0);
    result.columns[2] = simd_make_float4(right.z, upVector.z, forwards.z, 0);
    result.columns[3] = simd_make_float4(-simd_dot(right, eye), -simd_dot(upVector, eye), -simd_dot(forwards, eye), 1);

    return result;
}

matrix_float4x4 MPerspective(float fov, float aspect, float near, float far)
{
    float rad = fov * (M_PI / 360.0f);
    float fovRad = 1.0f / tanf(rad);

    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4( aspect * fovRad, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, fovRad, 0, 0);
    result.columns[2] = simd_make_float4(0, 0, far / (far - near), 1);
    result.columns[3] = simd_make_float4(0, 0, (-far * near) / (far - near), 0);

    return result;
}

matrix_float4x4 MScale(vector_float3 scale)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(scale.x, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, scale.y, 0, 0);
    result.columns[2] = simd_make_float4(0, 0, scale.z, 0);
    result.columns[3] = simd_make_float4(0, 0, 0, 1);

    return result;
}

matrix_float4x4 MRotate(vector_float3 eulers)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    float rad = (M_PI / 180.0f);

    float gamma = eulers.x * rad;
    float beta = eulers.y * rad;
    float alpha = eulers.z * rad;

    // result = MRotateZ(alpha) * MRotateY(beta) * MRotateX(gamma);
    result = simd_mul(MRotateZ(alpha), MRotateY(beta));
    result = simd_mul(result, MRotateX(gamma));

    return result;
}

matrix_float4x4 MRotateX(float angle)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(1, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, cosf(angle), sinf(angle), 0);
    result.columns[2] = simd_make_float4(0, -sinf(angle), cosf(angle), 0);
    result.columns[3] = simd_make_float4(0, 0, 0, 1);

    return result;
}

matrix_float4x4 MRotateY(float angle)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(cosf(angle), 0, -sinf(angle), 0);
    result.columns[1] = simd_make_float4(0, 1, 0, 0);
    result.columns[2] = simd_make_float4(sinf(angle), 0, cosf(angle), 0);
    result.columns[3] = simd_make_float4(0, 0, 0, 1);

    return result;
}

matrix_float4x4 MRotateZ(float angle)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    result.columns[0] = simd_make_float4(cosf(angle), sinf(angle), 0, 0);
    result.columns[1] = simd_make_float4(-sinf(angle), cosf(angle), 0, 0);
    result.columns[2] = simd_make_float4(0, 0, 1, 0);
    result.columns[3] = simd_make_float4(0, 0, 0, 1);

    return result;
}