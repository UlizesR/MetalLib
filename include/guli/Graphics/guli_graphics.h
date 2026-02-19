#ifndef GULI_GRAPHICS_H
#define GULI_GRAPHICS_H

#include "Core/guli_core.h"
#include "guli_defines.h"
#include "guli_shader.h"
#include "guli_texture.h"

/* Clear color; only valid between GuliBeginDraw and GuliEndDraw */
#define GULI_CLEAR_COLOR_IMPL(CLEAR, HAS_ACTIVE) \
    static inline void GuliClearColor(GULI_COLOR color) { \
        if (HAS_ACTIVE()) CLEAR(color); \
    }

#define GULI_SHADER_API_IMPL(PREFIX) \
    static inline GuliShader* GuliShaderLoadDefault(void) { return PREFIX##ShaderLoadDefault(); } \
    static inline GuliShader* GuliShaderLoadFromMemory(const char* vs, const char* fs) { return PREFIX##ShaderLoadFromMemory(vs, fs); } \
    static inline GuliShader* GuliShaderLoadFromMemoryEx(const char* vs, const char* fs, const char* vn, const char* fn) { return PREFIX##ShaderLoadFromMemoryEx(vs, fs, vn, fn); } \
    static inline GuliShader* GuliShaderLoadFromFile(const char* p1, const char* p2) { return PREFIX##ShaderLoadFromFile(p1, p2); } \
    static inline GuliShader* GuliShaderLoadFromFileEx(const char* p1, const char* p2, const char* vn, const char* fn) { return PREFIX##ShaderLoadFromFileEx(p1, p2, vn, fn); } \
    static inline void GuliShaderUnload(GuliShader* s) { PREFIX##ShaderUnload(s); } \
    static inline int GuliShaderIsValid(const GuliShader* s) { return PREFIX##ShaderIsValid(s); } \
    static inline int GuliShaderGetLocation(const GuliShader* s, const char* n) { return PREFIX##ShaderGetLocation(s, n); } \
    static inline int GuliShaderGetVertexLocation(const GuliShader* s, const char* n) { return PREFIX##ShaderGetVertexLocation(s, n); } \
    static inline int GuliShaderGetDefaultLocation(GuliShader* s, GuliShaderLocationIndex i) { return PREFIX##ShaderGetDefaultLocation(s, i); } \
    static inline void GuliShaderUse(GuliShader* s) { PREFIX##ShaderUse(s); } \
    static inline void GuliShaderSetFloat(GuliShader* s, int l, float v) { PREFIX##ShaderSetFloat(s, l, v); } \
    static inline void GuliShaderSetVec2(GuliShader* s, int l, const float v[2]) { PREFIX##ShaderSetVec2(s, l, v); } \
    static inline void GuliShaderSetVec3(GuliShader* s, int l, const float v[3]) { PREFIX##ShaderSetVec3(s, l, v); } \
    static inline void GuliShaderSetVec4(GuliShader* s, int l, const float v[4]) { PREFIX##ShaderSetVec4(s, l, v); } \
    static inline void GuliShaderSetInt(GuliShader* s, int l, int v) { PREFIX##ShaderSetInt(s, l, v); } \
    static inline void GuliShaderSetMatrix4(GuliShader* s, int l, const float m[16]) { PREFIX##ShaderSetMatrix4(s, l, m); } \
    static inline void GuliShaderSetColor(GuliShader* s, int l, GULI_COLOR c) { PREFIX##ShaderSetColor(s, l, c); } \
    static inline void GuliShaderSetTexture(GuliShader* s, int l, GuliTexture* t) { PREFIX##ShaderSetTexture(s, l, t); } \
    static inline void GuliShaderSetTextureEx(GuliShader* s, int l, GuliTexture* t, int slot) { PREFIX##ShaderSetTextureEx(s, l, t, slot); } \
    static inline const char* GuliShaderGetCompileError(void) { return PREFIX##ShaderGetCompileError(); }

#define GULI_SHADER_API_METAL_VERTEX \
    static inline void GuliShaderSetVertexFloat(GuliShader* s, int l, float v) { MetalShaderSetVertexFloat(s, l, v); } \
    static inline void GuliShaderSetVertexVec2(GuliShader* s, int l, const float v[2]) { MetalShaderSetVertexVec2(s, l, v); } \
    static inline void GuliShaderSetVertexVec3(GuliShader* s, int l, const float v[3]) { MetalShaderSetVertexVec3(s, l, v); } \
    static inline void GuliShaderSetVertexVec4(GuliShader* s, int l, const float v[4]) { MetalShaderSetVertexVec4(s, l, v); } \
    static inline void GuliShaderSetVertexInt(GuliShader* s, int l, int v) { MetalShaderSetVertexInt(s, l, v); } \
    static inline void GuliShaderSetVertexMatrix4(GuliShader* s, int l, const float m[16]) { MetalShaderSetVertexMatrix4(s, l, m); }

#define GULI_SHADER_API_GL_VERTEX \
    static inline void GuliShaderSetVertexFloat(GuliShader* s, int l, float v) { GlShaderSetFloat(s, l, v); } \
    static inline void GuliShaderSetVertexVec2(GuliShader* s, int l, const float v[2]) { GlShaderSetVec2(s, l, v); } \
    static inline void GuliShaderSetVertexVec3(GuliShader* s, int l, const float v[3]) { GlShaderSetVec3(s, l, v); } \
    static inline void GuliShaderSetVertexVec4(GuliShader* s, int l, const float v[4]) { GlShaderSetVec4(s, l, v); } \
    static inline void GuliShaderSetVertexInt(GuliShader* s, int l, int v) { GlShaderSetInt(s, l, v); } \
    static inline void GuliShaderSetVertexMatrix4(GuliShader* s, int l, const float m[16]) { GlShaderSetMatrix4(s, l, m); }

#ifdef GULI_BACKEND_METAL
#include "Metal/guli_metal.h"
#include "Metal/guli_metal_shader.h"
GULI_CLEAR_COLOR_IMPL(MetalClearColor, MetalHasActiveFrame)
static inline void GuliBeginDraw(void) { MetalBeginDraw(); }
static inline void GuliEndDraw(void) { MetalEndDraw(); }
static inline void GuliDrawFullscreen(void) { MetalDrawFullscreen(); }
GULI_SHADER_API_IMPL(Metal)
GULI_SHADER_API_METAL_VERTEX
#endif

#ifdef GULI_BACKEND_OPENGL
#include "OpenGL/guli_gl.h"
#include "OpenGL/guli_gl_shader.h"
GULI_CLEAR_COLOR_IMPL(GlClearColor, GlHasActiveFrame)
static inline void GuliBeginDraw(void) { GlBeginDraw(); }
static inline void GuliEndDraw(void) { GlEndDraw(); }
static inline void GuliDrawFullscreen(void) { GlDrawFullscreen(); }
GULI_SHADER_API_IMPL(Gl)
GULI_SHADER_API_GL_VERTEX
#endif

/** Type-generic scalar uniform setter. Use for float or int based on value type. */
#define GuliShaderSetScalar(shader, loc, value) \
    _Generic((value), float: GuliShaderSetFloat, int: GuliShaderSetInt)(shader, loc, value)

#endif // GULI_GRAPHICS_H
