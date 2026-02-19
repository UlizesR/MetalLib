#ifndef GULI_TEXTURE_H
#define GULI_TEXTURE_H

#include "Core/guli_core.h"
#include <stddef.h>

/** Texture handle. _backend is GLuint (OpenGL) or id<MTLTexture> (Metal), stored as void*. */
struct GuliTexture {
    void* _backend;
    int width;
    int height;
};
typedef struct GuliTexture GuliTexture;

/** Create texture from RGBA pixel data (row-major, 4 bytes per pixel). */
GuliTexture* GuliTextureCreateFromPixels(int width, int height, const unsigned char* pixels);

/** Load texture from file (PNG, JPG, BMP, TGA, etc. via stb_image). Returns NULL on failure. */
GuliTexture* GuliTextureLoadFromFile(const char* path);

/** Unload texture and free resources. */
void GuliTextureUnload(GuliTexture* texture);

/** Get texture dimensions. Returns 0 if texture is NULL. */
void GuliTextureGetSize(const GuliTexture* texture, int* width, int* height);

/** Check if texture is valid (non-NULL and loaded). */
int GuliTextureIsValid(const GuliTexture* texture);

_Static_assert(sizeof(GuliTexture) >= 12, "GuliTexture must hold backend ptr and dimensions");
_Static_assert(offsetof(GuliTexture, width) >= sizeof(void*), "GuliTexture layout");

#endif /* GULI_TEXTURE_H */
