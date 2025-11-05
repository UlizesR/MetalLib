//
// MKLTexture.h
// MetalLib - Texture Loading and Management
//
// Provides texture loading from files and memory, similar to raylib's texture system
//

#ifndef MKLTexture_h
#define MKLTexture_h

#include "../Core/MKLCore.h"
#include <simd/simd.h>
#include <stdbool.h>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ========== Texture Types ==========

/**
 * @brief Texture wrap modes (for texture sampling beyond [0,1])
 */
typedef enum MKLTextureWrap {
    MKL_TEXTURE_WRAP_REPEAT = 0,        ///< Repeat texture coordinates
    MKL_TEXTURE_WRAP_CLAMP_TO_EDGE,     ///< Clamp to edge
    MKL_TEXTURE_WRAP_MIRRORED_REPEAT,   ///< Mirror repeat
    MKL_TEXTURE_WRAP_CLAMP_TO_ZERO      ///< Clamp to border color (0,0,0,0)
} MKLTextureWrap;

/**
 * @brief Texture filtering modes
 */
typedef enum MKLTextureFilter {
    MKL_TEXTURE_FILTER_NEAREST = 0,     ///< Nearest neighbor (pixelated)
    MKL_TEXTURE_FILTER_LINEAR,          ///< Linear interpolation (smooth)
    MKL_TEXTURE_FILTER_ANISOTROPIC      ///< Anisotropic filtering (best quality)
} MKLTextureFilter;

/**
 * @brief Texture pixel formats
 */
typedef enum MKLTextureFormat {
    MKL_TEXTURE_FORMAT_RGBA8 = 0,       ///< 8-bit RGBA
    MKL_TEXTURE_FORMAT_RGB8,            ///< 8-bit RGB
    MKL_TEXTURE_FORMAT_GRAY8,           ///< 8-bit grayscale
    MKL_TEXTURE_FORMAT_RGBA32F,         ///< 32-bit float RGBA
    MKL_TEXTURE_FORMAT_DEPTH32F         ///< 32-bit float depth
} MKLTextureFormat;

/**
 * @brief Texture configuration structure
 */
typedef struct MKLTextureConfig {
    MKLTextureWrap wrapS;               ///< Horizontal wrap mode
    MKLTextureWrap wrapT;               ///< Vertical wrap mode
    MKLTextureFilter minFilter;         ///< Minification filter
    MKLTextureFilter magFilter;         ///< Magnification filter
    bool generateMipmaps;               ///< Generate mipmaps automatically
    unsigned int maxAnisotropy;         ///< Max anisotropy level (1-16)
} MKLTextureConfig;

/**
 * @brief Texture object containing Metal texture and metadata
 */
typedef struct MKLTexture {
#ifdef __OBJC__
    id<MTLTexture> _texture;            ///< Metal texture object
    id<MTLSamplerState> _sampler;       ///< Sampler state for this texture
#else
    void *_texture;
    void *_sampler;
#endif
    int width;                          ///< Texture width in pixels
    int height;                         ///< Texture height in pixels
    int mipmaps;                        ///< Number of mipmap levels
    MKLTextureFormat format;            ///< Texture pixel format
    bool valid;                         ///< Is texture valid/loaded
} MKLTexture;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Texture Loading Functions ==========

/**
 * @brief Load texture from file with default configuration
 * @param renderer The renderer context (needed for Metal device)
 * @param fileName Path to image file (PNG, JPG, etc.)
 * @return Loaded texture or invalid texture on failure
 */
MKLAPI MKLTexture MKLLoadTexture(MKLRenderer *renderer, const char *fileName);

/**
 * @brief Load texture from file with custom configuration
 * @param renderer The renderer context
 * @param fileName Path to image file
 * @param config Texture configuration
 * @return Loaded texture or invalid texture on failure
 */
MKLAPI MKLTexture MKLLoadTextureEx(MKLRenderer *renderer, const char *fileName, MKLTextureConfig config);

/**
 * @brief Load texture from raw memory data
 * @param renderer The renderer context
 * @param data Pointer to pixel data
 * @param width Texture width
 * @param height Texture height
 * @param format Pixel format
 * @param config Texture configuration
 * @return Loaded texture or invalid texture on failure
 */
MKLAPI MKLTexture MKLLoadTextureFromMemory(MKLRenderer *renderer,
                                              const void *data,
                                              int width,
                                              int height,
                                              MKLTextureFormat format,
                                              MKLTextureConfig config);

/**
 * @brief Unload texture and free GPU memory
 * @param texture Texture to unload
 */
MKLAPI void MKLUnloadTexture(MKLTexture *texture);

/**
 * @brief Check if a texture is valid
 * @param texture Texture to check
 * @return true if texture is valid and loaded
 */
MKLAPI bool MKLIsTextureValid(const MKLTexture *texture);

// ========== Texture Configuration Helpers ==========

/**
 * @brief Get default texture configuration
 * @return Default texture config with sensible defaults
 */
MKLAPI MKLTextureConfig MKLGetDefaultTextureConfig(void);

/**
 * @brief Create a texture configuration for pixel art (nearest filtering, no mipmaps)
 * @return Pixel art texture configuration
 */
MKLAPI MKLTextureConfig MKLGetPixelArtTextureConfig(void);

/**
 * @brief Create a texture configuration for high quality textures (anisotropic, mipmaps)
 * @return High quality texture configuration
 */
MKLAPI MKLTextureConfig MKLGetHighQualityTextureConfig(void);

// ========== Texture Creation Functions ==========

/**
 * @brief Create an empty texture for render targets
 * @param renderer The renderer context
 * @param width Texture width
 * @param height Texture height
 * @param format Texture format
 * @param config Texture configuration
 * @return Created texture
 */
MKLAPI MKLTexture MKLCreateTexture(MKLRenderer *renderer,
                                     int width,
                                     int height,
                                     MKLTextureFormat format,
                                     MKLTextureConfig config);

/**
 * @brief Generate a simple checkerboard texture for testing/debugging
 * @param renderer The renderer context
 * @param width Texture width
 * @param height Texture height
 * @param checksX Number of checks horizontally
 * @param checksY Number of checks vertically
 * @param color1 First checkerboard color (RGBA)
 * @param color2 Second checkerboard color (RGBA)
 * @return Generated checkerboard texture
 */
MKLAPI MKLTexture MKLGenTextureCheckerboard(MKLRenderer *renderer,
                                               int width,
                                               int height,
                                               int checksX,
                                               int checksY,
                                               vector_float4 color1,
                                               vector_float4 color2);

/**
 * @brief Generate a solid color texture
 * @param renderer The renderer context
 * @param width Texture width
 * @param height Texture height
 * @param color Color (RGBA)
 * @return Generated solid color texture
 */
MKLAPI MKLTexture MKLGenTextureColor(MKLRenderer *renderer,
                                       int width,
                                       int height,
                                       vector_float4 color);

// ========== Texture Updates ==========

/**
 * @brief Update texture data (useful for dynamic textures)
 * @param texture Texture to update
 * @param data New pixel data
 * @param width Data width
 * @param height Data height
 * @param offsetX X offset in texture
 * @param offsetY Y offset in texture
 */
MKLAPI void MKLUpdateTexture(MKLTexture *texture,
                               const void *data,
                               int width,
                               int height,
                               int offsetX,
                               int offsetY);

#ifdef __cplusplus
}
#endif

#endif /* MKLTexture_h */

