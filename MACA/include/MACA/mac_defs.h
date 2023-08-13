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

typedef struct Mac_NView Mac_NView;     // Normal view for apps
typedef struct Mac_RView Mac_RView;     // normal view to render core graphics
typedef struct Mac_MView Mac_MView;     // metal view to render metal graphics
typedef union UView UView;              // The union of all views
typedef struct Mac_View Mac_View;       // The view (can be any of the above)

typedef struct Mac_Window Mac_Window;     // window for apps
typedef struct Mac_Renderer Mac_Renderer; // renderer for graphics

#ifdef __cplusplus
}
#endif