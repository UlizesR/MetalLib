#ifndef _mcl_defs_h_
#define _mcl_defs_h_

#include <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Vertex {
    vector_float2 position;
    vector_float4 color;
} Vertex;

typedef struct MCL_App MCL_App;           // The app

typedef struct MCL_Frame MCL_Frame;         // The view

typedef struct MCL_Window MCL_Window;     // window for apps

// gui element action callback
typedef void (*MCL_ActionCallback)(void *data);

#ifdef __cplusplus
}
#endif

#endif