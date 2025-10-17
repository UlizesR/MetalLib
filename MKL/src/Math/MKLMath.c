#include "MKLMath.h"

#include <simd/matrix.h>
#include <simd/matrix_types.h>
#include <simd/vector_types.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

matrix_float4x4 MRotateX(const float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { 1.0f, 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, cosf(angle), sinf(angle), 0.0f },
        .columns[2] = { 0.0f, -sinf(angle), cosf(angle), 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotateY(const float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { cosf(angle), 0.0f, -sinf(angle), 0.0f },
        .columns[1] = { 0.0f, 1.0f, 0.0f, 0.0f },
        .columns[2] = { sinf(angle), 0.0f, cosf(angle), 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotateZ(const float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { cosf(angle), sinf(angle), 0.0f, 0.0f },
        .columns[1] = { -sinf(angle), cosf(angle), 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, 1.0f, 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotate(const vector_float3 eulers)
{
    const float gamma = eulers[0] * (M_PI / 180.0f);
    const float beta = eulers[1] * (M_PI / 180.0f);
    const float alpha = eulers[2] * (M_PI / 180.0f);

    const matrix_float4x4 xr = MRotateX(gamma);
    const matrix_float4x4 yr = MRotateY(beta);
    const matrix_float4x4 zr = MRotateZ(alpha);

    return matrix_multiply(matrix_multiply(zr, yr), xr);
}

matrix_float4x4 MScale(const vector_float3 scale)
{
    matrix_float4x4 result = {
        .columns[0] = { scale[0], 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, scale[1], 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, scale[2], 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MTranslate(const vector_float3 direction)
{
    matrix_float4x4 result = {
        .columns[0] = { 1.0f, 0.0f, 0.0f, 0.0f},
        .columns[1] = { 0.0f, 1.0f, 0.0f, 0.0f},
        .columns[2] = { 0.0f, 0.0f, 1.0f, 0.0f},
        .columns[3] = { direction[0], direction[1], direction[2], 1.0f}
    };
    return result;
}



matrix_float4x4 MLookAt(const vector_float3 eye, const vector_float3 target, const vector_float3 up)
{
    const simd_float3 fV = simd_normalize(target - eye);
    const simd_float3 rV = simd_normalize(simd_cross(fV, up));
    const simd_float3 uV = simd_normalize(simd_cross(rV, fV));

    const matrix_float4x4 result = {
        .columns[0] = { rV[0], uV[0], fV[0], 0.0f },
        .columns[1] = { rV[1], uV[1], fV[1], 0.0f },
        .columns[2] = { rV[2], uV[2], fV[2], 0.0f },
        .columns[3] = { -simd_dot(rV, eye), -simd_dot(uV, eye), -simd_dot(fV, eye), 1.0f }
    };
    return result;
}

matrix_float4x4 MPerspective(const float fovy, const float aspect, const float near, const float far)
{
    const float f = 1.0f / tanf(fovy * (M_PI / 360.0f));
    const float lambda = far / (far - near);

    const float xc = aspect * f;
    const float yc = f;
    const float zc1 = -lambda * near;
    const float zc2 = lambda;

    const matrix_float4x4 result = {
        .columns[0] = { xc, 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, yc, 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, zc2, 1.0f},
        .columns[3] = { 0.0f, 0.0f, zc1, 0.0f }
    };

    return result;
}


vector_float3 MAddVector(const vector_float3 vec1, const vector_float3 vec2)
{
    // Use SIMD addition for better performance
    return vec1 + vec2;
}

vector_float3 MSubVector(const vector_float3 vec1, const vector_float3 vec2)
{
    // Use SIMD subtraction for better performance
    return vec1 - vec2;
}

vector_float3 MMulVecByScalar(const vector_float3 vec1, const float scalar)
{
    // Use SIMD multiplication for better performance
    return vec1 * scalar;
}
