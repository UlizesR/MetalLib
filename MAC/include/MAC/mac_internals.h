#ifndef MAC_INTERNALS_H_
#define MAC_INTERNALS_H_

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

typedef struct MPosition
{
    int x;
    int y;
} MPosition;

typedef struct MProperties
{
    MPosition position;
    MSize size;
} MProperties;

typedef const char* MTitle;
typedef const char* MImage;

typedef void (*Action)(void*);

#ifdef __cplusplus
}
#endif

#endif // MAC_INTERNALS_H_