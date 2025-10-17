//
// MKLMaterial.h
// MetalLib - Material System
//
// Provides material properties for physically-based and traditional rendering
//

#ifndef MKLMaterial_h
#define MKLMaterial_h

#include "../Core/MKLCore.h"
#include "MKLColors.h"
#include "MKLTexture.h"
#include <simd/simd.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ========== Material Types ==========

/**
 * @brief Material shading model
 */
typedef enum MKLMaterialType {
    MKL_MATERIAL_STANDARD = 0,      ///< Standard Phong/Blinn-Phong shading
    MKL_MATERIAL_PBR,               ///< Physically-Based Rendering
    MKL_MATERIAL_UNLIT              ///< No lighting, just textures/colors
} MKLMaterialType;

/**
 * @brief Material structure containing rendering properties
 */
typedef struct MKLMaterial {
    MKLMaterialType type;           ///< Material shading model
    
    // Base colors (Standard/PBR)
    MKLColor albedo;                ///< Base color / Diffuse color
    MKLColor emissive;              ///< Emissive color (glowing)
    
    // Standard shading properties (Phong/Blinn-Phong)
    MKLColor ambient;               ///< Ambient color
    MKLColor specular;              ///< Specular color
    float shininess;                ///< Shininess/glossiness (1-1000)
    
    // PBR properties
    float metallic;                 ///< Metallic factor (0-1)
    float roughness;                ///< Roughness factor (0-1)
    float ao;                       ///< Ambient occlusion factor (0-1)
    
    // Transparency
    float opacity;                  ///< Opacity (0=transparent, 1=opaque)
    
    // Texture maps
    MKLTexture *albedoMap;          ///< Albedo/Diffuse texture
    MKLTexture *normalMap;          ///< Normal map for bump mapping
    MKLTexture *metallicMap;        ///< Metallic map (PBR)
    MKLTexture *roughnessMap;       ///< Roughness map (PBR)
    MKLTexture *aoMap;              ///< Ambient occlusion map
    MKLTexture *emissiveMap;        ///< Emissive map
    MKLTexture *specularMap;        ///< Specular map (Standard)
    
    // Flags
    bool useTextures;               ///< Use texture maps if available
    bool receiveShadows;            ///< Receive shadows from lights
    bool castShadows;               ///< Cast shadows
    
    // Internal
    void *_userData;                ///< User data pointer
} MKLMaterial;

// Forward declarations
typedef struct MKLRenderer MKLRenderer;
typedef struct MKLMesh MKLMesh;

// ========== Material Creation Functions ==========

/**
 * @brief Create a default material with white color
 * @return Default material
 */
MKLAPI MKLMaterial MKLCreateMaterial(void);

/**
 * @brief Create a material with a specific color
 * @param color Material color
 * @return Material with specified color
 */
MKLAPI MKLMaterial MKLCreateMaterialColor(MKLColor color);

/**
 * @brief Create a material from an albedo texture
 * @param texture Albedo texture
 * @return Material with texture
 */
MKLAPI MKLMaterial MKLCreateMaterialTexture(MKLTexture *texture);

/**
 * @brief Create a PBR material
 * @param albedo Base color
 * @param metallic Metallic factor (0-1)
 * @param roughness Roughness factor (0-1)
 * @return PBR material
 */
MKLAPI MKLMaterial MKLCreatePBRMaterial(MKLColor albedo, float metallic, float roughness);

/**
 * @brief Create an unlit material (no lighting calculations)
 * @param color Material color
 * @return Unlit material
 */
MKLAPI MKLMaterial MKLCreateUnlitMaterial(MKLColor color);

/**
 * @brief Create a material from a loaded model's material data
 * @param renderer The renderer context
 * @param modelPath Path to model file
 * @param materialIndex Index of material in model
 * @return Loaded material
 */
MKLAPI MKLMaterial MKLLoadMaterialFromModel(MKLRenderer *renderer, const char *modelPath, int materialIndex);

// ========== Material Property Setters ==========

/**
 * @brief Set material albedo color
 * @param material Material to modify
 * @param color Albedo color
 */
MKLAPI void MKLSetMaterialAlbedo(MKLMaterial *material, MKLColor color);

/**
 * @brief Set material albedo texture
 * @param material Material to modify
 * @param texture Albedo texture
 */
MKLAPI void MKLSetMaterialAlbedoMap(MKLMaterial *material, MKLTexture *texture);

/**
 * @brief Set material normal map
 * @param material Material to modify
 * @param texture Normal map texture
 */
MKLAPI void MKLSetMaterialNormalMap(MKLMaterial *material, MKLTexture *texture);

/**
 * @brief Set material PBR properties
 * @param material Material to modify
 * @param metallic Metallic factor (0-1)
 * @param roughness Roughness factor (0-1)
 */
MKLAPI void MKLSetMaterialPBR(MKLMaterial *material, float metallic, float roughness);

/**
 * @brief Set material shininess (for standard materials)
 * @param material Material to modify
 * @param shininess Shininess value (1-1000)
 */
MKLAPI void MKLSetMaterialShininess(MKLMaterial *material, float shininess);

/**
 * @brief Set material emissive color
 * @param material Material to modify
 * @param color Emissive color
 * @param intensity Emissive intensity
 */
MKLAPI void MKLSetMaterialEmissive(MKLMaterial *material, MKLColor color, float intensity);

/**
 * @brief Set material opacity
 * @param material Material to modify
 * @param opacity Opacity value (0-1)
 */
MKLAPI void MKLSetMaterialOpacity(MKLMaterial *material, float opacity);

// ========== Material Presets ==========

/**
 * @brief Create a metallic material preset
 * @param color Base metallic color
 * @return Metallic material
 */
MKLAPI MKLMaterial MKLMaterialMetal(MKLColor color);

/**
 * @brief Create a plastic material preset
 * @param color Base plastic color
 * @return Plastic material
 */
MKLAPI MKLMaterial MKLMaterialPlastic(MKLColor color);

/**
 * @brief Create a glass material preset
 * @param color Glass tint color
 * @return Glass material
 */
MKLAPI MKLMaterial MKLMaterialGlass(MKLColor color);

/**
 * @brief Create a wood material preset
 * @param texture Wood texture (optional)
 * @return Wood material
 */
MKLAPI MKLMaterial MKLMaterialWood(MKLTexture *texture);

/**
 * @brief Create a stone material preset
 * @param texture Stone texture (optional)
 * @return Stone material
 */
MKLAPI MKLMaterial MKLMaterialStone(MKLTexture *texture);

// ========== Material Cleanup ==========

/**
 * @brief Release material resources (does not unload textures)
 * @param material Material to release
 */
MKLAPI void MKLReleaseMaterial(MKLMaterial *material);

#ifdef __cplusplus
}
#endif

#endif /* MKLMaterial_h */

