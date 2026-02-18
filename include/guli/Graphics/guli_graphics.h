#ifndef GULI_GRAPHICS_H
#define GULI_GRAPHICS_H

#include "Core/guli_core.h"
#include "guli_defines.h"
#include "guli_shader.h"

/* Clear color; only valid between GuliBeginDraw and GuliEndDraw */
#define GULI_CLEAR_COLOR_IMPL(CLEAR, HAS_ACTIVE) \
    static inline void GuliClearColor(GULI_COLOR color) {     \
        if (HAS_ACTIVE()) CLEAR(color);                       \
    }

#ifdef GULI_BACKEND_METAL
#include "Metal/guli_metal.h"
#include "Metal/guli_metal_shader.h"
GULI_CLEAR_COLOR_IMPL(MetalClearColor, MetalHasActiveFrame)
static inline void GuliBeginDraw(void) { MetalBeginDraw(); }
static inline void GuliEndDraw(void) { MetalEndDraw(); }
static inline void GuliDrawFullscreen(void) { MetalDrawFullscreen(); }
static inline GuliShader* GuliShaderLoadDefault(void) { return MetalShaderLoadDefault(); }
static inline GuliShader* GuliShaderLoadFromMemory(const char* vs, const char* fs) { return MetalShaderLoadFromMemory(vs, fs); }
static inline GuliShader* GuliShaderLoadFromFile(const char* path1, const char* path2) { return MetalShaderLoadFromFile(path1, path2); }
static inline void GuliShaderUnload(GuliShader* s) { MetalShaderUnload(s); }
static inline int GuliShaderIsValid(const GuliShader* s) { return MetalShaderIsValid(s); }
static inline int GuliShaderGetLocation(const GuliShader* s, const char* n) { return MetalShaderGetLocation(s, n); }
static inline int GuliShaderGetDefaultLocation(GuliShader* s, GuliShaderLocationIndex i) { return MetalShaderGetDefaultLocation(s, i); }
static inline void GuliShaderUse(GuliShader* s) { MetalShaderUse(s); }
static inline void GuliShaderSetFloat(GuliShader* s, int l, float v) { MetalShaderSetFloat(s, l, v); }
static inline void GuliShaderSetVec2(GuliShader* s, int l, const float v[2]) { MetalShaderSetVec2(s, l, v); }
static inline void GuliShaderSetVec3(GuliShader* s, int l, const float v[3]) { MetalShaderSetVec3(s, l, v); }
static inline void GuliShaderSetVec4(GuliShader* s, int l, const float v[4]) { MetalShaderSetVec4(s, l, v); }
static inline void GuliShaderSetInt(GuliShader* s, int l, int v) { MetalShaderSetInt(s, l, v); }
static inline void GuliShaderSetMatrix4(GuliShader* s, int l, const float m[16]) { MetalShaderSetMatrix4(s, l, m); }
static inline void GuliShaderSetColor(GuliShader* s, int l, GULI_COLOR c) { MetalShaderSetColor(s, l, c); }
static inline void GuliShaderSetTexture(GuliShader* s, int l, unsigned int t) { MetalShaderSetTexture(s, l, t); }
#endif

#ifdef GULI_BACKEND_OPENGL
#include "OpenGL/guli_gl.h"
#include "OpenGL/guli_gl_shader.h"
GULI_CLEAR_COLOR_IMPL(GlClearColor, GlHasActiveFrame)
static inline void GuliBeginDraw(void) { GlBeginDraw(); }
static inline void GuliEndDraw(void) { GlEndDraw(); }
static inline void GuliDrawFullscreen(void) { GlDrawFullscreen(); }
static inline GuliShader* GuliShaderLoadDefault(void) { return GlShaderLoadDefault(); }
static inline GuliShader* GuliShaderLoadFromMemory(const char* vs, const char* fs) { return GlShaderLoadFromMemory(vs, fs); }
static inline GuliShader* GuliShaderLoadFromFile(const char* vertPath, const char* fragPath) { return GlShaderLoadFromFile(vertPath, fragPath); }
static inline void GuliShaderUnload(GuliShader* s) { GlShaderUnload(s); }
static inline int GuliShaderIsValid(const GuliShader* s) { return GlShaderIsValid(s); }
static inline int GuliShaderGetLocation(const GuliShader* s, const char* n) { return GlShaderGetLocation(s, n); }
static inline int GuliShaderGetDefaultLocation(GuliShader* s, GuliShaderLocationIndex i) { return GlShaderGetDefaultLocation(s, i); }
static inline void GuliShaderUse(GuliShader* s) { GlShaderUse(s); }
static inline void GuliShaderSetFloat(GuliShader* s, int l, float v) { GlShaderSetFloat(s, l, v); }
static inline void GuliShaderSetVec2(GuliShader* s, int l, const float v[2]) { GlShaderSetVec2(s, l, v); }
static inline void GuliShaderSetVec3(GuliShader* s, int l, const float v[3]) { GlShaderSetVec3(s, l, v); }
static inline void GuliShaderSetVec4(GuliShader* s, int l, const float v[4]) { GlShaderSetVec4(s, l, v); }
static inline void GuliShaderSetInt(GuliShader* s, int l, int v) { GlShaderSetInt(s, l, v); }
static inline void GuliShaderSetMatrix4(GuliShader* s, int l, const float m[16]) { GlShaderSetMatrix4(s, l, m); }
static inline void GuliShaderSetColor(GuliShader* s, int l, GULI_COLOR c) { GlShaderSetColor(s, l, c); }
static inline void GuliShaderSetTexture(GuliShader* s, int l, unsigned int t) { GlShaderSetTexture(s, l, t); }
#endif

#endif // GULI_GRAPHICS_H
