#ifndef _MKL_OBJECTS_H_
#define _MKL_OBJECTS_H_

#include "../MKLColors.h"
#include "../MKLRenderer.h"
#include "../../Core/MKLCore.h"

#include <simd/vector_types.h>

MKLAPI void MKLDrawAxis(MKLRenderer* renderer, float length);

MKLAPI void MKLDrawGrid(MKLRenderer* renderer, float size, float step, vector_float4 axis);

#endif // _MKL_OBJECTS_H_
