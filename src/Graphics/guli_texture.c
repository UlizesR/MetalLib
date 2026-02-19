#include "Graphics/guli_texture.h"
#include "Core/guli_image.h"
#include "Core/guli_core.h"

#include <stdlib.h>

#ifdef GULI_BACKEND_METAL
extern GuliTexture* MetalTextureCreateFromPixels(int width, int height, const unsigned char* pixels);
extern void MetalTextureUnload(GuliTexture* texture);
#endif

#ifdef GULI_BACKEND_OPENGL
extern GuliTexture* GlTextureCreateFromPixels(int width, int height, const unsigned char* pixels);
extern void GlTextureUnload(GuliTexture* texture);
#endif

GuliTexture* GuliTextureCreateFromPixels(int width, int height, const unsigned char* pixels)
{
    if (width <= 0 || height <= 0) return NULL;

#ifdef GULI_BACKEND_METAL
    return MetalTextureCreateFromPixels(width, height, pixels);
#endif

#ifdef GULI_BACKEND_OPENGL
    return GlTextureCreateFromPixels(width, height, pixels);
#endif

    (void)pixels;
    return NULL;
}

GuliTexture* GuliTextureLoadFromFile(const char* path)
{
    if (!path) return NULL;

    GuliImage img = GuliImageLoadFromFile(path);
    if (!img.data || img.width <= 0 || img.height <= 0)
    {
        GuliImageFree(&img);
        return NULL;
    }

    GuliTexture* tex = GuliTextureCreateFromPixels(img.width, img.height, img.data);
    GuliImageFree(&img);
    return tex;
}

void GuliTextureUnload(GuliTexture* texture)
{
    if (!texture) return;

#ifdef GULI_BACKEND_METAL
    MetalTextureUnload(texture);
#endif

#ifdef GULI_BACKEND_OPENGL
    GlTextureUnload(texture);
#endif

    free(texture);
}

void GuliTextureGetSize(const GuliTexture* texture, int* width, int* height)
{
    if (width) *width = texture ? texture->width : 0;
    if (height) *height = texture ? texture->height : 0;
}

int GuliTextureIsValid(const GuliTexture* texture)
{
    return (texture && texture->_backend) ? 1 : 0;
}
