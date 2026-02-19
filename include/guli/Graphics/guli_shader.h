#ifndef GULI_SHADER_H
#define GULI_SHADER_H

#include "Core/guli_core.h"
#include "guli_defines.h"

/* Opaque shader handle. Backend-specific data inside. */
struct GuliShader;
typedef struct GuliShader GuliShader;

/* Uniform data types (matches GLSL/Metal scalar/vector types) */
typedef enum {
    GULI_SHADER_UNIFORM_FLOAT,
    GULI_SHADER_UNIFORM_VEC2,
    GULI_SHADER_UNIFORM_VEC3,
    GULI_SHADER_UNIFORM_VEC4,
    GULI_SHADER_UNIFORM_INT,
    GULI_SHADER_UNIFORM_MAT4,
    GULI_SHADER_UNIFORM_SAMPLER2D,
} GuliShaderUniformType;

/* Default shader location indices (for built-in uniforms) */
typedef enum {
    GULI_SHADER_LOC_COLOR = 0,
    GULI_SHADER_LOC_MVP,
    GULI_SHADER_LOC_COUNT,
} GuliShaderLocationIndex;

_Static_assert(GULI_SHADER_LOC_COUNT >= 2, "GULI_SHADER_LOC_COUNT must include color and MVP");

#endif // GULI_SHADER_H
