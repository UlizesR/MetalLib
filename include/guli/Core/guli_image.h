#ifndef GULI_IMAGE_H
#define GULI_IMAGE_H

#include "guli_core.h"

/** Image data loaded from file. Free with GuliImageFree. */
typedef struct {
    unsigned char* data;
    int width;
    int height;
    int channels;  /* 1=gray, 2=gray+alpha, 3=RGB, 4=RGBA */
} GuliImage;

/** Load image from file. Returns {0} on failure. Uses stb_image. */
GuliImage GuliImageLoadFromFile(const char* path);

/** Free image data. Safe to call on zero-initialized image. */
void GuliImageFree(GuliImage* img);

#endif /* GULI_IMAGE_H */
