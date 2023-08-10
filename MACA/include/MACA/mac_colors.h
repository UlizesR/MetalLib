#ifndef mac_colors_h_
#define mac_colors_h_


#ifdef __cplusplus
extern "C" {
#endif

typedef struct Mac_Color
{
    float r;
    float g;
    float b;
    float a;
} Mac_Color;


// Basic colors
#define MAC_COLOR_TRANSPARENT   (Mac_Color){0.0f, 0.0f, 0.0f, 0.0f}
#define MAC_COLOR_WHITE         (Mac_Color){1.0f, 1.0f, 1.0f, 1.0f}
#define MAC_COLOR_BLACK         (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED           (Mac_Color){1.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN         (Mac_Color){0.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_BLUE          (Mac_Color){0.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_YELLOW        (Mac_Color){1.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_MAGENTA       (Mac_Color){1.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_CYAN          (Mac_Color){0.0f, 1.0f, 1.0f, 1.0f}

// Grayscale colors
#define MAC_COLOR_GRAY_0        (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GRAY_1        (Mac_Color){0.1f, 0.1f, 0.1f, 1.0f}
#define MAC_COLOR_GRAY_2        (Mac_Color){0.2f, 0.2f, 0.2f, 1.0f}
#define MAC_COLOR_GRAY_3        (Mac_Color){0.3f, 0.3f, 0.3f, 1.0f}
#define MAC_COLOR_GRAY_4        (Mac_Color){0.4f, 0.4f, 0.4f, 1.0f}
#define MAC_COLOR_GRAY_5        (Mac_Color){0.5f, 0.5f, 0.5f, 1.0f}
#define MAC_COLOR_GRAY_6        (Mac_Color){0.6f, 0.6f, 0.6f, 1.0f}
#define MAC_COLOR_GRAY_7        (Mac_Color){0.7f, 0.7f, 0.7f, 1.0f}
#define MAC_COLOR_GRAY_8        (Mac_Color){0.8f, 0.8f, 0.8f, 1.0f}
#define MAC_COLOR_GRAY_9        (Mac_Color){0.9f, 0.9f, 0.9f, 1.0f}
#define MAC_COLOR_GRAY_10       (Mac_Color){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define MAC_COLOR_RED_0         (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_1         (Mac_Color){0.1f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_2         (Mac_Color){0.2f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_3         (Mac_Color){0.3f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_4         (Mac_Color){0.4f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_5         (Mac_Color){0.5f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_6         (Mac_Color){0.6f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_7         (Mac_Color){0.7f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_8         (Mac_Color){0.8f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_9         (Mac_Color){0.9f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_10        (Mac_Color){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define MAC_COLOR_GREEN_0       (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_1       (Mac_Color){0.0f, 0.1f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_2       (Mac_Color){0.0f, 0.2f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_3       (Mac_Color){0.0f, 0.3f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_4       (Mac_Color){0.0f, 0.4f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_5       (Mac_Color){0.0f, 0.5f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_6       (Mac_Color){0.0f, 0.6f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_7       (Mac_Color){0.0f, 0.7f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_8       (Mac_Color){0.0f, 0.8f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_9       (Mac_Color){0.0f, 0.9f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_10      (Mac_Color){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define MAC_COLOR_BLUE_0        (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_BLUE_1        (Mac_Color){0.0f, 0.0f, 0.1f, 1.0f}
#define MAC_COLOR_BLUE_2        (Mac_Color){0.0f, 0.0f, 0.2f, 1.0f}
#define MAC_COLOR_BLUE_3        (Mac_Color){0.0f, 0.0f, 0.3f, 1.0f}
#define MAC_COLOR_BLUE_4        (Mac_Color){0.0f, 0.0f, 0.4f, 1.0f}
#define MAC_COLOR_BLUE_5        (Mac_Color){0.0f, 0.0f, 0.5f, 1.0f}
#define MAC_COLOR_BLUE_6        (Mac_Color){0.0f, 0.0f, 0.6f, 1.0f}
#define MAC_COLOR_BLUE_7        (Mac_Color){0.0f, 0.0f, 0.7f, 1.0f}
#define MAC_COLOR_BLUE_8        (Mac_Color){0.0f, 0.0f, 0.8f, 1.0f}
#define MAC_COLOR_BLUE_9        (Mac_Color){0.0f, 0.0f, 0.9f, 1.0f}
#define MAC_COLOR_BLUE_10       (Mac_Color){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define MAC_COLOR_YELLOW_0      (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_1      (Mac_Color){0.1f, 0.1f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_2      (Mac_Color){0.2f, 0.2f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_3      (Mac_Color){0.3f, 0.3f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_4      (Mac_Color){0.4f, 0.4f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_5      (Mac_Color){0.5f, 0.5f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_6      (Mac_Color){0.6f, 0.6f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_7      (Mac_Color){0.7f, 0.7f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_8      (Mac_Color){0.8f, 0.8f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_9      (Mac_Color){0.9f, 0.9f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_10     (Mac_Color){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define MAC_COLOR_MAGENTA_0     (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_MAGENTA_1     (Mac_Color){0.1f, 0.0f, 0.1f, 1.0f}
#define MAC_COLOR_MAGENTA_2     (Mac_Color){0.2f, 0.0f, 0.2f, 1.0f}
#define MAC_COLOR_MAGENTA_3     (Mac_Color){0.3f, 0.0f, 0.3f, 1.0f}
#define MAC_COLOR_MAGENTA_4     (Mac_Color){0.4f, 0.0f, 0.4f, 1.0f}
#define MAC_COLOR_MAGENTA_5     (Mac_Color){0.5f, 0.0f, 0.5f, 1.0f}
#define MAC_COLOR_MAGENTA_6     (Mac_Color){0.6f, 0.0f, 0.6f, 1.0f}
#define MAC_COLOR_MAGENTA_7     (Mac_Color){0.7f, 0.0f, 0.7f, 1.0f}
#define MAC_COLOR_MAGENTA_8     (Mac_Color){0.8f, 0.0f, 0.8f, 1.0f}
#define MAC_COLOR_MAGENTA_9     (Mac_Color){0.9f, 0.0f, 0.9f, 1.0f}
#define MAC_COLOR_MAGENTA_10    (Mac_Color){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define MAC_COLOR_CYAN_0        (Mac_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_CYAN_1        (Mac_Color){0.0f, 0.1f, 0.1f, 1.0f}
#define MAC_COLOR_CYAN_2        (Mac_Color){0.0f, 0.2f, 0.2f, 1.0f}
#define MAC_COLOR_CYAN_3        (Mac_Color){0.0f, 0.3f, 0.3f, 1.0f}
#define MAC_COLOR_CYAN_4        (Mac_Color){0.0f, 0.4f, 0.4f, 1.0f}
#define MAC_COLOR_CYAN_5        (Mac_Color){0.0f, 0.5f, 0.5f, 1.0f}
#define MAC_COLOR_CYAN_6        (Mac_Color){0.0f, 0.6f, 0.6f, 1.0f}
#define MAC_COLOR_CYAN_7        (Mac_Color){0.0f, 0.7f, 0.7f, 1.0f}
#define MAC_COLOR_CYAN_8        (Mac_Color){0.0f, 0.8f, 0.8f, 1.0f}
#define MAC_COLOR_CYAN_9        (Mac_Color){0.0f, 0.9f, 0.9f, 1.0f}
#define MAC_COLOR_CYAN_10       (Mac_Color){0.0f, 1.0f, 1.0f, 1.0f}

#ifdef __cplusplus
}
#endif

#endif // mac_colors_h_