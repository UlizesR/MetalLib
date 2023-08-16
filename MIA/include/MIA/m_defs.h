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

typedef const char* MTitle; // for titles
typedef const char* MImage; // for images paths
typedef const char* MFile;  // for file paths
typedef const char* MText;  // for text
typedef const char* MData;  // for data

typedef struct M_View M_View;       // The view 

typedef struct M_Window M_Window;     // window for apps

#ifdef __cplusplus
}
#endif