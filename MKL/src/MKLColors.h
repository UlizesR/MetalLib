#ifndef _MKL_COLOR_H_
#define _MKL_COLOR_H_

#include <simd/simd.h>

#define MKL_COLOR2VECTOR_F4(color) ((vector_float4){color.r, color.g, color.b, color.a})

typedef vector_float4 MKLColor;

// Basic colors
#define MKL_COLOR_TRANSPARENT   (MKLColor){0.0f, 0.0f, 0.0f, 0.0f}
#define MKL_COLOR_WHITE         (MKLColor){1.0f, 1.0f, 1.0f, 1.0f}
#define MKL_COLOR_BLACK         (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED           (MKLColor){1.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN         (MKLColor){0.0f, 1.0f, 0.0f, 1.0f}
#define MKL_COLOR_BLUE          (MKLColor){0.0f, 0.0f, 1.0f, 1.0f}
#define MKL_COLOR_YELLOW        (MKLColor){1.0f, 1.0f, 0.0f, 1.0f}
#define MKL_COLOR_MAGENTA       (MKLColor){1.0f, 0.0f, 1.0f, 1.0f}
#define MKL_COLOR_CYAN          (MKLColor){0.0f, 1.0f, 1.0f, 1.0f}

// random colors
#define MKL_COLOR_MAIN          (MKLColor){47.0f/255.0f, 79.0f/255.0f, 79.0f/255.0f, 1.0}
#define MKL_COLOR_SKY           (MKLColor){182.0f/255.0f, 240.0f/255.0f, 228.0f/255.0f, 1.0f}

// Grayscale colors
#define MKL_COLOR_GRAY_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_GRAY_1        (MKLColor){0.1f, 0.1f, 0.1f, 1.0f}
#define MKL_COLOR_GRAY_2        (MKLColor){0.2f, 0.2f, 0.2f, 1.0f}
#define MKL_COLOR_GRAY_3        (MKLColor){0.3f, 0.3f, 0.3f, 1.0f}
#define MKL_COLOR_GRAY_4        (MKLColor){0.4f, 0.4f, 0.4f, 1.0f}
#define MKL_COLOR_GRAY_5        (MKLColor){0.5f, 0.5f, 0.5f, 1.0f}
#define MKL_COLOR_GRAY_6        (MKLColor){0.6f, 0.6f, 0.6f, 1.0f}
#define MKL_COLOR_GRAY_7        (MKLColor){0.7f, 0.7f, 0.7f, 1.0f}
#define MKL_COLOR_GRAY_8        (MKLColor){0.8f, 0.8f, 0.8f, 1.0f}
#define MKL_COLOR_GRAY_9        (MKLColor){0.9f, 0.9f, 0.9f, 1.0f}
#define MKL_COLOR_GRAY_10       (MKLColor){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define MKL_COLOR_RED_0         (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_1         (MKLColor){0.1f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_2         (MKLColor){0.2f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_3         (MKLColor){0.3f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_4         (MKLColor){0.4f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_5         (MKLColor){0.5f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_6         (MKLColor){0.6f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_7         (MKLColor){0.7f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_8         (MKLColor){0.8f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_9         (MKLColor){0.9f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_RED_10        (MKLColor){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define MKL_COLOR_GREEN_0       (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_1       (MKLColor){0.0f, 0.1f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_2       (MKLColor){0.0f, 0.2f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_3       (MKLColor){0.0f, 0.3f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_4       (MKLColor){0.0f, 0.4f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_5       (MKLColor){0.0f, 0.5f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_6       (MKLColor){0.0f, 0.6f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_7       (MKLColor){0.0f, 0.7f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_8       (MKLColor){0.0f, 0.8f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_9       (MKLColor){0.0f, 0.9f, 0.0f, 1.0f}
#define MKL_COLOR_GREEN_10      (MKLColor){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define MKL_COLOR_BLUE_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_BLUE_1        (MKLColor){0.0f, 0.0f, 0.1f, 1.0f}
#define MKL_COLOR_BLUE_2        (MKLColor){0.0f, 0.0f, 0.2f, 1.0f}
#define MKL_COLOR_BLUE_3        (MKLColor){0.0f, 0.0f, 0.3f, 1.0f}
#define MKL_COLOR_BLUE_4        (MKLColor){0.0f, 0.0f, 0.4f, 1.0f}
#define MKL_COLOR_BLUE_5        (MKLColor){0.0f, 0.0f, 0.5f, 1.0f}
#define MKL_COLOR_BLUE_6        (MKLColor){0.0f, 0.0f, 0.6f, 1.0f}
#define MKL_COLOR_BLUE_7        (MKLColor){0.0f, 0.0f, 0.7f, 1.0f}
#define MKL_COLOR_BLUE_8        (MKLColor){0.0f, 0.0f, 0.8f, 1.0f}
#define MKL_COLOR_BLUE_9        (MKLColor){0.0f, 0.0f, 0.9f, 1.0f}
#define MKL_COLOR_BLUE_10       (MKLColor){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define MKL_COLOR_YELLOW_0      (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_1      (MKLColor){0.1f, 0.1f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_2      (MKLColor){0.2f, 0.2f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_3      (MKLColor){0.3f, 0.3f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_4      (MKLColor){0.4f, 0.4f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_5      (MKLColor){0.5f, 0.5f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_6      (MKLColor){0.6f, 0.6f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_7      (MKLColor){0.7f, 0.7f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_8      (MKLColor){0.8f, 0.8f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_9      (MKLColor){0.9f, 0.9f, 0.0f, 1.0f}
#define MKL_COLOR_YELLOW_10     (MKLColor){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define MKL_COLOR_MAGENTA_0     (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_MAGENTA_1     (MKLColor){0.1f, 0.0f, 0.1f, 1.0f}
#define MKL_COLOR_MAGENTA_2     (MKLColor){0.2f, 0.0f, 0.2f, 1.0f}
#define MKL_COLOR_MAGENTA_3     (MKLColor){0.3f, 0.0f, 0.3f, 1.0f}
#define MKL_COLOR_MAGENTA_4     (MKLColor){0.4f, 0.0f, 0.4f, 1.0f}
#define MKL_COLOR_MAGENTA_5     (MKLColor){0.5f, 0.0f, 0.5f, 1.0f}
#define MKL_COLOR_MAGENTA_6     (MKLColor){0.6f, 0.0f, 0.6f, 1.0f}
#define MKL_COLOR_MAGENTA_7     (MKLColor){0.7f, 0.0f, 0.7f, 1.0f}
#define MKL_COLOR_MAGENTA_8     (MKLColor){0.8f, 0.0f, 0.8f, 1.0f}
#define MKL_COLOR_MAGENTA_9     (MKLColor){0.9f, 0.0f, 0.9f, 1.0f}
#define MKL_COLOR_MAGENTA_10    (MKLColor){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define MKL_COLOR_CYAN_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_CYAN_1        (MKLColor){0.0f, 0.1f, 0.1f, 1.0f}
#define MKL_COLOR_CYAN_2        (MKLColor){0.0f, 0.2f, 0.2f, 1.0f}
#define MKL_COLOR_CYAN_3        (MKLColor){0.0f, 0.3f, 0.3f, 1.0f}
#define MKL_COLOR_CYAN_4        (MKLColor){0.0f, 0.4f, 0.4f, 1.0f}
#define MKL_COLOR_CYAN_5        (MKLColor){0.0f, 0.5f, 0.5f, 1.0f}
#define MKL_COLOR_CYAN_6        (MKLColor){0.0f, 0.6f, 0.6f, 1.0f}
#define MKL_COLOR_CYAN_7        (MKLColor){0.0f, 0.7f, 0.7f, 1.0f}
#define MKL_COLOR_CYAN_8        (MKLColor){0.0f, 0.8f, 0.8f, 1.0f}
#define MKL_COLOR_CYAN_9        (MKLColor){0.0f, 0.9f, 0.9f, 1.0f}
#define MKL_COLOR_CYAN_10       (MKLColor){0.0f, 1.0f, 1.0f, 1.0f}

// Brownscale colors
#define MKL_COLOR_BROWN_0       (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_1       (MKLColor){0.1f, 0.05f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_2       (MKLColor){0.2f, 0.1f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_3       (MKLColor){0.3f, 0.15f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_4       (MKLColor){0.4f, 0.2f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_5       (MKLColor){0.5f, 0.25f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_6       (MKLColor){0.6f, 0.3f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_7       (MKLColor){0.7f, 0.35f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_8       (MKLColor){0.8f, 0.4f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_9       (MKLColor){0.9f, 0.45f, 0.0f, 1.0f}
#define MKL_COLOR_BROWN_10      (MKLColor){1.0f, 0.5f, 0.0f, 1.0f}

// Orangescale colors
#define MKL_COLOR_ORANGE_0      (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_1      (MKLColor){0.1f, 0.05f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_2      (MKLColor){0.2f, 0.1f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_3      (MKLColor){0.3f, 0.15f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_4      (MKLColor){0.4f, 0.2f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_5      (MKLColor){0.5f, 0.25f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_6      (MKLColor){0.6f, 0.3f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_7      (MKLColor){0.7f, 0.35f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_8      (MKLColor){0.8f, 0.4f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_9      (MKLColor){0.9f, 0.45f, 0.0f, 1.0f}
#define MKL_COLOR_ORANGE_10     (MKLColor){1.0f, 0.5f, 0.0f, 1.0f}

// Purplescale colors
#define MKL_COLOR_PURPLE_0      (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_PURPLE_1      (MKLColor){0.1f, 0.0f, 0.1f, 1.0f}
#define MKL_COLOR_PURPLE_2      (MKLColor){0.2f, 0.0f, 0.2f, 1.0f}
#define MKL_COLOR_PURPLE_3      (MKLColor){0.3f, 0.0f, 0.3f, 1.0f}
#define MKL_COLOR_PURPLE_4      (MKLColor){0.4f, 0.0f, 0.4f, 1.0f}
#define MKL_COLOR_PURPLE_5      (MKLColor){0.5f, 0.0f, 0.5f, 1.0f}
#define MKL_COLOR_PURPLE_6      (MKLColor){0.6f, 0.0f, 0.6f, 1.0f}
#define MKL_COLOR_PURPLE_7      (MKLColor){0.7f, 0.0f, 0.7f, 1.0f}
#define MKL_COLOR_PURPLE_8      (MKLColor){0.8f, 0.0f, 0.8f, 1.0f}
#define MKL_COLOR_PURPLE_9      (MKLColor){0.9f, 0.0f, 0.9f, 1.0f}
#define MKL_COLOR_PURPLE_10     (MKLColor){1.0f, 0.0f, 1.0f, 1.0f}

// Pinkscale colors
#define MKL_COLOR_PINK_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_PINK_1        (MKLColor){0.1f, 0.0f, 0.05f, 1.0f}
#define MKL_COLOR_PINK_2        (MKLColor){0.2f, 0.0f, 0.1f, 1.0f}
#define MKL_COLOR_PINK_3        (MKLColor){0.3f, 0.0f, 0.15f, 1.0f}
#define MKL_COLOR_PINK_4        (MKLColor){0.4f, 0.0f, 0.2f, 1.0f}
#define MKL_COLOR_PINK_5        (MKLColor){0.5f, 0.0f, 0.25f, 1.0f}
#define MKL_COLOR_PINK_6        (MKLColor){0.6f, 0.0f, 0.3f, 1.0f}
#define MKL_COLOR_PINK_7        (MKLColor){0.7f, 0.0f, 0.35f, 1.0f}
#define MKL_COLOR_PINK_8        (MKLColor){0.8f, 0.0f, 0.4f, 1.0f}
#define MKL_COLOR_PINK_9        (MKLColor){0.9f, 0.0f, 0.45f, 1.0f}
#define MKL_COLOR_PINK_10       (MKLColor){1.0f, 0.0f, 0.5f, 1.0f}

// Tealscale colors
#define MKL_COLOR_TEAL_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_TEAL_1        (MKLColor){0.0f, 0.05f, 0.1f, 1.0f}
#define MKL_COLOR_TEAL_2        (MKLColor){0.0f, 0.1f, 0.2f, 1.0f}
#define MKL_COLOR_TEAL_3        (MKLColor){0.0f, 0.15f, 0.3f, 1.0f}
#define MKL_COLOR_TEAL_4        (MKLColor){0.0f, 0.2f, 0.4f, 1.0f}
#define MKL_COLOR_TEAL_5        (MKLColor){0.0f, 0.25f, 0.5f, 1.0f}
#define MKL_COLOR_TEAL_6        (MKLColor){0.0f, 0.3f, 0.6f, 1.0f}
#define MKL_COLOR_TEAL_7        (MKLColor){0.0f, 0.35f, 0.7f, 1.0f}
#define MKL_COLOR_TEAL_8        (MKLColor){0.0f, 0.4f, 0.8f, 1.0f}
#define MKL_COLOR_TEAL_9        (MKLColor){0.0f, 0.45f, 0.9f, 1.0f}
#define MKL_COLOR_TEAL_10       (MKLColor){0.0f, 0.5f, 1.0f, 1.0f}

// Lime scale colors
#define MKL_COLOR_LIME_0        (MKLColor){0.0f, 0.0f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_1        (MKLColor){0.05f, 0.1f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_2        (MKLColor){0.1f, 0.2f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_3        (MKLColor){0.15f, 0.3f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_4        (MKLColor){0.2f, 0.4f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_5        (MKLColor){0.25f, 0.5f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_6        (MKLColor){0.3f, 0.6f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_7        (MKLColor){0.35f, 0.7f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_8        (MKLColor){0.4f, 0.8f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_9        (MKLColor){0.45f, 0.9f, 0.0f, 1.0f}
#define MKL_COLOR_LIME_10       (MKLColor){0.5f, 1.0f, 0.0f, 1.0f}

#endif // _MKL_COLOR_H_