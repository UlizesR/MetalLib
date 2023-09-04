#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MSize
{
    int width;
    int height;
} MSize;

typedef struct MPoint
{
    int x;
    int y;
} MPoint;

typedef struct MFPoint
{
    float x;
    float y;
} MFPoint;

typedef struct M_View M_View;       // The view 

typedef struct M_Window M_Window;     // window for apps

#ifdef __cplusplus
}
#endif