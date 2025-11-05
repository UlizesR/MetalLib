/**
 * @file MKLConfig.h
 * @brief MetalLib Configuration Constants
 *
 * Central configuration file for all library constants, limits, and defaults.
 * Modify these values to tune library behavior.
 */

#ifndef MKL_CONFIG_H
#define MKL_CONFIG_H

// ============================================================================
// Rendering Configuration
// ============================================================================

/**
 * @brief Maximum number of frames that can be in-flight simultaneously
 *
 * Triple buffering (3) is recommended for optimal performance.
 * Increase for smoother frame pacing on high-latency GPUs.
 */
#define MKL_MAX_FRAMES_IN_FLIGHT 3

/**
 * @brief Default target frames per second
 *
 * Set to 60 for standard displays, 0 for unlimited (disables VSync).
 */
#define MKL_DEFAULT_TARGET_FPS 60

/**
 * @brief MSAA (Multi-Sample Anti-Aliasing) sample count
 *
 * Valid values: 1 (off), 2, 4, 8
 * Higher = smoother edges but more GPU memory/performance cost
 *
 * - 1: No MSAA (default, fastest)
 * - 2: 2x MSAA (minimal cost, moderate improvement)
 * - 4: 4x MSAA (recommended, good quality/performance balance)
 * - 8: 8x MSAA (highest quality, 4-8x more memory/performance cost)
 */
#define MKL_DEFAULT_MSAA_SAMPLES 4

/**
 * @brief Maximum number of draw commands that can be batched per frame
 *
 * Increase if you need to render more than 10,000 objects per frame.
 * Each command uses ~80 bytes of memory.
 */
#define MKL_MAX_DRAW_COMMANDS 10000

// ============================================================================
// Lighting Configuration
// ============================================================================

/**
 * @brief Maximum number of lights supported in a scene
 *
 * Must match MAX_LIGHTS in Shaders.metal!
 * Increase requires shader recompilation.
 */
#define MKL_MAX_LIGHTS 8

// ============================================================================
// Geometry Caching Configuration
// ============================================================================

/**
 * @brief Maximum number of plane geometry configurations to cache
 *
 * Each entry caches a unique (segments.x, segments.y) configuration.
 * Memory usage: ~34 KB per entry.
 */
#define MKL_MAX_PLANE_CACHE_ENTRIES 8

/**
 * @brief Maximum number of sphere geometry configurations to cache
 *
 * Caches different segment counts (16, 32, 64, etc).
 * Future optimization.
 */
#define MKL_MAX_SPHERE_CACHE_ENTRIES 4

// ============================================================================
// Input Configuration
// ============================================================================

/**
 * @brief Number of keyboard keys tracked
 */
#define MKL_KEY_COUNT 256

/**
 * @brief Number of mouse buttons tracked
 */
#define MKL_MOUSE_BUTTON_COUNT 12

/**
 * @brief Size of keyboard key press event queue
 */
#define MKL_KEY_PRESS_QUEUE_SIZE 16

// ============================================================================
// Camera Configuration
// ============================================================================

/**
 * @brief Default camera movement speed (units per second)
 */
#define MKL_CAMERA_MOVE_SPEED 5.0f

/**
 * @brief Default camera rotation speed (degrees per second)
 */
#define MKL_CAMERA_ROTATION_SPEED 90.0f

/**
 * @brief Camera pan speed multiplier
 */
#define MKL_CAMERA_PAN_SPEED 0.2f

/**
 * @brief Mouse sensitivity for camera look (radians per pixel)
 */
#define MKL_CAMERA_MOUSE_SENSITIVITY 0.003f

/**
 * @brief Orbital camera rotation speed (radians per second)
 */
#define MKL_CAMERA_ORBITAL_SPEED 0.5f

// ============================================================================
// Performance Monitoring
// ============================================================================

/**
 * @brief Number of FPS samples for rolling average
 */
#define MKL_MAX_FPS_SAMPLES 10

// ============================================================================
// Memory Configuration
// ============================================================================

/**
 * @brief Buffer alignment size (4KB for optimal GPU performance)
 */
#define MKL_BUFFER_ALIGNMENT 4096

/**
 * @brief Align buffer size to MKL_BUFFER_ALIGNMENT
 * @param size The size to align
 * @return Aligned size (rounded up to nearest MKL_BUFFER_ALIGNMENT)
 */
#define MKL_ALIGN_BUFFER(size) (((size) + (MKL_BUFFER_ALIGNMENT - 1)) & ~(MKL_BUFFER_ALIGNMENT - 1))

/**
 * @brief Initial buffer pool size (number of buffers per size)
 */
#define MKL_BUFFER_POOL_INITIAL_SIZE 16

/**
 * @brief Maximum buffer pool size before warning
 */
#define MKL_BUFFER_POOL_MAX_SIZE 1024

// ============================================================================
// Rendering Limits
// ============================================================================

/**
 * @brief Maximum texture size (width or height)
 */
#define MKL_MAX_TEXTURE_SIZE 8192

/**
 * @brief Maximum number of materials
 */
#define MKL_MAX_MATERIALS 256

/**
 * @brief Maximum number of render targets
 */
#define MKL_MAX_RENDER_TARGETS 16

// ============================================================================
// Debug Configuration
// ============================================================================

/**
 * @brief Enable verbose logging (0 = off, 1 = on)
 */
#ifndef MKL_VERBOSE_LOGGING
#define MKL_VERBOSE_LOGGING 0
#endif

/**
 * @brief Enable performance warnings (0 = off, 1 = on)
 */
#ifndef MKL_PERFORMANCE_WARNINGS
#define MKL_PERFORMANCE_WARNINGS 1
#endif

/**
 * @brief Enable validation checks (0 = off, 1 = on)
 * Disable in release builds for maximum performance
 */
#ifndef MKL_VALIDATION_ENABLED
#ifdef DEBUG
#define MKL_VALIDATION_ENABLED 1
#else
#define MKL_VALIDATION_ENABLED 0
#endif
#endif

#endif // MKL_CONFIG_H

