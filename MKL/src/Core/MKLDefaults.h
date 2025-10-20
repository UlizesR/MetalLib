/**
 * @file MKLDefaults.h
 * @brief Default values for MetalLib objects and parameters
 * 
 * Centralized default values for cameras, lights, materials, and other
 * library objects. Modify these to change library-wide defaults.
 */

#ifndef MKL_DEFAULTS_H
#define MKL_DEFAULTS_H

// ============================================================================
// Camera Defaults
// ============================================================================

/**
 * @brief Default camera field of view (degrees)
 */
#define MKL_DEFAULT_CAMERA_FOV 45.0f

/**
 * @brief Default camera near clipping plane
 */
#define MKL_DEFAULT_CAMERA_NEAR 0.1f

/**
 * @brief Default camera far clipping plane
 */
#define MKL_DEFAULT_CAMERA_FAR 1000.0f

/**
 * @brief Default camera aspect ratio (16:9)
 */
#define MKL_DEFAULT_CAMERA_ASPECT (16.0f / 9.0f)

/**
 * @brief Default camera position
 */
#define MKL_DEFAULT_CAMERA_POSITION {0.0f, 10.0f, 10.0f}

/**
 * @brief Default camera target/look-at point
 */
#define MKL_DEFAULT_CAMERA_TARGET {0.0f, 0.0f, 0.0f}

/**
 * @brief Default camera up vector
 */
#define MKL_DEFAULT_CAMERA_UP {0.0f, 1.0f, 0.0f}

// ============================================================================
// Light Defaults
// ============================================================================

/**
 * @brief Default light intensity (0.0 - 1.0+)
 */
#define MKL_DEFAULT_LIGHT_INTENSITY 1.0f

/**
 * @brief Default ambient light color
 */
#define MKL_DEFAULT_AMBIENT_COLOR {0.1f, 0.1f, 0.1f}

/**
 * @brief Default ambient light intensity
 */
#define MKL_DEFAULT_AMBIENT_INTENSITY 0.2f

/**
 * @brief Default directional light direction (downward)
 */
#define MKL_DEFAULT_LIGHT_DIRECTION {0.0f, -1.0f, 0.0f}

/**
 * @brief Default point light constant attenuation
 */
#define MKL_DEFAULT_LIGHT_CONSTANT_ATTEN 1.0f

/**
 * @brief Default point light linear attenuation
 */
#define MKL_DEFAULT_LIGHT_LINEAR_ATTEN 0.09f

/**
 * @brief Default point light quadratic attenuation
 */
#define MKL_DEFAULT_LIGHT_QUADRATIC_ATTEN 0.032f

/**
 * @brief Default spotlight inner cone angle (degrees)
 */
#define MKL_DEFAULT_SPOTLIGHT_INNER_ANGLE 12.5f

/**
 * @brief Default spotlight outer cone angle (degrees)
 */
#define MKL_DEFAULT_SPOTLIGHT_OUTER_ANGLE 17.5f

// ============================================================================
// Material Defaults
// ============================================================================

/**
 * @brief Default material albedo (white)
 */
#define MKL_DEFAULT_MATERIAL_ALBEDO {1.0f, 1.0f, 1.0f, 1.0f}

/**
 * @brief Default material metallic value (0.0 = dielectric, 1.0 = metal)
 */
#define MKL_DEFAULT_MATERIAL_METALLIC 0.0f

/**
 * @brief Default material roughness (0.0 = smooth, 1.0 = rough)
 */
#define MKL_DEFAULT_MATERIAL_ROUGHNESS 0.5f

/**
 * @brief Default material shininess (Blinn-Phong specular exponent)
 */
#define MKL_DEFAULT_MATERIAL_SHININESS 32.0f

/**
 * @brief Default material opacity (1.0 = opaque, 0.0 = transparent)
 */
#define MKL_DEFAULT_MATERIAL_OPACITY 1.0f

// ============================================================================
// Geometry Defaults
// ============================================================================

/**
 * @brief Default sphere segment count (higher = smoother)
 */
#define MKL_DEFAULT_SPHERE_SEGMENTS 32

/**
 * @brief Default cylinder segment count
 */
#define MKL_DEFAULT_CYLINDER_SEGMENTS 32

/**
 * @brief Default cone segment count
 */
#define MKL_DEFAULT_CONE_SEGMENTS 32

/**
 * @brief Default torus major segments
 */
#define MKL_DEFAULT_TORUS_MAJOR_SEGMENTS 32

/**
 * @brief Default torus minor segments
 */
#define MKL_DEFAULT_TORUS_MINOR_SEGMENTS 16

/**
 * @brief Default plane segments (per dimension)
 */
#define MKL_DEFAULT_PLANE_SEGMENTS 1

// ============================================================================
// Window Defaults
// ============================================================================

/**
 * @brief Default window width
 */
#define MKL_DEFAULT_WINDOW_WIDTH 800

/**
 * @brief Default window height
 */
#define MKL_DEFAULT_WINDOW_HEIGHT 600

/**
 * @brief Default window title
 */
#define MKL_DEFAULT_WINDOW_TITLE "MetalLib Application"

// ============================================================================
// Rendering Defaults
// ============================================================================

/**
 * @brief Default clear color (dark gray)
 */
#define MKL_DEFAULT_CLEAR_COLOR {0.2f, 0.2f, 0.2f, 1.0f}

/**
 * @brief Default depth clear value
 */
#define MKL_DEFAULT_DEPTH_CLEAR 1.0f

/**
 * @brief Default line thickness for 2D shapes
 */
#define MKL_DEFAULT_LINE_THICKNESS 1.0f

#endif // MKL_DEFAULTS_H

