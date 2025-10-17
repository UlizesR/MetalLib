//
// MKLLight.m
// MetalLib - Lighting System Implementation
//

#import "MKLLight.h"
#import "MKLRenderer.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

// Define maximum number of lights
#define MKL_MAX_LIGHTS 8

// Light storage structure (internal)
typedef struct MKLLightManager {
    MKLLight lights[MKL_MAX_LIGHTS];
    int lightCount;
    bool lightingEnabled;
    MKLColor ambientColor;
    float ambientIntensity;
} MKLLightManager;

// Add light manager to renderer (we'll need to update MKLRenderer.h later)
static MKLLightManager* GetLightManager(MKLRenderer *renderer) {
    // For now, we'll create a global light manager
    // TODO: Move this into MKLRenderer structure
    static MKLLightManager manager = {
        .lightCount = 0,
        .lightingEnabled = true,
        .ambientColor = {0.1f, 0.1f, 0.1f, 1.0f},
        .ambientIntensity = 0.2f
    };
    return &manager;
}

// ========== Light Creation Functions ==========

MKLLight MKLCreateAmbientLight(MKLColor color, float intensity) {
    MKLLight light = {0};
    light.type = MKL_LIGHT_AMBIENT;
    light.enabled = true;
    light.color = color;
    light.intensity = intensity;
    light.position = (vector_float3){0, 0, 0};
    light.direction = (vector_float3){0, -1, 0};
    light.constantAttenuation = 1.0f;
    light.linearAttenuation = 0.0f;
    light.quadraticAttenuation = 0.0f;
    light.innerConeAngle = 0.0f;
    light.outerConeAngle = 0.0f;
    return light;
}

MKLLight MKLCreateDirectionalLight(vector_float3 direction, MKLColor color, float intensity) {
    MKLLight light = {0};
    light.type = MKL_LIGHT_DIRECTIONAL;
    light.enabled = true;
    light.color = color;
    light.intensity = intensity;
    light.position = (vector_float3){0, 0, 0};
    light.direction = simd_normalize(direction);
    light.constantAttenuation = 1.0f;
    light.linearAttenuation = 0.0f;
    light.quadraticAttenuation = 0.0f;
    light.innerConeAngle = 0.0f;
    light.outerConeAngle = 0.0f;
    return light;
}

MKLLight MKLCreatePointLight(vector_float3 position, MKLColor color, float intensity, float range) {
    MKLLight light = {0};
    light.type = MKL_LIGHT_POINT;
    light.enabled = true;
    light.color = color;
    light.intensity = intensity;
    light.position = position;
    light.direction = (vector_float3){0, -1, 0};
    
    // Calculate attenuation based on range
    if (range > 0.0f) {
        light.constantAttenuation = 1.0f;
        light.linearAttenuation = 2.0f / range;
        light.quadraticAttenuation = 1.0f / (range * range);
    } else {
        light.constantAttenuation = 1.0f;
        light.linearAttenuation = 0.0f;
        light.quadraticAttenuation = 0.0f;
    }
    
    light.innerConeAngle = 0.0f;
    light.outerConeAngle = 0.0f;
    return light;
}

MKLLight MKLCreateSpotLight(vector_float3 position, 
                             vector_float3 direction,
                             MKLColor color, 
                             float intensity,
                             float innerAngle,
                             float outerAngle) {
    MKLLight light = {0};
    light.type = MKL_LIGHT_SPOT;
    light.enabled = true;
    light.color = color;
    light.intensity = intensity;
    light.position = position;
    light.direction = simd_normalize(direction);
    light.constantAttenuation = 1.0f;
    light.linearAttenuation = 0.09f;
    light.quadraticAttenuation = 0.032f;
    light.innerConeAngle = innerAngle;
    light.outerConeAngle = outerAngle;
    return light;
}

// ========== Light Management Functions ==========

int MKLAddLight(MKLRenderer *renderer, MKLLight light) {
    if (!renderer) {
        return -1;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    
    if (manager->lightCount >= MKL_MAX_LIGHTS) {
        NSLog(@"Warning: Maximum number of lights (%d) reached", MKL_MAX_LIGHTS);
        return -1;
    }
    
    int index = manager->lightCount;
    manager->lights[index] = light;
    manager->lightCount++;
    
    return index;
}

void MKLRemoveLight(MKLRenderer *renderer, int index) {
    if (!renderer) {
        return;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    
    if (index < 0 || index >= manager->lightCount) {
        return;
    }
    
    // Shift lights down
    for (int i = index; i < manager->lightCount - 1; i++) {
        manager->lights[i] = manager->lights[i + 1];
    }
    
    manager->lightCount--;
}

void MKLUpdateLight(MKLRenderer *renderer, int index, MKLLight light) {
    if (!renderer) {
        return;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    
    if (index < 0 || index >= manager->lightCount) {
        return;
    }
    
    manager->lights[index] = light;
}

MKLLight* MKLGetLight(MKLRenderer *renderer, int index) {
    if (!renderer) {
        return NULL;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    
    if (index < 0 || index >= manager->lightCount) {
        return NULL;
    }
    
    return &manager->lights[index];
}

void MKLSetLightEnabled(MKLRenderer *renderer, int index, bool enabled) {
    MKLLight *light = MKLGetLight(renderer, index);
    if (light) {
        light->enabled = enabled;
    }
}

int MKLGetLightCount(MKLRenderer *renderer) {
    if (!renderer) {
        return 0;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    return manager->lightCount;
}

void MKLClearLights(MKLRenderer *renderer) {
    if (!renderer) {
        return;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    manager->lightCount = 0;
}

// ========== Lighting Control ==========

void MKLEnableLighting(MKLRenderer *renderer, bool enabled) {
    if (!renderer) {
        return;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    manager->lightingEnabled = enabled;
}

bool MKLIsLightingEnabled(MKLRenderer *renderer) {
    if (!renderer) {
        return false;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    return manager->lightingEnabled;
}

void MKLSetAmbientLight(MKLRenderer *renderer, MKLColor color, float intensity) {
    if (!renderer) {
        return;
    }
    
    MKLLightManager *manager = GetLightManager(renderer);
    manager->ambientColor = color;
    manager->ambientIntensity = intensity;
}

