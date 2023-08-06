#ifndef MAC_INTERNALS_H_
#define MAC_INTERNALS_H_

#include <MacTypes.h>

#ifdef __OBJC__
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MDimensions
{
    int width;
    int height;
    int x;
    int y;
} MDimensions;

typedef const char* MTitle;
typedef const char* MImage;

#ifdef __cplusplus
}
#endif

#endif // MAC_INTERNALS_H_