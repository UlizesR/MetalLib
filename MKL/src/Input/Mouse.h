#ifndef __MKL_MOUSE_H__
#define __MKL_MOUSE_H__

#include "../Core/MKLCore.h"

#include <simd/conversion.h>
#include <stdbool.h>
#include <simd/vector.h>


typedef enum {
    MouseCodeLeft = 0,  // Trackpad click
    MouseCodeRight = 1,
    MouseCodeCenter = 2,
} MouseCodes;

void MKLSetMouseButtonPressed(MouseCodes button, bool isOn);

bool MKLIsMouseButtonPressed(MouseCodes button);

void MKLSetOverallMousePosition(float x, float y);

void MKLSetMousePositionChangeWithOverallPosition(vector_float2 oPos, vector_float2 dPos);

MKLAPI void MKLScrollMouse(float deltaY);

MKLAPI float MKLGetMouseDWheel();

MKLAPI float MKLGetMouseDY();

MKLAPI float MKLGetMouseDX();

MKLAPI vector_float2 MKLGetMouseViewportPosition(float viewportWidth, float viewportHeight);

MKLAPI vector_float2 MKLGetMouseWindowPosition();

#endif // __MKL_MOUSE_H__