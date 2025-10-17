//
// MKLLight.h
// MetalLib - Lighting System
//
// Provides a flexible lighting system supporting multiple light types
//

#ifndef MKLLight_h
#define MKLLight_h

#include "../Core/MKLCore.h"
#include "MKLColors.h"
#include <simd/simd.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ========== Light Types ==========

/**
 * @brief Types of lights supported by the engine
 */
typedef enum MKLLightType {
    MKL_LIGHT_AMBIENT = 0,          ///< Ambient light (no direction, affects everything equally)
    MKL_LIGHT_DIRECTIONAL,          ///< Directional light (like sun, parallel rays)
    MKL_LIGHT_POINT,                ///< Point light (emits in all directions, has position)
    MKL_LIGHT_SPOT                  ///< Spotlight (cone of light, has position and direction)
} MKLLightType;

/**
 * @brief Light structure containing all light properties
 */
typedef struct MKLLight {
    MKLLightType type;              ///< Type of light
    bool enabled;                   ///< Is light active
    
    // Color and intensity
    MKLColor color;                 ///< Light color (RGB)
    float intensity;                ///< Light intensity/brightness
    
    // Position (for point and spot lights)
    vector_float3 position;         ///< World position
    
    // Direction (for directional and spot lights)
    vector_float3 direction;        ///< Light direction (normalized)
    
    // Attenuation (for point and spot lights)
    float constantAttenuation;      ///< Constant attenuation factor
    float linearAttenuation;        ///< Linear attenuation factor
    float quadraticAttenuation;     ///< Quadratic attenuation factor
    
    // Spotlight specific
    float innerConeAngle;           ///< Inner cone angle in radians
    float outerConeAngle;           ///< Outer cone angle in radians
} MKLLight;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Light Creation Functions ==========

/**
 * @brief Create an ambient light
 * @param color Light color
 * @param intensity Light intensity (usually 0.0-1.0)
 * @return Ambient light
 */
MKLAPI MKLLight MKLCreateAmbientLight(MKLColor color, float intensity);

/**
 * @brief Create a directional light (like sun)
 * @param direction Light direction (will be normalized)
 * @param color Light color
 * @param intensity Light intensity
 * @return Directional light
 */
MKLAPI MKLLight MKLCreateDirectionalLight(vector_float3 direction, MKLColor color, float intensity);

/**
 * @brief Create a point light
 * @param position Light position in world space
 * @param color Light color
 * @param intensity Light intensity
 * @param range Effective range of the light (0 = infinite)
 * @return Point light
 */
MKLAPI MKLLight MKLCreatePointLight(vector_float3 position, MKLColor color, float intensity, float range);

/**
 * @brief Create a spotlight
 * @param position Light position in world space
 * @param direction Light direction (will be normalized)
 * @param color Light color
 * @param intensity Light intensity
 * @param innerAngle Inner cone angle in radians
 * @param outerAngle Outer cone angle in radians
 * @return Spotlight
 */
MKLAPI MKLLight MKLCreateSpotLight(vector_float3 position, 
                                     vector_float3 direction,
                                     MKLColor color, 
                                     float intensity,
                                     float innerAngle,
                                     float outerAngle);

// ========== Light Management Functions ==========

/**
 * @brief Add a light to the renderer's light list
 * @param renderer The renderer context
 * @param light Light to add
 * @return Index of added light, or -1 on failure
 */
MKLAPI int MKLAddLight(MKLRenderer *renderer, MKLLight light);

/**
 * @brief Remove a light by index
 * @param renderer The renderer context
 * @param index Index of light to remove
 */
MKLAPI void MKLRemoveLight(MKLRenderer *renderer, int index);

/**
 * @brief Update an existing light
 * @param renderer The renderer context
 * @param index Index of light to update
 * @param light Updated light data
 */
MKLAPI void MKLUpdateLight(MKLRenderer *renderer, int index, MKLLight light);

/**
 * @brief Get a light by index
 * @param renderer The renderer context
 * @param index Index of light
 * @return Pointer to light, or NULL if index invalid
 */
MKLAPI MKLLight* MKLGetLight(MKLRenderer *renderer, int index);

/**
 * @brief Enable or disable a light
 * @param renderer The renderer context
 * @param index Index of light
 * @param enabled Enable state
 */
MKLAPI void MKLSetLightEnabled(MKLRenderer *renderer, int index, bool enabled);

/**
 * @brief Get the number of lights in the scene
 * @param renderer The renderer context
 * @return Number of lights
 */
MKLAPI int MKLGetLightCount(MKLRenderer *renderer);

/**
 * @brief Remove all lights from the scene
 * @param renderer The renderer context
 */
MKLAPI void MKLClearLights(MKLRenderer *renderer);

// ========== Lighting Control ==========

/**
 * @brief Enable or disable lighting globally
 * @param renderer The renderer context
 * @param enabled Enable lighting
 */
MKLAPI void MKLEnableLighting(MKLRenderer *renderer, bool enabled);

/**
 * @brief Check if lighting is enabled
 * @param renderer The renderer context
 * @return true if lighting is enabled
 */
MKLAPI bool MKLIsLightingEnabled(MKLRenderer *renderer);

/**
 * @brief Set ambient light color (affects all objects)
 * @param renderer The renderer context
 * @param color Ambient color
 * @param intensity Ambient intensity
 */
MKLAPI void MKLSetAmbientLight(MKLRenderer *renderer, MKLColor color, float intensity);

#ifdef __cplusplus
}
#endif

#endif /* MKLLight_h */

