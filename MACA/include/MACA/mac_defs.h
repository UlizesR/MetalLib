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

typedef struct M_NView M_NView;     // Normal view for apps
typedef struct M_RView M_RView;     // normal view to render core graphics
typedef struct M_MView M_MView;     // metal view to render metal graphics
typedef struct M_TView M_TView;     // table view
typedef union UView UView;          // The union of all views
typedef struct M_View M_View;       // The view (can be any of the above)

typedef struct M_Window M_Window;     // window for apps
typedef struct M_Renderer M_Renderer; // renderer for graphics

#ifdef __cplusplus
}
#endif