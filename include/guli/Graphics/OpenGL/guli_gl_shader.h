#ifndef GULI_GL_SHADER_H
#define GULI_GL_SHADER_H

#include "Graphics/guli_shader.h"

struct GuliShader;

GuliShader* GlShaderLoadDefault(void);
GuliShader* GlShaderLoadFromMemory(const char* vsCode, const char* fsCode);
GuliShader* GlShaderLoadFromFile(const char* vertPath, const char* fragPath);
void GlShaderUnload(GuliShader* shader);
int GlShaderIsValid(const GuliShader* shader);
int GlShaderGetLocation(const GuliShader* shader, const char* uniformName);
void GlShaderUse(GuliShader* shader);
void GlShaderSetFloat(GuliShader* shader, int loc, float value);
void GlShaderSetVec2(GuliShader* shader, int loc, const float v[2]);
void GlShaderSetVec3(GuliShader* shader, int loc, const float v[3]);
void GlShaderSetVec4(GuliShader* shader, int loc, const float v[4]);
void GlShaderSetInt(GuliShader* shader, int loc, int value);
void GlShaderSetMatrix4(GuliShader* shader, int loc, const float m[16]);
void GlShaderSetColor(GuliShader* shader, int loc, GULI_COLOR color);
void GlShaderSetTexture(GuliShader* shader, int loc, unsigned int texId);
int GlShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx);

#endif // GULI_GL_SHADER_H
