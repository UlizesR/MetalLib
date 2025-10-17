//
// MKLMaterial.m
// MetalLib - Material System Implementation
//

#import "MKLMaterial.h"
#import "MKLRenderer.h"
#import <Foundation/Foundation.h>

// ========== Material Creation Functions ==========

MKLMaterial MKLCreateMaterial(void) {
    MKLMaterial material = {0};
    material.type = MKL_MATERIAL_STANDARD;
    material.albedo = MKL_COLOR_WHITE;
    material.emissive = MKL_COLOR_BLACK;
    material.ambient = (MKLColor){0.2f, 0.2f, 0.2f, 1.0f};
    material.specular = (MKLColor){0.5f, 0.5f, 0.5f, 1.0f};
    material.shininess = 32.0f;
    material.metallic = 0.0f;
    material.roughness = 0.5f;
    material.ao = 1.0f;
    material.opacity = 1.0f;
    material.useTextures = true;
    material.receiveShadows = true;
    material.castShadows = true;
    material.albedoMap = NULL;
    material.normalMap = NULL;
    material.metallicMap = NULL;
    material.roughnessMap = NULL;
    material.aoMap = NULL;
    material.emissiveMap = NULL;
    material.specularMap = NULL;
    material._userData = NULL;
    return material;
}

MKLMaterial MKLCreateMaterialColor(MKLColor color) {
    MKLMaterial material = MKLCreateMaterial();
    material.albedo = color;
    return material;
}

MKLMaterial MKLCreateMaterialTexture(MKLTexture *texture) {
    MKLMaterial material = MKLCreateMaterial();
    material.albedoMap = texture;
    return material;
}

MKLMaterial MKLCreatePBRMaterial(MKLColor albedo, float metallic, float roughness) {
    MKLMaterial material = MKLCreateMaterial();
    material.type = MKL_MATERIAL_PBR;
    material.albedo = albedo;
    material.metallic = metallic;
    material.roughness = roughness;
    return material;
}

MKLMaterial MKLCreateUnlitMaterial(MKLColor color) {
    MKLMaterial material = MKLCreateMaterial();
    material.type = MKL_MATERIAL_UNLIT;
    material.albedo = color;
    return material;
}

MKLMaterial MKLLoadMaterialFromModel(MKLRenderer *renderer, const char *modelPath, int materialIndex) {
    // This would load material from a model file
    // For now, return default material
    // TODO: Implement model material loading
    (void)renderer;
    (void)modelPath;
    (void)materialIndex;
    return MKLCreateMaterial();
}

// ========== Material Property Setters ==========

void MKLSetMaterialAlbedo(MKLMaterial *material, MKLColor color) {
    if (material) {
        material->albedo = color;
    }
}

void MKLSetMaterialAlbedoMap(MKLMaterial *material, MKLTexture *texture) {
    if (material) {
        material->albedoMap = texture;
    }
}

void MKLSetMaterialNormalMap(MKLMaterial *material, MKLTexture *texture) {
    if (material) {
        material->normalMap = texture;
    }
}

void MKLSetMaterialPBR(MKLMaterial *material, float metallic, float roughness) {
    if (material) {
        material->metallic = metallic;
        material->roughness = roughness;
    }
}

void MKLSetMaterialShininess(MKLMaterial *material, float shininess) {
    if (material) {
        material->shininess = shininess;
    }
}

void MKLSetMaterialEmissive(MKLMaterial *material, MKLColor color, float intensity) {
    if (material) {
        material->emissive = (MKLColor){
            color.x * intensity,
            color.y * intensity,
            color.z * intensity,
            color.w
        };
    }
}

void MKLSetMaterialOpacity(MKLMaterial *material, float opacity) {
    if (material) {
        material->opacity = opacity;
    }
}

// ========== Material Presets ==========

MKLMaterial MKLMaterialMetal(MKLColor color) {
    MKLMaterial material = MKLCreatePBRMaterial(color, 1.0f, 0.2f);
    material.specular = MKL_COLOR_WHITE;
    return material;
}

MKLMaterial MKLMaterialPlastic(MKLColor color) {
    MKLMaterial material = MKLCreatePBRMaterial(color, 0.0f, 0.5f);
    material.shininess = 64.0f;
    return material;
}

MKLMaterial MKLMaterialGlass(MKLColor color) {
    MKLMaterial material = MKLCreatePBRMaterial(color, 0.0f, 0.1f);
    material.opacity = 0.3f;
    material.shininess = 128.0f;
    return material;
}

MKLMaterial MKLMaterialWood(MKLTexture *texture) {
    MKLMaterial material = MKLCreatePBRMaterial(MKL_COLOR_WHITE, 0.0f, 0.8f);
    material.albedoMap = texture;
    return material;
}

MKLMaterial MKLMaterialStone(MKLTexture *texture) {
    MKLMaterial material = MKLCreatePBRMaterial(MKL_COLOR_WHITE, 0.0f, 0.9f);
    material.albedoMap = texture;
    return material;
}

// ========== Material Cleanup ==========

void MKLReleaseMaterial(MKLMaterial *material) {
    if (material) {
        // Note: We don't unload textures here as they might be shared
        // User is responsible for managing texture lifetimes
        material->_userData = NULL;
    }
}

