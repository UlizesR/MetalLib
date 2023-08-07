#ifndef mac_internals_h_
#define mac_internals_h_

#include <MacTypes.h>

#ifdef __OBJC__
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MSize
{
    int width;
    int height;
} MSize;

typedef struct 
{
    int x;
    int y;
} MPoint;

typedef struct 
{
    float x;
    float y;
} MFPoint;


typedef const char* MTitle;
typedef const char* MImage;

typedef struct Mac_View Mac_View;
typedef struct Mac_Window Mac_Window;

typedef UInt32 Mac_WindowID;


#ifdef __cplusplus
}
#endif

#endif // mac_internals_h_