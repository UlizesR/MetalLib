#ifndef _MKL_TYPES_H_
#define _MKL_TYPES_H_

#include <simd/vector.h>

typedef struct MKLVertex
{
    vector_float3 position;
    vector_float4 color;
} MKLVertex;

#endif // _MKL_TYPES_H_