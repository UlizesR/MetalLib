#import "Graphics/Metal/guli_metal.h"
#import "Graphics/guli_texture.h"

#include <stdlib.h>

/* -----------------------------------------------------------------------------
 * Metal texture backend
 * ----------------------------------------------------------------------------- */

GuliTexture* MetalTextureCreateFromPixels(int width, int height, const unsigned char* pixels)
{
    if (width <= 0 || height <= 0) return NULL;

    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_device) return NULL;

    MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                    width:(NSUInteger)width
                                                                                   height:(NSUInteger)height
                                                                                mipmapped:NO];
    desc.usage = MTLTextureUsageShaderRead;
    desc.storageMode = MTLStorageModeShared;

    id<MTLTexture> mtlTex = [m->_device newTextureWithDescriptor:desc];
    if (!mtlTex) return NULL;

    if (pixels)
    {
        MTLRegion region = MTLRegionMake2D(0, 0, (NSUInteger)width, (NSUInteger)height);
        NSUInteger bytesPerRow = (NSUInteger)width * 4;
        [mtlTex replaceRegion:region mipmapLevel:0 withBytes:pixels bytesPerRow:bytesPerRow];
    }

    GuliTexture* tex = (GuliTexture*)calloc(1, sizeof(GuliTexture));
    if (!tex)
    {
        return NULL;
    }
    tex->_backend = (__bridge void*)mtlTex;
    tex->width = width;
    tex->height = height;
    return tex;
}

void MetalTextureUnload(GuliTexture* texture)
{
    if (!texture) return;
    if (texture->_backend)
    {
        id<MTLTexture> mtlTex = (__bridge_transfer id<MTLTexture>)texture->_backend;
        (void)mtlTex; /* ARC releases when we transfer */
        texture->_backend = NULL;
    }
    texture->width = texture->height = 0;
}
