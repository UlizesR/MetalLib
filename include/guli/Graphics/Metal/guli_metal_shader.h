#ifndef GULI_METAL_SHADER_H
#define GULI_METAL_SHADER_H

#include "Graphics/guli_shader.h"
#include "Graphics/guli_texture.h"

struct GuliShader;

/* Load / unload */
GuliShader* MetalShaderLoadDefault(void);
GuliShader* MetalShaderLoadFromMemory(const char* vsCode, const char* fsCode);
GuliShader* MetalShaderLoadFromMemoryEx(const char* vsCode, const char* fsCode, const char* vertexName, const char* fragmentName);
GuliShader* MetalShaderLoadFromFile(const char* path, const char* unused);
GuliShader* MetalShaderLoadFromFileEx(const char* path, const char* unused, const char* vertexName, const char* fragmentName);
void MetalShaderUnload(GuliShader* shader);

/* Validation / location */
int MetalShaderIsValid(const GuliShader* shader);
int MetalShaderGetLocation(const GuliShader* shader, const char* uniformName);
int MetalShaderGetVertexLocation(const GuliShader* shader, const char* uniformName);
int MetalShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx);

/* Use / set uniforms */
void MetalShaderUse(GuliShader* shader);
void MetalShaderSetFloat(GuliShader* restrict shader, int loc, float value);
void MetalShaderSetVec2(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetVec3(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetVec4(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetInt(GuliShader* restrict shader, int loc, int value);
void MetalShaderSetMatrix4(GuliShader* restrict shader, int loc, const float* restrict m);
void MetalShaderSetColor(GuliShader* restrict shader, int loc, GULI_COLOR color);
void MetalShaderSetTexture(GuliShader* shader, int loc, GuliTexture* texture);
void MetalShaderSetTextureEx(GuliShader* shader, int loc, GuliTexture* texture, int slot);
void MetalShaderSetVertexFloat(GuliShader* restrict shader, int loc, float value);
void MetalShaderSetVertexVec2(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetVertexVec3(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetVertexVec4(GuliShader* restrict shader, int loc, const float* restrict v);
void MetalShaderSetVertexInt(GuliShader* restrict shader, int loc, int value);
void MetalShaderSetVertexMatrix4(GuliShader* restrict shader, int loc, const float* restrict m);

/** Returns the last shader compile/link error string, or NULL if none. */
const char* MetalShaderGetCompileError(void);

#endif // GULI_METAL_SHADER_H
