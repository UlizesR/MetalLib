#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M_Color
{
    float r;
    float g;
    float b;
    float a;
} M_Color;


// Basic colors
#define M_COLOR_TRANSPARENT   (M_Color){0.0f, 0.0f, 0.0f, 0.0f}
#define M_COLOR_WHITE         (M_Color){1.0f, 1.0f, 1.0f, 1.0f}
#define M_COLOR_BLACK         (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED           (M_Color){1.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GREEN         (M_Color){0.0f, 1.0f, 0.0f, 1.0f}
#define M_COLOR_BLUE          (M_Color){0.0f, 0.0f, 1.0f, 1.0f}
#define M_COLOR_YELLOW        (M_Color){1.0f, 1.0f, 0.0f, 1.0f}
#define M_COLOR_MAGENTA       (M_Color){1.0f, 0.0f, 1.0f, 1.0f}
#define M_COLOR_CYAN          (M_Color){0.0f, 1.0f, 1.0f, 1.0f}

// Grayscale colors
#define M_COLOR_GRAY_0        (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GRAY_1        (M_Color){0.1f, 0.1f, 0.1f, 1.0f}
#define M_COLOR_GRAY_2        (M_Color){0.2f, 0.2f, 0.2f, 1.0f}
#define M_COLOR_GRAY_3        (M_Color){0.3f, 0.3f, 0.3f, 1.0f}
#define M_COLOR_GRAY_4        (M_Color){0.4f, 0.4f, 0.4f, 1.0f}
#define M_COLOR_GRAY_5        (M_Color){0.5f, 0.5f, 0.5f, 1.0f}
#define M_COLOR_GRAY_6        (M_Color){0.6f, 0.6f, 0.6f, 1.0f}
#define M_COLOR_GRAY_7        (M_Color){0.7f, 0.7f, 0.7f, 1.0f}
#define M_COLOR_GRAY_8        (M_Color){0.8f, 0.8f, 0.8f, 1.0f}
#define M_COLOR_GRAY_9        (M_Color){0.9f, 0.9f, 0.9f, 1.0f}
#define M_COLOR_GRAY_10       (M_Color){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define M_COLOR_RED_0         (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_1         (M_Color){0.1f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_2         (M_Color){0.2f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_3         (M_Color){0.3f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_4         (M_Color){0.4f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_5         (M_Color){0.5f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_6         (M_Color){0.6f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_7         (M_Color){0.7f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_8         (M_Color){0.8f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_9         (M_Color){0.9f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_RED_10        (M_Color){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define M_COLOR_GREEN_0       (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_GREEN_1       (M_Color){0.0f, 0.1f, 0.0f, 1.0f}
#define M_COLOR_GREEN_2       (M_Color){0.0f, 0.2f, 0.0f, 1.0f}
#define M_COLOR_GREEN_3       (M_Color){0.0f, 0.3f, 0.0f, 1.0f}
#define M_COLOR_GREEN_4       (M_Color){0.0f, 0.4f, 0.0f, 1.0f}
#define M_COLOR_GREEN_5       (M_Color){0.0f, 0.5f, 0.0f, 1.0f}
#define M_COLOR_GREEN_6       (M_Color){0.0f, 0.6f, 0.0f, 1.0f}
#define M_COLOR_GREEN_7       (M_Color){0.0f, 0.7f, 0.0f, 1.0f}
#define M_COLOR_GREEN_8       (M_Color){0.0f, 0.8f, 0.0f, 1.0f}
#define M_COLOR_GREEN_9       (M_Color){0.0f, 0.9f, 0.0f, 1.0f}
#define M_COLOR_GREEN_10      (M_Color){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define M_COLOR_BLUE_0        (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_BLUE_1        (M_Color){0.0f, 0.0f, 0.1f, 1.0f}
#define M_COLOR_BLUE_2        (M_Color){0.0f, 0.0f, 0.2f, 1.0f}
#define M_COLOR_BLUE_3        (M_Color){0.0f, 0.0f, 0.3f, 1.0f}
#define M_COLOR_BLUE_4        (M_Color){0.0f, 0.0f, 0.4f, 1.0f}
#define M_COLOR_BLUE_5        (M_Color){0.0f, 0.0f, 0.5f, 1.0f}
#define M_COLOR_BLUE_6        (M_Color){0.0f, 0.0f, 0.6f, 1.0f}
#define M_COLOR_BLUE_7        (M_Color){0.0f, 0.0f, 0.7f, 1.0f}
#define M_COLOR_BLUE_8        (M_Color){0.0f, 0.0f, 0.8f, 1.0f}
#define M_COLOR_BLUE_9        (M_Color){0.0f, 0.0f, 0.9f, 1.0f}
#define M_COLOR_BLUE_10       (M_Color){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define M_COLOR_YELLOW_0      (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_1      (M_Color){0.1f, 0.1f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_2      (M_Color){0.2f, 0.2f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_3      (M_Color){0.3f, 0.3f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_4      (M_Color){0.4f, 0.4f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_5      (M_Color){0.5f, 0.5f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_6      (M_Color){0.6f, 0.6f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_7      (M_Color){0.7f, 0.7f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_8      (M_Color){0.8f, 0.8f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_9      (M_Color){0.9f, 0.9f, 0.0f, 1.0f}
#define M_COLOR_YELLOW_10     (M_Color){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define M_COLOR_MAGENTA_0     (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_MAGENTA_1     (M_Color){0.1f, 0.0f, 0.1f, 1.0f}
#define M_COLOR_MAGENTA_2     (M_Color){0.2f, 0.0f, 0.2f, 1.0f}
#define M_COLOR_MAGENTA_3     (M_Color){0.3f, 0.0f, 0.3f, 1.0f}
#define M_COLOR_MAGENTA_4     (M_Color){0.4f, 0.0f, 0.4f, 1.0f}
#define M_COLOR_MAGENTA_5     (M_Color){0.5f, 0.0f, 0.5f, 1.0f}
#define M_COLOR_MAGENTA_6     (M_Color){0.6f, 0.0f, 0.6f, 1.0f}
#define M_COLOR_MAGENTA_7     (M_Color){0.7f, 0.0f, 0.7f, 1.0f}
#define M_COLOR_MAGENTA_8     (M_Color){0.8f, 0.0f, 0.8f, 1.0f}
#define M_COLOR_MAGENTA_9     (M_Color){0.9f, 0.0f, 0.9f, 1.0f}
#define M_COLOR_MAGENTA_10    (M_Color){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define M_COLOR_CYAN_0        (M_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define M_COLOR_CYAN_1        (M_Color){0.0f, 0.1f, 0.1f, 1.0f}
#define M_COLOR_CYAN_2        (M_Color){0.0f, 0.2f, 0.2f, 1.0f}
#define M_COLOR_CYAN_3        (M_Color){0.0f, 0.3f, 0.3f, 1.0f}
#define M_COLOR_CYAN_4        (M_Color){0.0f, 0.4f, 0.4f, 1.0f}
#define M_COLOR_CYAN_5        (M_Color){0.0f, 0.5f, 0.5f, 1.0f}
#define M_COLOR_CYAN_6        (M_Color){0.0f, 0.6f, 0.6f, 1.0f}
#define M_COLOR_CYAN_7        (M_Color){0.0f, 0.7f, 0.7f, 1.0f}
#define M_COLOR_CYAN_8        (M_Color){0.0f, 0.8f, 0.8f, 1.0f}
#define M_COLOR_CYAN_9        (M_Color){0.0f, 0.9f, 0.9f, 1.0f}
#define M_COLOR_CYAN_10       (M_Color){0.0f, 1.0f, 1.0f, 1.0f}

#ifdef __cplusplus
}
#endif
