//
// MKLText.h
// MetalLib - Text Rendering System
//
// Provides text rendering capabilities using bitmap fonts
//

#ifndef MKLText_h
#define MKLText_h

#include "../Core/MKLCore.h"
#include "MKLColors.h"
#include "MKLTexture.h"
#include <simd/simd.h>
#include <stdbool.h>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ========== Font Types ==========

/**
 * @brief Font type/style
 */
typedef enum MKLFontType {
    MKL_FONT_DEFAULT = 0,           ///< Default embedded bitmap font
    MKL_FONT_BITMAP,                ///< Bitmap font from file
    MKL_FONT_TTF                    ///< TrueType font (rasterized)
} MKLFontType;

/**
 * @brief Character information in font atlas
 */
typedef struct MKLGlyphInfo {
    int value;                      ///< Character value (ASCII/Unicode)
    int offsetX;                    ///< Glyph offset X
    int offsetY;                    ///< Glyph offset Y
    int advanceX;                   ///< Horizontal advance
    int width;                      ///< Glyph width
    int height;                     ///< Glyph height
    
    // Texture coordinates in atlas
    float texCoordX;                ///< Texture coordinate X (normalized)
    float texCoordY;                ///< Texture coordinate Y (normalized)
    float texWidth;                 ///< Texture width (normalized)
    float texHeight;                ///< Texture height (normalized)
} MKLGlyphInfo;

/**
 * @brief Font structure containing glyph data and atlas texture
 */
typedef struct MKLFont {
    MKLFontType type;               ///< Font type
    int baseSize;                   ///< Base font size in pixels
    int glyphCount;                 ///< Number of glyphs
    int glyphPadding;               ///< Padding between glyphs in atlas
    
    MKLTexture atlas;               ///< Font atlas texture
    MKLGlyphInfo *glyphs;           ///< Glyph information array
    
#ifdef __OBJC__
    id<MTLBuffer> _glyphBuffer;     ///< GPU buffer for glyph data
    id<MTLRenderPipelineState> _pipeline; ///< Text rendering pipeline
#else
    void *_glyphBuffer;
    void *_pipeline;
#endif
    
    bool valid;                     ///< Is font valid
} MKLFont;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Font Loading Functions ==========

/**
 * @brief Get the default built-in font
 * @param renderer The renderer context
 * @return Default font
 */
MKLAPI MKLFont* MKLGetDefaultFont(MKLRenderer *renderer);

/**
 * @brief Load font from file (TTF or bitmap font)
 * @param renderer The renderer context
 * @param fileName Path to font file
 * @param fontSize Font size in pixels (for TTF fonts)
 * @param glyphCount Number of glyphs to load (0 = all ASCII)
 * @param glyphs Array of glyph codepoints to load (NULL = ASCII range)
 * @return Loaded font or NULL on failure
 */
MKLAPI MKLFont* MKLLoadFont(MKLRenderer *renderer, 
                              const char *fileName, 
                              int fontSize,
                              int glyphCount,
                              int *glyphs);

/**
 * @brief Load font from file with default settings (ASCII characters, size 32)
 * @param renderer The renderer context
 * @param fileName Path to font file
 * @return Loaded font or NULL on failure
 */
MKLAPI MKLFont* MKLLoadFontEx(MKLRenderer *renderer, const char *fileName);

/**
 * @brief Unload font and free resources
 * @param font Font to unload
 */
MKLAPI void MKLUnloadFont(MKLFont *font);

/**
 * @brief Check if a font is valid
 * @param font Font to check
 * @return true if font is valid
 */
MKLAPI bool MKLIsFontValid(const MKLFont *font);

// ========== Text Measurement Functions ==========

/**
 * @brief Measure text dimensions
 * @param font Font to use for measurement
 * @param text Text to measure
 * @param fontSize Font size to render at
 * @param spacing Character spacing
 * @return Text dimensions (width, height)
 */
MKLAPI vector_float2 MKLMeasureText(const MKLFont *font, 
                                      const char *text, 
                                      float fontSize, 
                                      float spacing);

/**
 * @brief Measure text width only
 * @param font Font to use
 * @param text Text to measure
 * @param fontSize Font size
 * @param spacing Character spacing
 * @return Text width in pixels
 */
MKLAPI float MKLMeasureTextWidth(const MKLFont *font, 
                                   const char *text, 
                                   float fontSize, 
                                   float spacing);

// ========== 2D Text Drawing Functions ==========

/**
 * @brief Draw text at position (2D screen coordinates)
 * @param renderer The renderer context
 * @param text Text to draw
 * @param posX X position (screen coordinates)
 * @param posY Y position (screen coordinates)
 * @param fontSize Font size in pixels
 * @param color Text color
 */
MKLAPI void MKLDrawText(MKLRenderer *renderer, 
                         const char *text, 
                         float posX, 
                         float posY, 
                         float fontSize, 
                         MKLColor color);

/**
 * @brief Draw text with custom font
 * @param renderer The renderer context
 * @param font Font to use
 * @param text Text to draw
 * @param position Position (x, y)
 * @param fontSize Font size
 * @param spacing Character spacing
 * @param color Text color
 */
MKLAPI void MKLDrawTextEx(MKLRenderer *renderer,
                            const MKLFont *font,
                            const char *text,
                            vector_float2 position,
                            float fontSize,
                            float spacing,
                            MKLColor color);

/**
 * @brief Draw text with rotation and origin
 * @param renderer The renderer context
 * @param font Font to use
 * @param text Text to draw
 * @param position Position (x, y)
 * @param origin Origin point for rotation (x, y)
 * @param rotation Rotation in degrees
 * @param fontSize Font size
 * @param spacing Character spacing
 * @param color Text color
 */
MKLAPI void MKLDrawTextPro(MKLRenderer *renderer,
                             const MKLFont *font,
                             const char *text,
                             vector_float2 position,
                             vector_float2 origin,
                             float rotation,
                             float fontSize,
                             float spacing,
                             MKLColor color);

// ========== 3D Text Drawing Functions ==========

/**
 * @brief Draw text in 3D space (billboard, always faces camera)
 * @param renderer The renderer context
 * @param text Text to draw
 * @param position 3D world position
 * @param fontSize Font size in world units
 * @param color Text color
 */
MKLAPI void MKLDrawText3D(MKLRenderer *renderer,
                            const char *text,
                            vector_float3 position,
                            float fontSize,
                            MKLColor color);

/**
 * @brief Draw text in 3D space with custom font
 * @param renderer The renderer context
 * @param font Font to use
 * @param text Text to draw
 * @param position 3D world position
 * @param fontSize Font size in world units
 * @param spacing Character spacing
 * @param color Text color
 */
MKLAPI void MKLDrawText3DEx(MKLRenderer *renderer,
                              const MKLFont *font,
                              const char *text,
                              vector_float3 position,
                              float fontSize,
                              float spacing,
                              MKLColor color);

// ========== Formatted Text Functions ==========

/**
 * @brief Draw formatted text (printf-style)
 * @param renderer The renderer context
 * @param posX X position
 * @param posY Y position
 * @param fontSize Font size
 * @param color Text color
 * @param format Format string (printf-style)
 * @param ... Variable arguments
 */
MKLAPI void MKLDrawTextFormatted(MKLRenderer *renderer,
                                   float posX,
                                   float posY,
                                   float fontSize,
                                   MKLColor color,
                                   const char *format,
                                   ...);

#ifdef __cplusplus
}
#endif

#endif /* MKLText_h */

