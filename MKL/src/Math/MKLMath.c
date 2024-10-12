#include "MKLMath.h"


#include <simd/matrix.h>
#include <simd/matrix_types.h>
#include <simd/vector_types.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// matrix_float4x4 createIdentity()
// {
//     return matrix_identity_float4x4;
// }

matrix_float4x4 MRotateX(float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { 1.0f, 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, cosf(angle), sinf(angle), 0.0f },
        .columns[2] = { 0.0f, -sinf(angle), cosf(angle), 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotateY(float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { cosf(angle), 0.0f, -sinf(angle), 0.0f },
        .columns[1] = { 0.0f, 1.0f, 0.0f, 0.0f },
        .columns[2] = { sinf(angle), 0.0f, cosf(angle), 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotateZ(float angle)
{
    matrix_float4x4 result = {
        .columns[0] = { cosf(angle), sinf(angle), 0.0f, 0.0f },
        .columns[1] = { -sinf(angle), cosf(angle), 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, 1.0f, 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MRotate(vector_float3 eulers)
{
    float gamma = eulers[0] * (M_PI / 180.0f);
    float beta = eulers[1] * (M_PI / 180.0f);
    float alpha = eulers[2] * (M_PI / 180.0f);

    matrix_float4x4 xr = MRotateX(gamma);
    matrix_float4x4 yr = MRotateY(beta);
    matrix_float4x4 zr = MRotateZ(alpha);

    return matrix_multiply(matrix_multiply(zr, yr), xr);
}

 matrix_float4x4 MScale(vector_float3 scale)
{
    matrix_float4x4 result = {
        .columns[0] = { scale[0], 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, scale[1], 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, scale[2], 0.0f },
        .columns[3] = { 0.0f, 0.0f, 0.0f, 1.0f }
    };
    return result;
}

matrix_float4x4 MTranslate(vector_float3 direction)
{
    matrix_float4x4 result = {
        .columns[0] = { 1.0f, 0.0f, 0.0f, 0.0f},
        .columns[1] = { 0.0f, 1.0f, 0.0f, 0.0f},
        .columns[2] = { 0.0f, 0.0f, 1.0f, 0.0f},
        .columns[3] = { direction[0], direction[1], direction[2], 1.0f}
    };
    return result;
}



matrix_float4x4 MLookAt(vector_float3 eye, vector_float3 target, vector_float3 up)
{
    simd_float3 fV = simd_normalize(target - eye);
    simd_float3 rV = simd_normalize(simd_cross(fV, up));
    simd_float3 uV = simd_normalize(simd_cross(rV, fV));

    matrix_float4x4 result = {
        .columns[0] = { rV[0], uV[0], fV[0], 0.0f },
        .columns[1] = { rV[1], uV[1], fV[1], 0.0f },
        .columns[2] = { rV[2], uV[2], fV[2], 0.0f },
        .columns[3] = { -simd_dot(rV, eye), -simd_dot(uV, eye), -simd_dot(fV, eye), 1.0f }
    };
    return result;
}

matrix_float4x4 MPerspective(float fovy, float aspect, float near, float far)
{
    float f = 1.0f / tanf(fovy * (M_PI / 360.0f));

    float lambda = far / (far - near);

    float xc = aspect * f;
    float yc = f;
    float zc1 = -lambda * near;
    float zc2 = lambda;

    matrix_float4x4 result = {
        .columns[0] = { xc, 0.0f, 0.0f, 0.0f },
        .columns[1] = { 0.0f, yc, 0.0f, 0.0f },
        .columns[2] = { 0.0f, 0.0f, zc2, 1.0f},
        .columns[3] = { 0.0f, 0.0f, zc1, 0.0f }
    };

    return result;
}


vector_float3 MAddVector(vector_float3 vec1, vector_float3 vec2)
{
    vector_float3 result = {
        vec1[0] + vec2[0],
        vec1[1] + vec2[1],
        vec1[2] + vec2[2]
    };
    return result;
}

vector_float3 MSubVector(vector_float3 vec1, vector_float3 vec2)
{
    vector_float3 result = {
        vec1[0] - vec2[0],
        vec1[1] - vec2[1],
        vec1[2] - vec2[2]
    };
    return result;
}

vector_float3 MMulVecByScalar(vector_float3 vec1, float  vec2)
{
    vector_float3 result = {
        vec1[0] * vec2,
        vec1[1] * vec2,
        vec1[2] * vec2
    };
    return result;
}