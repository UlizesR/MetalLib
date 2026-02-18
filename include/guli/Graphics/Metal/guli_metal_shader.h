#ifndef GULI_METAL_SHADER_H
#define GULI_METAL_SHADER_H

#include "Graphics/guli_shader.h"

struct GuliShader;

GuliShader* MetalShaderLoadDefault(void);
GuliShader* MetalShaderLoadFromMemory(const char* vsCode, const char* fsCode);
GuliShader* MetalShaderLoadFromFile(const char* path, const char* unused);
void MetalShaderUnload(GuliShader* shader);
int MetalShaderIsValid(const GuliShader* shader);
int MetalShaderGetLocation(const GuliShader* shader, const char* uniformName);
int MetalShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx);
void MetalShaderUse(GuliShader* shader);
void MetalShaderSetFloat(GuliShader* shader, int loc, float value);
void MetalShaderSetVec2(GuliShader* shader, int loc, const float v[2]);
void MetalShaderSetVec3(GuliShader* shader, int loc, const float v[3]);
void MetalShaderSetVec4(GuliShader* shader, int loc, const float v[4]);
void MetalShaderSetInt(GuliShader* shader, int loc, int value);
void MetalShaderSetMatrix4(GuliShader* shader, int loc, const float m[16]);
void MetalShaderSetColor(GuliShader* shader, int loc, GULI_COLOR color);
void MetalShaderSetTexture(GuliShader* shader, int loc, unsigned int texId);

#endif // GULI_METAL_SHADER_H
