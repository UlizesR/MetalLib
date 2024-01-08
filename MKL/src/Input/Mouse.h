#ifndef __MKL_MOUSE_H__
#define __MKL_MOUSE_H__

#include <stdbool.h>
#include <simd/vector.h>

typedef enum {
    MouseCodesLeft = 0,
    MouseCodesRight = 1,
    MouseCodesCenter = 2
} MouseCodes;

void MKLSetMouseButtonPressed(MouseCodes button, bool isOn);

bool MKLIsMouseButtonPressed(MouseCodes button);

void MKLSetOverallMousePosition(float x, float y);

void MKLSetMousePositionChangeWithOverallPosition(float x, float y);

void MKLScrollMouse(float deltaY);

float MKLGetMouseDWheel();

float MKLGetMouseDY();

float MKLGetMouseDX();

vector_float2 MKLGetMouseViewportPosition(float viewportWidth, float viewportHeight);

vector_float2 MKLGetMouseWindowPosition();

#endif // __MKL_MOUSE_H__