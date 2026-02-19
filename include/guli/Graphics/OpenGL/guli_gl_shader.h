#ifndef GULI_GL_SHADER_H
#define GULI_GL_SHADER_H

#include "Graphics/guli_shader.h"
#include "Graphics/guli_texture.h"

struct GuliShader;

/* Load / unload */
GuliShader* GlShaderLoadDefault(void);
GuliShader* GlShaderLoadFromMemory(const char* vsCode, const char* fsCode);
GuliShader* GlShaderLoadFromMemoryEx(const char* vsCode, const char* fsCode,
    const char* vertexName, const char* fragmentName);
GuliShader* GlShaderLoadFromFile(const char* vertPath, const char* fragPath);
GuliShader* GlShaderLoadFromFileEx(const char* vertPath, const char* fragPath,
    const char* vertexName, const char* fragmentName);
void GlShaderUnload(GuliShader* shader);

/* Validation / location */
int GlShaderIsValid(const GuliShader* shader);
int GlShaderGetLocation(const GuliShader* shader, const char* uniformName);
int GlShaderGetVertexLocation(const GuliShader* shader, const char* uniformName);
int GlShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx);

/* Use / set uniforms */
void GlShaderUse(GuliShader* shader);
void GlShaderSetFloat(GuliShader* restrict shader, int loc, float value);
void GlShaderSetVec2(GuliShader* restrict shader, int loc, const float* restrict v);
void GlShaderSetVec3(GuliShader* restrict shader, int loc, const float* restrict v);
void GlShaderSetVec4(GuliShader* restrict shader, int loc, const float* restrict v);
void GlShaderSetInt(GuliShader* restrict shader, int loc, int value);
void GlShaderSetMatrix4(GuliShader* restrict shader, int loc, const float* restrict m);
void GlShaderSetColor(GuliShader* restrict shader, int loc, GULI_COLOR color);
void GlShaderSetTexture(GuliShader* shader, int loc, GuliTexture* texture);
void GlShaderSetTextureEx(GuliShader* restrict shader, int loc, GuliTexture* texture, int slot);

/** Returns the last shader compile/link error string, or NULL if none. */
const char* GlShaderGetCompileError(void);

#endif // GULI_GL_SHADER_H
