#ifndef _mcl_colors_h_
#define _mcl_colors_h_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_Color
{
    float r;
    float g;
    float b;
    float a;
} MCL_Color;


// Basic colors
#define MCL_COLOR_TRANSPARENT   (MCL_Color){0.0f, 0.0f, 0.0f, 0.0f}
#define MCL_COLOR_WHITE         (MCL_Color){1.0f, 1.0f, 1.0f, 1.0f}
#define MCL_COLOR_BLACK         (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED           (MCL_Color){1.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN         (MCL_Color){0.0f, 1.0f, 0.0f, 1.0f}
#define MCL_COLOR_BLUE          (MCL_Color){0.0f, 0.0f, 1.0f, 1.0f}
#define MCL_COLOR_YELLOW        (MCL_Color){1.0f, 1.0f, 0.0f, 1.0f}
#define MCL_COLOR_MAGENTA       (MCL_Color){1.0f, 0.0f, 1.0f, 1.0f}
#define MCL_COLOR_CYAN          (MCL_Color){0.0f, 1.0f, 1.0f, 1.0f}

// Grayscale colors
#define MCL_COLOR_GRAY_0        (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_GRAY_1        (MCL_Color){0.1f, 0.1f, 0.1f, 1.0f}
#define MCL_COLOR_GRAY_2        (MCL_Color){0.2f, 0.2f, 0.2f, 1.0f}
#define MCL_COLOR_GRAY_3        (MCL_Color){0.3f, 0.3f, 0.3f, 1.0f}
#define MCL_COLOR_GRAY_4        (MCL_Color){0.4f, 0.4f, 0.4f, 1.0f}
#define MCL_COLOR_GRAY_5        (MCL_Color){0.5f, 0.5f, 0.5f, 1.0f}
#define MCL_COLOR_GRAY_6        (MCL_Color){0.6f, 0.6f, 0.6f, 1.0f}
#define MCL_COLOR_GRAY_7        (MCL_Color){0.7f, 0.7f, 0.7f, 1.0f}
#define MCL_COLOR_GRAY_8        (MCL_Color){0.8f, 0.8f, 0.8f, 1.0f}
#define MCL_COLOR_GRAY_9        (MCL_Color){0.9f, 0.9f, 0.9f, 1.0f}
#define MCL_COLOR_GRAY_10       (MCL_Color){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define MCL_COLOR_RED_0         (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_1         (MCL_Color){0.1f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_2         (MCL_Color){0.2f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_3         (MCL_Color){0.3f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_4         (MCL_Color){0.4f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_5         (MCL_Color){0.5f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_6         (MCL_Color){0.6f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_7         (MCL_Color){0.7f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_8         (MCL_Color){0.8f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_9         (MCL_Color){0.9f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_RED_10        (MCL_Color){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define MCL_COLOR_GREEN_0       (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_1       (MCL_Color){0.0f, 0.1f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_2       (MCL_Color){0.0f, 0.2f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_3       (MCL_Color){0.0f, 0.3f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_4       (MCL_Color){0.0f, 0.4f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_5       (MCL_Color){0.0f, 0.5f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_6       (MCL_Color){0.0f, 0.6f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_7       (MCL_Color){0.0f, 0.7f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_8       (MCL_Color){0.0f, 0.8f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_9       (MCL_Color){0.0f, 0.9f, 0.0f, 1.0f}
#define MCL_COLOR_GREEN_10      (MCL_Color){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define MCL_COLOR_BLUE_0        (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_BLUE_1        (MCL_Color){0.0f, 0.0f, 0.1f, 1.0f}
#define MCL_COLOR_BLUE_2        (MCL_Color){0.0f, 0.0f, 0.2f, 1.0f}
#define MCL_COLOR_BLUE_3        (MCL_Color){0.0f, 0.0f, 0.3f, 1.0f}
#define MCL_COLOR_BLUE_4        (MCL_Color){0.0f, 0.0f, 0.4f, 1.0f}
#define MCL_COLOR_BLUE_5        (MCL_Color){0.0f, 0.0f, 0.5f, 1.0f}
#define MCL_COLOR_BLUE_6        (MCL_Color){0.0f, 0.0f, 0.6f, 1.0f}
#define MCL_COLOR_BLUE_7        (MCL_Color){0.0f, 0.0f, 0.7f, 1.0f}
#define MCL_COLOR_BLUE_8        (MCL_Color){0.0f, 0.0f, 0.8f, 1.0f}
#define MCL_COLOR_BLUE_9        (MCL_Color){0.0f, 0.0f, 0.9f, 1.0f}
#define MCL_COLOR_BLUE_10       (MCL_Color){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define MCL_COLOR_YELLOW_0      (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_1      (MCL_Color){0.1f, 0.1f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_2      (MCL_Color){0.2f, 0.2f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_3      (MCL_Color){0.3f, 0.3f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_4      (MCL_Color){0.4f, 0.4f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_5      (MCL_Color){0.5f, 0.5f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_6      (MCL_Color){0.6f, 0.6f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_7      (MCL_Color){0.7f, 0.7f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_8      (MCL_Color){0.8f, 0.8f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_9      (MCL_Color){0.9f, 0.9f, 0.0f, 1.0f}
#define MCL_COLOR_YELLOW_10     (MCL_Color){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define MCL_COLOR_MAGENTA_0     (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_MAGENTA_1     (MCL_Color){0.1f, 0.0f, 0.1f, 1.0f}
#define MCL_COLOR_MAGENTA_2     (MCL_Color){0.2f, 0.0f, 0.2f, 1.0f}
#define MCL_COLOR_MAGENTA_3     (MCL_Color){0.3f, 0.0f, 0.3f, 1.0f}
#define MCL_COLOR_MAGENTA_4     (MCL_Color){0.4f, 0.0f, 0.4f, 1.0f}
#define MCL_COLOR_MAGENTA_5     (MCL_Color){0.5f, 0.0f, 0.5f, 1.0f}
#define MCL_COLOR_MAGENTA_6     (MCL_Color){0.6f, 0.0f, 0.6f, 1.0f}
#define MCL_COLOR_MAGENTA_7     (MCL_Color){0.7f, 0.0f, 0.7f, 1.0f}
#define MCL_COLOR_MAGENTA_8     (MCL_Color){0.8f, 0.0f, 0.8f, 1.0f}
#define MCL_COLOR_MAGENTA_9     (MCL_Color){0.9f, 0.0f, 0.9f, 1.0f}
#define MCL_COLOR_MAGENTA_10    (MCL_Color){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define MCL_COLOR_CYAN_0        (MCL_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MCL_COLOR_CYAN_1        (MCL_Color){0.0f, 0.1f, 0.1f, 1.0f}
#define MCL_COLOR_CYAN_2        (MCL_Color){0.0f, 0.2f, 0.2f, 1.0f}
#define MCL_COLOR_CYAN_3        (MCL_Color){0.0f, 0.3f, 0.3f, 1.0f}
#define MCL_COLOR_CYAN_4        (MCL_Color){0.0f, 0.4f, 0.4f, 1.0f}
#define MCL_COLOR_CYAN_5        (MCL_Color){0.0f, 0.5f, 0.5f, 1.0f}
#define MCL_COLOR_CYAN_6        (MCL_Color){0.0f, 0.6f, 0.6f, 1.0f}
#define MCL_COLOR_CYAN_7        (MCL_Color){0.0f, 0.7f, 0.7f, 1.0f}
#define MCL_COLOR_CYAN_8        (MCL_Color){0.0f, 0.8f, 0.8f, 1.0f}
#define MCL_COLOR_CYAN_9        (MCL_Color){0.0f, 0.9f, 0.9f, 1.0f}
#define MCL_COLOR_CYAN_10       (MCL_Color){0.0f, 1.0f, 1.0f, 1.0f}

#ifdef __cplusplus
}
#endif

#endif // _mcl_colors_h_