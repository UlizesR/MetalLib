#ifndef MAC_PIXELS_H_
#define MAC_PIXELS_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct 
{
    int x;
    int y;
} MAC_Point;

typedef struct 
{
    float x;
    float y;
} MAC_FPoint;

typedef struct 
{
    float r;
    float g;
    float b;
    float a;
} MAC_Color;

// Basic colors
#define MAC_COLOR_TRANSPARENT   (MAC_Color){0.0f, 0.0f, 0.0f, 0.0f}
#define MAC_COLOR_WHITE         (MAC_Color){1.0f, 1.0f, 1.0f, 1.0f}
#define MAC_COLOR_BLACK         (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED           (MAC_Color){1.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN         (MAC_Color){0.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_BLUE          (MAC_Color){0.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_YELLOW        (MAC_Color){1.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_MAGENTA       (MAC_Color){1.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_CYAN          (MAC_Color){0.0f, 1.0f, 1.0f, 1.0f}

// Grayscale colors
#define MAC_COLOR_GRAY_0        (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GRAY_1        (MAC_Color){0.1f, 0.1f, 0.1f, 1.0f}
#define MAC_COLOR_GRAY_2        (MAC_Color){0.2f, 0.2f, 0.2f, 1.0f}
#define MAC_COLOR_GRAY_3        (MAC_Color){0.3f, 0.3f, 0.3f, 1.0f}
#define MAC_COLOR_GRAY_4        (MAC_Color){0.4f, 0.4f, 0.4f, 1.0f}
#define MAC_COLOR_GRAY_5        (MAC_Color){0.5f, 0.5f, 0.5f, 1.0f}
#define MAC_COLOR_GRAY_6        (MAC_Color){0.6f, 0.6f, 0.6f, 1.0f}
#define MAC_COLOR_GRAY_7        (MAC_Color){0.7f, 0.7f, 0.7f, 1.0f}
#define MAC_COLOR_GRAY_8        (MAC_Color){0.8f, 0.8f, 0.8f, 1.0f}
#define MAC_COLOR_GRAY_9        (MAC_Color){0.9f, 0.9f, 0.9f, 1.0f}
#define MAC_COLOR_GRAY_10       (MAC_Color){1.0f, 1.0f, 1.0f, 1.0f}

// Redscale colors
#define MAC_COLOR_RED_0         (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_1         (MAC_Color){0.1f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_2         (MAC_Color){0.2f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_3         (MAC_Color){0.3f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_4         (MAC_Color){0.4f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_5         (MAC_Color){0.5f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_6         (MAC_Color){0.6f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_7         (MAC_Color){0.7f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_8         (MAC_Color){0.8f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_9         (MAC_Color){0.9f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED_10        (MAC_Color){1.0f, 0.0f, 0.0f, 1.0f}

// Greenscale colors
#define MAC_COLOR_GREEN_0       (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_1       (MAC_Color){0.0f, 0.1f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_2       (MAC_Color){0.0f, 0.2f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_3       (MAC_Color){0.0f, 0.3f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_4       (MAC_Color){0.0f, 0.4f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_5       (MAC_Color){0.0f, 0.5f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_6       (MAC_Color){0.0f, 0.6f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_7       (MAC_Color){0.0f, 0.7f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_8       (MAC_Color){0.0f, 0.8f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_9       (MAC_Color){0.0f, 0.9f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN_10      (MAC_Color){0.0f, 1.0f, 0.0f, 1.0f}

// Bluescale colors
#define MAC_COLOR_BLUE_0        (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_BLUE_1        (MAC_Color){0.0f, 0.0f, 0.1f, 1.0f}
#define MAC_COLOR_BLUE_2        (MAC_Color){0.0f, 0.0f, 0.2f, 1.0f}
#define MAC_COLOR_BLUE_3        (MAC_Color){0.0f, 0.0f, 0.3f, 1.0f}
#define MAC_COLOR_BLUE_4        (MAC_Color){0.0f, 0.0f, 0.4f, 1.0f}
#define MAC_COLOR_BLUE_5        (MAC_Color){0.0f, 0.0f, 0.5f, 1.0f}
#define MAC_COLOR_BLUE_6        (MAC_Color){0.0f, 0.0f, 0.6f, 1.0f}
#define MAC_COLOR_BLUE_7        (MAC_Color){0.0f, 0.0f, 0.7f, 1.0f}
#define MAC_COLOR_BLUE_8        (MAC_Color){0.0f, 0.0f, 0.8f, 1.0f}
#define MAC_COLOR_BLUE_9        (MAC_Color){0.0f, 0.0f, 0.9f, 1.0f}
#define MAC_COLOR_BLUE_10       (MAC_Color){0.0f, 0.0f, 1.0f, 1.0f}

// Yellowscale colors
#define MAC_COLOR_YELLOW_0      (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_1      (MAC_Color){0.1f, 0.1f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_2      (MAC_Color){0.2f, 0.2f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_3      (MAC_Color){0.3f, 0.3f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_4      (MAC_Color){0.4f, 0.4f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_5      (MAC_Color){0.5f, 0.5f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_6      (MAC_Color){0.6f, 0.6f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_7      (MAC_Color){0.7f, 0.7f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_8      (MAC_Color){0.8f, 0.8f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_9      (MAC_Color){0.9f, 0.9f, 0.0f, 1.0f}
#define MAC_COLOR_YELLOW_10     (MAC_Color){1.0f, 1.0f, 0.0f, 1.0f}

// Magentascale colors
#define MAC_COLOR_MAGENTA_0     (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_MAGENTA_1     (MAC_Color){0.1f, 0.0f, 0.1f, 1.0f}
#define MAC_COLOR_MAGENTA_2     (MAC_Color){0.2f, 0.0f, 0.2f, 1.0f}
#define MAC_COLOR_MAGENTA_3     (MAC_Color){0.3f, 0.0f, 0.3f, 1.0f}
#define MAC_COLOR_MAGENTA_4     (MAC_Color){0.4f, 0.0f, 0.4f, 1.0f}
#define MAC_COLOR_MAGENTA_5     (MAC_Color){0.5f, 0.0f, 0.5f, 1.0f}
#define MAC_COLOR_MAGENTA_6     (MAC_Color){0.6f, 0.0f, 0.6f, 1.0f}
#define MAC_COLOR_MAGENTA_7     (MAC_Color){0.7f, 0.0f, 0.7f, 1.0f}
#define MAC_COLOR_MAGENTA_8     (MAC_Color){0.8f, 0.0f, 0.8f, 1.0f}
#define MAC_COLOR_MAGENTA_9     (MAC_Color){0.9f, 0.0f, 0.9f, 1.0f}
#define MAC_COLOR_MAGENTA_10    (MAC_Color){1.0f, 0.0f, 1.0f, 1.0f}

// Cyanscale colors
#define MAC_COLOR_CYAN_0        (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_CYAN_1        (MAC_Color){0.0f, 0.1f, 0.1f, 1.0f}
#define MAC_COLOR_CYAN_2        (MAC_Color){0.0f, 0.2f, 0.2f, 1.0f}
#define MAC_COLOR_CYAN_3        (MAC_Color){0.0f, 0.3f, 0.3f, 1.0f}
#define MAC_COLOR_CYAN_4        (MAC_Color){0.0f, 0.4f, 0.4f, 1.0f}
#define MAC_COLOR_CYAN_5        (MAC_Color){0.0f, 0.5f, 0.5f, 1.0f}
#define MAC_COLOR_CYAN_6        (MAC_Color){0.0f, 0.6f, 0.6f, 1.0f}
#define MAC_COLOR_CYAN_7        (MAC_Color){0.0f, 0.7f, 0.7f, 1.0f}
#define MAC_COLOR_CYAN_8        (MAC_Color){0.0f, 0.8f, 0.8f, 1.0f}
#define MAC_COLOR_CYAN_9        (MAC_Color){0.0f, 0.9f, 0.9f, 1.0f}
#define MAC_COLOR_CYAN_10       (MAC_Color){0.0f, 1.0f, 1.0f, 1.0f}



#ifdef __cplusplus
}
#endif

#endif // MAC_PIXELS_H_