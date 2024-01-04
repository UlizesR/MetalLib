#ifndef _M_COLOR_H_
#define _M_COLOR_H_

#include <simd/simd.h>

#define M_COLOR2VECTOR_F4(color) ((vector_float4){color.r, color.g, color.b, color.a})

typedef struct MColor
{
    float r;
    float g;
    float b;
    float a;
} MColor;

// Basic colors
#define M_COLOR_TRANSPARENT   (MColor){0.0f, 0.0f, 0.0f, 0.0f}
#define M_COLOR_WHITE         (MColor){1.0f, 1.0f, 1.0f, 1.0f}
#define M_COLOR_BLACK         (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED           (MColor){1.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GREEN         (MColor){0.0f, 1.0f, 0.0f, 1.0f}
#define M_COLOR_BLUE          (MColor){0.0f, 0.0f, 1.0f, 1.0f}
#define M_COLOR_YELLOW        (MColor){1.0f, 1.0f, 0.0f, 1.0f}
#define M_COLOR_MAGENTA       (MColor){1.0f, 0.0f, 1.0f, 1.0f}
#define M_COLOR_CYAN          (MColor){0.0f, 1.0f, 1.0f, 1.0f}

// Grayscale colors
#define M_COLOR_GRAY_0        (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GRAY_1        (MColor){0.1f, 0.1f, 0.1f, 1.0f}
#define M_COLOR_GRAY_2        (MColor){0.2f, 0.2f, 0.2f, 1.0f}
#define M_COLOR_GRAY_3        (MColor){0.3f, 0.3f, 0.3f, 1.0f}
#define M_COLOR_GRAY_4        (MColor){0.4f, 0.4f, 0.4f, 1.0f}
#define M_COLOR_GRAY_5        (MColor){0.5f, 0.5f, 0.5f, 1.0f}
#define M_COLOR_GRAY_6        (MColor){0.6f, 0.6f, 0.6f, 1.0f}
#define M_COLOR_GRAY_7        (MColor){0.7f, 0.7f, 0.7f, 1.0f}
#define M_COLOR_GRAY_8        (MColor){0.8f, 0.8f, 0.8f, 1.0f}
#define M_COLOR_GRAY_9        (MColor){0.9f, 0.9f, 0.9f, 1.0f}
#define M_COLOR_GRAY_10       (MColor){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define M_COLOR_RED_0         (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_1         (MColor){0.1f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_2         (MColor){0.2f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_3         (MColor){0.3f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_4         (MColor){0.4f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_5         (MColor){0.5f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_6         (MColor){0.6f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_7         (MColor){0.7f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_8         (MColor){0.8f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_9         (MColor){0.9f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_10        (MColor){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define M_COLOR_GREEN_0       (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GREEN_1       (MColor){0.0f, 0.1f, 0.0f, 1.0f}
#define M_COLOR_GREEN_2       (MColor){0.0f, 0.2f, 0.0f, 1.0f}
#define M_COLOR_GREEN_3       (MColor){0.0f, 0.3f, 0.0f, 1.0f}
#define M_COLOR_GREEN_4       (MColor){0.0f, 0.4f, 0.0f, 1.0f}
#define M_COLOR_GREEN_5       (MColor){0.0f, 0.5f, 0.0f, 1.0f}
#define M_COLOR_GREEN_6       (MColor){0.0f, 0.6f, 0.0f, 1.0f}
#define M_COLOR_GREEN_7       (MColor){0.0f, 0.7f, 0.0f, 1.0f}
#define M_COLOR_GREEN_8       (MColor){0.0f, 0.8f, 0.0f, 1.0f}
#define M_COLOR_GREEN_9       (MColor){0.0f, 0.9f, 0.0f, 1.0f}
#define M_COLOR_GREEN_10      (MColor){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define M_COLOR_BLUE_0        (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_BLUE_1        (MColor){0.0f, 0.0f, 0.1f, 1.0f}
#define M_COLOR_BLUE_2        (MColor){0.0f, 0.0f, 0.2f, 1.0f}
#define M_COLOR_BLUE_3        (MColor){0.0f, 0.0f, 0.3f, 1.0f}
#define M_COLOR_BLUE_4        (MColor){0.0f, 0.0f, 0.4f, 1.0f}
#define M_COLOR_BLUE_5        (MColor){0.0f, 0.0f, 0.5f, 1.0f}
#define M_COLOR_BLUE_6        (MColor){0.0f, 0.0f, 0.6f, 1.0f}
#define M_COLOR_BLUE_7        (MColor){0.0f, 0.0f, 0.7f, 1.0f}
#define M_COLOR_BLUE_8        (MColor){0.0f, 0.0f, 0.8f, 1.0f}
#define M_COLOR_BLUE_9        (MColor){0.0f, 0.0f, 0.9f, 1.0f}
#define M_COLOR_BLUE_10       (MColor){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define M_COLOR_YELLOW_0      (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_1      (MColor){0.1f, 0.1f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_2      (MColor){0.2f, 0.2f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_3      (MColor){0.3f, 0.3f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_4      (MColor){0.4f, 0.4f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_5      (MColor){0.5f, 0.5f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_6      (MColor){0.6f, 0.6f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_7      (MColor){0.7f, 0.7f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_8      (MColor){0.8f, 0.8f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_9      (MColor){0.9f, 0.9f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_10     (MColor){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define M_COLOR_MAGENTA_0     (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_MAGENTA_1     (MColor){0.1f, 0.0f, 0.1f, 1.0f}
#define M_COLOR_MAGENTA_2     (MColor){0.2f, 0.0f, 0.2f, 1.0f}
#define M_COLOR_MAGENTA_3     (MColor){0.3f, 0.0f, 0.3f, 1.0f}
#define M_COLOR_MAGENTA_4     (MColor){0.4f, 0.0f, 0.4f, 1.0f}
#define M_COLOR_MAGENTA_5     (MColor){0.5f, 0.0f, 0.5f, 1.0f}
#define M_COLOR_MAGENTA_6     (MColor){0.6f, 0.0f, 0.6f, 1.0f}
#define M_COLOR_MAGENTA_7     (MColor){0.7f, 0.0f, 0.7f, 1.0f}
#define M_COLOR_MAGENTA_8     (MColor){0.8f, 0.0f, 0.8f, 1.0f}
#define M_COLOR_MAGENTA_9     (MColor){0.9f, 0.0f, 0.9f, 1.0f}
#define M_COLOR_MAGENTA_10    (MColor){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define M_COLOR_CYAN_0        (MColor){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_CYAN_1        (MColor){0.0f, 0.1f, 0.1f, 1.0f}
#define M_COLOR_CYAN_2        (MColor){0.0f, 0.2f, 0.2f, 1.0f}
#define M_COLOR_CYAN_3        (MColor){0.0f, 0.3f, 0.3f, 1.0f}
#define M_COLOR_CYAN_4        (MColor){0.0f, 0.4f, 0.4f, 1.0f}
#define M_COLOR_CYAN_5        (MColor){0.0f, 0.5f, 0.5f, 1.0f}
#define M_COLOR_CYAN_6        (MColor){0.0f, 0.6f, 0.6f, 1.0f}
#define M_COLOR_CYAN_7        (MColor){0.0f, 0.7f, 0.7f, 1.0f}
#define M_COLOR_CYAN_8        (MColor){0.0f, 0.8f, 0.8f, 1.0f}
#define M_COLOR_CYAN_9        (MColor){0.0f, 0.9f, 0.9f, 1.0f}
#define M_COLOR_CYAN_10       (MColor){0.0f, 1.0f, 1.0f, 1.0f}


#endif // _M_COLOR_H_