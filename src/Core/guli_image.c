#define STB_IMAGE_IMPLEMENTATION
#include "Core/guli_image.h"
#include <stdlib.h>
#include <string.h>

/* stb_image from assimp - add include path in CMake */
#include <stb_image.h>

GuliImage GuliImageLoadFromFile(const char* path)
{
    GuliImage img = {0};
    if (!path) return img;

    int w = 0, h = 0, ch = 0;
    unsigned char* data = stbi_load(path, &w, &h, &ch, 4);
    if (!data || w <= 0 || h <= 0) return img;

    img.data = data;
    img.width = w;
    img.height = h;
    img.channels = 4;
    return img;
}

void GuliImageFree(GuliImage* img)
{
    if (!img) return;
    if (img->data)
    {
        stbi_image_free(img->data);
        img->data = NULL;
    }
    img->width = img->height = img->channels = 0;
}
