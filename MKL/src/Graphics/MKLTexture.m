//
// MKLTexture.m
// MetalLib - Texture Implementation
//

#import "MKLTexture.h"
#import "MKLRenderer.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// ========== Helper Functions ==========

static MTLPixelFormat MKLTextureFormatToMTL(MKLTextureFormat format) {
    switch (format) {
        case MKL_TEXTURE_FORMAT_RGBA8:      return MTLPixelFormatRGBA8Unorm;
        case MKL_TEXTURE_FORMAT_RGB8:       return MTLPixelFormatRGBA8Unorm; // Metal doesn't have RGB8
        case MKL_TEXTURE_FORMAT_GRAY8:      return MTLPixelFormatR8Unorm;
        case MKL_TEXTURE_FORMAT_RGBA32F:    return MTLPixelFormatRGBA32Float;
        case MKL_TEXTURE_FORMAT_DEPTH32F:   return MTLPixelFormatDepth32Float;
        default:                            return MTLPixelFormatRGBA8Unorm;
    }
}

static MTLSamplerAddressMode MKLTextureWrapToMTL(MKLTextureWrap wrap) {
    switch (wrap) {
        case MKL_TEXTURE_WRAP_REPEAT:           return MTLSamplerAddressModeRepeat;
        case MKL_TEXTURE_WRAP_CLAMP_TO_EDGE:    return MTLSamplerAddressModeClampToEdge;
        case MKL_TEXTURE_WRAP_MIRRORED_REPEAT:  return MTLSamplerAddressModeMirrorRepeat;
        case MKL_TEXTURE_WRAP_CLAMP_TO_ZERO:    return MTLSamplerAddressModeClampToZero;
        default:                                return MTLSamplerAddressModeClampToEdge;
    }
}

static MTLSamplerMinMagFilter MKLTextureFilterToMTL(MKLTextureFilter filter) {
    switch (filter) {
        case MKL_TEXTURE_FILTER_NEAREST:    return MTLSamplerMinMagFilterNearest;
        case MKL_TEXTURE_FILTER_LINEAR:     return MTLSamplerMinMagFilterLinear;
        case MKL_TEXTURE_FILTER_ANISOTROPIC: return MTLSamplerMinMagFilterLinear;
        default:                            return MTLSamplerMinMagFilterLinear;
    }
}

static id<MTLSamplerState> CreateSamplerState(id<MTLDevice> device, MKLTextureConfig config) {
    MTLSamplerDescriptor *desc = [[MTLSamplerDescriptor alloc] init];
    desc.sAddressMode = MKLTextureWrapToMTL(config.wrapS);
    desc.tAddressMode = MKLTextureWrapToMTL(config.wrapT);
    desc.minFilter = MKLTextureFilterToMTL(config.minFilter);
    desc.magFilter = MKLTextureFilterToMTL(config.magFilter);
    desc.mipFilter = config.generateMipmaps ? MTLSamplerMipFilterLinear : MTLSamplerMipFilterNotMipmapped;
    desc.maxAnisotropy = (config.minFilter == MKL_TEXTURE_FILTER_ANISOTROPIC || 
                          config.magFilter == MKL_TEXTURE_FILTER_ANISOTROPIC) ? config.maxAnisotropy : 1;
    desc.normalizedCoordinates = YES;
    
    return [device newSamplerStateWithDescriptor:desc];
}

// ========== Configuration Helpers ==========

MKLTextureConfig MKLGetDefaultTextureConfig(void) {
    return (MKLTextureConfig){
        .wrapS = MKL_TEXTURE_WRAP_REPEAT,
        .wrapT = MKL_TEXTURE_WRAP_REPEAT,
        .minFilter = MKL_TEXTURE_FILTER_LINEAR,
        .magFilter = MKL_TEXTURE_FILTER_LINEAR,
        .generateMipmaps = true,
        .maxAnisotropy = 1
    };
}

MKLTextureConfig MKLGetPixelArtTextureConfig(void) {
    return (MKLTextureConfig){
        .wrapS = MKL_TEXTURE_WRAP_CLAMP_TO_EDGE,
        .wrapT = MKL_TEXTURE_WRAP_CLAMP_TO_EDGE,
        .minFilter = MKL_TEXTURE_FILTER_NEAREST,
        .magFilter = MKL_TEXTURE_FILTER_NEAREST,
        .generateMipmaps = false,
        .maxAnisotropy = 1
    };
}

MKLTextureConfig MKLGetHighQualityTextureConfig(void) {
    return (MKLTextureConfig){
        .wrapS = MKL_TEXTURE_WRAP_REPEAT,
        .wrapT = MKL_TEXTURE_WRAP_REPEAT,
        .minFilter = MKL_TEXTURE_FILTER_ANISOTROPIC,
        .magFilter = MKL_TEXTURE_FILTER_ANISOTROPIC,
        .generateMipmaps = true,
        .maxAnisotropy = 16
    };
}

// ========== Texture Loading Functions ==========

MKLTexture MKLLoadTexture(MKLRenderer *renderer, const char *fileName) {
    return MKLLoadTextureEx(renderer, fileName, MKLGetDefaultTextureConfig());
}

MKLTexture MKLLoadTextureEx(MKLRenderer *renderer, const char *fileName, MKLTextureConfig config) {
    MKLTexture texture = {0};
    texture.valid = false;
    
    if (!renderer || !fileName) {
        return texture;
    }
    
    @autoreleasepool {
        NSString *filePath = [NSString stringWithUTF8String:fileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:renderer->_device];
        
        NSDictionary *options = @{
            MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead),
            MTKTextureLoaderOptionTextureStorageMode: @(MTLStorageModePrivate),
            MTKTextureLoaderOptionGenerateMipmaps: @(config.generateMipmaps),
            MTKTextureLoaderOptionOrigin: MTKTextureLoaderOriginBottomLeft
        };
        
        NSError *error = nil;
        id<MTLTexture> mtlTexture = [loader newTextureWithContentsOfURL:fileURL
                                                                  options:options
                                                                    error:&error];
        
        if (error || !mtlTexture) {
            NSLog(@"Failed to load texture from %s: %@", fileName, error);
            return texture;
        }
        
        texture._texture = mtlTexture;
        texture._sampler = CreateSamplerState(renderer->_device, config);
        texture.width = (int)mtlTexture.width;
        texture.height = (int)mtlTexture.height;
        texture.mipmaps = (int)mtlTexture.mipmapLevelCount;
        texture.format = MKL_TEXTURE_FORMAT_RGBA8; // Assume RGBA8 for loaded images
        texture.valid = true;
    }
    
    return texture;
}

MKLTexture MKLLoadTextureFromMemory(MKLRenderer *renderer, 
                                      const void *data, 
                                      int width, 
                                      int height,
                                      MKLTextureFormat format,
                                      MKLTextureConfig config) {
    MKLTexture texture = {0};
    texture.valid = false;
    
    if (!renderer || !data || width <= 0 || height <= 0) {
        return texture;
    }
    
    @autoreleasepool {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MKLTextureFormatToMTL(format)
                                                                                         width:width
                                                                                        height:height
                                                                                     mipmapped:config.generateMipmaps];
        desc.usage = MTLTextureUsageShaderRead;
        desc.storageMode = MTLStorageModePrivate;
        
        id<MTLTexture> mtlTexture = [renderer->_device newTextureWithDescriptor:desc];
        if (!mtlTexture) {
            return texture;
        }
        
        // Upload data to texture
        MTLRegion region = MTLRegionMake2D(0, 0, width, height);
        NSUInteger bytesPerRow = width * 4; // Assume 4 bytes per pixel for RGBA
        if (format == MKL_TEXTURE_FORMAT_GRAY8) {
            bytesPerRow = width;
        }
        
        // Create temporary buffer for upload
        id<MTLBuffer> uploadBuffer = [renderer->_device newBufferWithBytes:data
                                                                     length:bytesPerRow * height
                                                                    options:MTLResourceStorageModeShared];
        
        // Use blit command encoder to copy to private storage
        id<MTLCommandBuffer> commandBuffer = [renderer->_commandQueue commandBuffer];
        id<MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
        
        [blitEncoder copyFromBuffer:uploadBuffer
                       sourceOffset:0
                  sourceBytesPerRow:bytesPerRow
                sourceBytesPerImage:bytesPerRow * height
                         sourceSize:MTLSizeMake(width, height, 1)
                          toTexture:mtlTexture
                   destinationSlice:0
                   destinationLevel:0
                  destinationOrigin:MTLOriginMake(0, 0, 0)];
        
        [blitEncoder endEncoding];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
        
        texture._texture = mtlTexture;
        texture._sampler = CreateSamplerState(renderer->_device, config);
        texture.width = width;
        texture.height = height;
        texture.mipmaps = config.generateMipmaps ? (int)mtlTexture.mipmapLevelCount : 1;
        texture.format = format;
        texture.valid = true;
    }
    
    return texture;
}

MKLTexture MKLCreateTexture(MKLRenderer *renderer,
                             int width,
                             int height,
                             MKLTextureFormat format,
                             MKLTextureConfig config) {
    MKLTexture texture = {0};
    texture.valid = false;
    
    if (!renderer || width <= 0 || height <= 0) {
        return texture;
    }
    
    @autoreleasepool {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MKLTextureFormatToMTL(format)
                                                                                         width:width
                                                                                        height:height
                                                                                     mipmapped:config.generateMipmaps];
        desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
        desc.storageMode = MTLStorageModePrivate;
        
        id<MTLTexture> mtlTexture = [renderer->_device newTextureWithDescriptor:desc];
        if (!mtlTexture) {
            return texture;
        }
        
        texture._texture = mtlTexture;
        texture._sampler = CreateSamplerState(renderer->_device, config);
        texture.width = width;
        texture.height = height;
        texture.mipmaps = config.generateMipmaps ? (int)mtlTexture.mipmapLevelCount : 1;
        texture.format = format;
        texture.valid = true;
    }
    
    return texture;
}

// ========== Generated Textures ==========

MKLTexture MKLGenTextureCheckerboard(MKLRenderer *renderer,
                                       int width,
                                       int height,
                                       int checksX,
                                       int checksY,
                                       vector_float4 color1,
                                       vector_float4 color2) {
    if (width <= 0 || height <= 0 || checksX <= 0 || checksY <= 0) {
        return (MKLTexture){.valid = false};
    }
    
    // Generate checkerboard pixel data
    unsigned char *pixels = malloc(width * height * 4);
    if (!pixels) {
        return (MKLTexture){.valid = false};
    }
    
    int checkWidth = width / checksX;
    int checkHeight = height / checksY;
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int checkX = x / checkWidth;
            int checkY = y / checkHeight;
            bool useColor1 = ((checkX + checkY) % 2) == 0;
            
            vector_float4 color = useColor1 ? color1 : color2;
            int index = (y * width + x) * 4;
            pixels[index + 0] = (unsigned char)(color.x * 255);
            pixels[index + 1] = (unsigned char)(color.y * 255);
            pixels[index + 2] = (unsigned char)(color.z * 255);
            pixels[index + 3] = (unsigned char)(color.w * 255);
        }
    }
    
    MKLTextureConfig config = MKLGetDefaultTextureConfig();
    config.generateMipmaps = false;
    
    MKLTexture texture = MKLLoadTextureFromMemory(renderer, pixels, width, height, 
                                                    MKL_TEXTURE_FORMAT_RGBA8, config);
    free(pixels);
    
    return texture;
}

MKLTexture MKLGenTextureColor(MKLRenderer *renderer,
                               int width,
                               int height,
                               vector_float4 color) {
    if (width <= 0 || height <= 0) {
        return (MKLTexture){.valid = false};
    }
    
    // Generate solid color pixel data
    unsigned char *pixels = malloc(width * height * 4);
    if (!pixels) {
        return (MKLTexture){.valid = false};
    }
    
    unsigned char r = (unsigned char)(color.x * 255);
    unsigned char g = (unsigned char)(color.y * 255);
    unsigned char b = (unsigned char)(color.z * 255);
    unsigned char a = (unsigned char)(color.w * 255);
    
    for (int i = 0; i < width * height; i++) {
        pixels[i * 4 + 0] = r;
        pixels[i * 4 + 1] = g;
        pixels[i * 4 + 2] = b;
        pixels[i * 4 + 3] = a;
    }
    
    MKLTextureConfig config = MKLGetDefaultTextureConfig();
    config.generateMipmaps = false;
    
    MKLTexture texture = MKLLoadTextureFromMemory(renderer, pixels, width, height,
                                                    MKL_TEXTURE_FORMAT_RGBA8, config);
    free(pixels);
    
    return texture;
}

// ========== Texture Management ==========

void MKLUnloadTexture(MKLTexture *texture) {
    if (texture && texture->valid) {
        @autoreleasepool {
            texture->_texture = nil;
            texture->_sampler = nil;
        }
        texture->valid = false;
    }
}

bool MKLIsTextureValid(const MKLTexture *texture) {
    return texture && texture->valid && texture->_texture != nil;
}

void MKLUpdateTexture(MKLTexture *texture,
                       const void *data,
                       int width,
                       int height,
                       int offsetX,
                       int offsetY) {
    if (!MKLIsTextureValid(texture) || !data) {
        return;
    }
    
    @autoreleasepool {
        id<MTLTexture> mtlTexture = texture->_texture;
        
        MTLRegion region = MTLRegionMake2D(offsetX, offsetY, width, height);
        NSUInteger bytesPerRow = width * 4; // Assume RGBA8
        
        [mtlTexture replaceRegion:region
                      mipmapLevel:0
                        withBytes:data
                      bytesPerRow:bytesPerRow];
    }
}

