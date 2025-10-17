//
// MKLRenderTarget.h
// MetalLib - Render Target / Framebuffer System
//
// Provides off-screen rendering capabilities for post-processing, shadows, reflections, etc.
//

#ifndef MKLRenderTarget_h
#define MKLRenderTarget_h

#include "../Core/MKLCore.h"
#include "MKLTexture.h"
#include "MKLColors.h"
#include <stdbool.h>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ========== Render Target Types ==========

/**
 * @brief Render target attachment types
 */
typedef enum MKLAttachmentType {
    MKL_ATTACHMENT_COLOR = 0,       ///< Color attachment
    MKL_ATTACHMENT_DEPTH,           ///< Depth attachment
    MKL_ATTACHMENT_STENCIL,         ///< Stencil attachment
    MKL_ATTACHMENT_DEPTH_STENCIL    ///< Combined depth-stencil attachment
} MKLAttachmentType;

/**
 * @brief Render target load action (what to do with previous contents)
 */
typedef enum MKLLoadAction {
    MKL_LOAD_ACTION_DONT_CARE = 0,  ///< Don't care about previous contents
    MKL_LOAD_ACTION_LOAD,           ///< Load previous contents
    MKL_LOAD_ACTION_CLEAR           ///< Clear to specified color/value
} MKLLoadAction;

/**
 * @brief Render target store action (what to do with rendered contents)
 */
typedef enum MKLStoreAction {
    MKL_STORE_ACTION_DONT_CARE = 0, ///< Don't care about storing
    MKL_STORE_ACTION_STORE,         ///< Store for later use
    MKL_STORE_ACTION_MULTISAMPLE_RESOLVE ///< Resolve multisample
} MKLStoreAction;

/**
 * @brief Render target configuration
 */
typedef struct MKLRenderTargetConfig {
    int width;                      ///< Width in pixels
    int height;                     ///< Height in pixels
    bool hasColorAttachment;        ///< Include color attachment
    bool hasDepthAttachment;        ///< Include depth attachment
    bool hasStencilAttachment;      ///< Include stencil attachment
    int sampleCount;                ///< MSAA sample count (1, 2, 4, 8)
    MKLTextureFormat colorFormat;   ///< Color texture format
    MKLTextureFormat depthFormat;   ///< Depth texture format
} MKLRenderTargetConfig;

/**
 * @brief Render target structure (render-to-texture)
 */
typedef struct MKLRenderTarget {
    int id;                         ///< Unique identifier
    int width;                      ///< Width in pixels
    int height;                     ///< Height in pixels
    
    MKLTexture colorTexture;        ///< Color texture attachment
    MKLTexture depthTexture;        ///< Depth texture attachment
    MKLTexture stencilTexture;      ///< Stencil texture attachment (if separate)
    
#ifdef __OBJC__
    MTLRenderPassDescriptor *_renderPassDescriptor; ///< Render pass descriptor
    id<MTLTexture> _msaaColorTexture;  ///< MSAA color texture (if MSAA enabled)
    id<MTLTexture> _msaaDepthTexture;  ///< MSAA depth texture (if MSAA enabled)
#else
    void *_renderPassDescriptor;
    void *_msaaColorTexture;
    void *_msaaDepthTexture;
#endif
    
    int sampleCount;                ///< MSAA sample count
    bool valid;                     ///< Is render target valid
} MKLRenderTarget;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Render Target Creation Functions ==========

/**
 * @brief Create a render target with default settings
 * @param renderer The renderer context
 * @param width Width in pixels
 * @param height Height in pixels
 * @return Created render target
 */
MKLAPI MKLRenderTarget MKLLoadRenderTarget(MKLRenderer *renderer, int width, int height);

/**
 * @brief Create a render target with custom configuration
 * @param renderer The renderer context
 * @param config Render target configuration
 * @return Created render target
 */
MKLAPI MKLRenderTarget MKLLoadRenderTargetEx(MKLRenderer *renderer, MKLRenderTargetConfig config);

/**
 * @brief Create a depth-only render target (for shadow mapping)
 * @param renderer The renderer context
 * @param width Width in pixels
 * @param height Height in pixels
 * @return Depth-only render target
 */
MKLAPI MKLRenderTarget MKLLoadRenderTargetDepth(MKLRenderer *renderer, int width, int height);

/**
 * @brief Unload render target and free resources
 * @param renderTarget Render target to unload
 */
MKLAPI void MKLUnloadRenderTarget(MKLRenderTarget *renderTarget);

/**
 * @brief Check if render target is valid
 * @param renderTarget Render target to check
 * @return true if valid
 */
MKLAPI bool MKLIsRenderTargetValid(const MKLRenderTarget *renderTarget);

// ========== Render Target Configuration Helpers ==========

/**
 * @brief Get default render target configuration
 * @param width Width in pixels
 * @param height Height in pixels
 * @return Default configuration
 */
MKLAPI MKLRenderTargetConfig MKLGetDefaultRenderTargetConfig(int width, int height);

/**
 * @brief Get configuration for shadow map render target
 * @param size Shadow map size (typically 1024, 2048, 4096)
 * @return Shadow map configuration
 */
MKLAPI MKLRenderTargetConfig MKLGetShadowMapConfig(int size);

/**
 * @brief Get configuration for HDR render target
 * @param width Width in pixels
 * @param height Height in pixels
 * @return HDR configuration
 */
MKLAPI MKLRenderTargetConfig MKLGetHDRConfig(int width, int height);

// ========== Render Target Usage Functions ==========

/**
 * @brief Begin rendering to a render target
 * @param renderer The renderer context
 * @param renderTarget Render target to render to
 * @param clearColor Color to clear to (if using CLEAR load action)
 */
MKLAPI void MKLBeginTextureMode(MKLRenderer *renderer, 
                                  MKLRenderTarget *renderTarget,
                                  MKLColor clearColor);

/**
 * @brief End rendering to render target and return to default framebuffer
 * @param renderer The renderer context
 */
MKLAPI void MKLEndTextureMode(MKLRenderer *renderer);

/**
 * @brief Begin rendering to render target with custom clear values
 * @param renderer The renderer context
 * @param renderTarget Render target to render to
 * @param loadAction Load action for color attachment
 * @param clearColor Color to clear to (if CLEAR action)
 * @param clearDepth Depth value to clear to
 */
MKLAPI void MKLBeginTextureModeEx(MKLRenderer *renderer,
                                    MKLRenderTarget *renderTarget,
                                    MKLLoadAction loadAction,
                                    MKLColor clearColor,
                                    float clearDepth);

// ========== Render Target Queries ==========

/**
 * @brief Get the color texture from a render target
 * @param renderTarget Render target
 * @return Pointer to color texture
 */
MKLAPI MKLTexture* MKLGetRenderTargetColorTexture(MKLRenderTarget *renderTarget);

/**
 * @brief Get the depth texture from a render target
 * @param renderTarget Render target
 * @return Pointer to depth texture
 */
MKLAPI MKLTexture* MKLGetRenderTargetDepthTexture(MKLRenderTarget *renderTarget);

/**
 * @brief Resize a render target
 * @param renderer The renderer context
 * @param renderTarget Render target to resize
 * @param width New width
 * @param height New height
 */
MKLAPI void MKLResizeRenderTarget(MKLRenderer *renderer,
                                    MKLRenderTarget *renderTarget,
                                    int width,
                                    int height);

// ========== Post-Processing Helpers ==========

/**
 * @brief Blit (copy) render target to screen
 * @param renderer The renderer context
 * @param renderTarget Source render target
 */
MKLAPI void MKLBlitRenderTarget(MKLRenderer *renderer, MKLRenderTarget *renderTarget);

/**
 * @brief Blit render target to screen with custom shader
 * @param renderer The renderer context
 * @param renderTarget Source render target
 * @param shader Custom shader for post-processing
 */
MKLAPI void MKLBlitRenderTargetShader(MKLRenderer *renderer,
                                       MKLRenderTarget *renderTarget,
                                       void *shader); // MKLShader*

#ifdef __cplusplus
}
#endif

#endif /* MKLRenderTarget_h */

