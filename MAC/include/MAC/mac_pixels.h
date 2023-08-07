#ifndef MAC_PIXELS_H_
#define MAC_PIXELS_H_

#include "mac_internals.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct 
{
    int x;
    int y;
} Mac_Point;

typedef struct 
{
    float x;
    float y;
} Mac_FPoint;

typedef struct 
{
    float r;
    float g;
    float b;
    float a;
} Mac_Color;



#ifdef __cplusplus
}
#endif

#endif // MAC_PIXELS_H_