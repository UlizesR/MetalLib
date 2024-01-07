#include "MKLMath.h"


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

matrix_float4x4 MTranslate(vector_float3 direction)
{
    matrix_float4x4 result = IDENTITY_MATRIX;

    float x = direction.x;
    float y = direction.y;
    float z = direction.z;

    result.columns[0] = simd_make_float4(1, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, 1, 0, 0);
    result.columns[2] = simd_make_float4(0, 0, 1, 0);
    result.columns[3] = simd_make_float4(x, y, z, 1);

    return simd_mul(result, matrix_identity_float4x4);
}

matrix_float4x4 MScale(vector_float3 scale)
{
    matrix_float4x4 result = matrix_identity_float4x4;

    float x = scale.x;
    float y = scale.y;
    float z = scale.z;

    result.columns[0] = simd_make_float4(x, 0, 0, 0);
    result.columns[1] = simd_make_float4(0, y, 0, 0);
    result.columns[2] = simd_make_float4(0, 0, z, 0);
    result.columns[3] = simd_make_float4(0, 0, 0, 1);

    return simd_mul(result, matrix_identity_float4x4);
}

matrix_float4x4 MRotate(float angle, vector_float3 axis)
{
    matrix_float4x4 result = matrix_identity_float4x4;

    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    float c = cos(angle);
    float s = sin(angle);

    float mc = 1 - c;

    float r1c1 = x * x * mc + c;
    float r2c1 = x * y * mc + z * s;
    float r3c1 = x * z * mc - y * s;
    float r4c1 = 0.0;
    
    float r1c2 = y * x * mc - z * s;
    float r2c2 = y * y * mc + c;
    float r3c2 = y * z * mc + x * s;
    float r4c2 = 0.0;
    
    float r1c3 = z * x * mc + y * s;
    float r2c3 = z * y * mc - x * s;
    float r3c3 = z * z * mc + c;
    float r4c3 = 0.0;
    
    float r1c4 = 0.0;
    float r2c4 = 0.0;
    float r3c4 = 0.0;
    float r4c4 = 1.0;

    result.columns[0] = simd_make_float4(r1c1, r2c1, r3c1, r4c1);
    result.columns[1] = simd_make_float4(r1c2, r2c2, r3c2, r4c2);
    result.columns[2] = simd_make_float4(r1c3, r2c3, r3c3, r4c3);   
    result.columns[3] = simd_make_float4(r1c4, r2c4, r3c4, r4c4);

    return simd_mul(result, matrix_identity_float4x4);
}