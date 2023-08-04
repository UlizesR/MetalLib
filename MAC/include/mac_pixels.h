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

#define MAC_COLOR_TRANSPARENT   (MAC_Color){0.0f, 0.0f, 0.0f, 0.0f}
#define MAC_COLOR_WHITE         (MAC_Color){1.0f, 1.0f, 1.0f, 1.0f}
#define MAC_COLOR_BLACK         (MAC_Color){0.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_RED           (MAC_Color){1.0f, 0.0f, 0.0f, 1.0f}
#define MAC_COLOR_GREEN         (MAC_Color){0.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_BLUE          (MAC_Color){0.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_YELLOW        (MAC_Color){1.0f, 1.0f, 0.0f, 1.0f}
#define MAC_COLOR_MAGENTA       (MAC_Color){1.0f, 0.0f, 1.0f, 1.0f}
#define MAC_COLOR_CYAN          (MAC_Color){0.0f, 1.0f, 1.0f, 1.0f}

#ifdef __cplusplus
}
#endif

#endif // MAC_PIXELS_H_