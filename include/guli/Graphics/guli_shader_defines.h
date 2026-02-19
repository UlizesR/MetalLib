#ifndef GULI_SHADER_DEFINES_H
#define GULI_SHADER_DEFINES_H

#define GULI_SHADER_ERROR_MAX 512

_Static_assert(GULI_SHADER_ERROR_MAX >= 256, "GULI_SHADER_ERROR_MAX too small for compile logs");

/* Default uniform/attribute names. Both GLSL and MSL shaders use these for compatibility. */
#define GULI_SHADER_UNIFORM_COLOR   "colDiffuse"
#define GULI_SHADER_UNIFORM_MVP     "mvp"
#define GULI_SHADER_UNIFORM_TEXTURE "texture0"

#define GULI_SHADER_ATTRIB_POSITION "vertexPosition"
#define GULI_SHADER_ATTRIB_COLOR    "vertexColor"
#define GULI_SHADER_ATTRIB_TEXCOORD "vertexTexCoord"

/* Uniform hash table tuning (Metal + OpenGL) */
#define GULI_UNIFORM_HASH_SIZE  32
#define GULI_UNIFORM_CACHE_MAX  64

#endif // GULI_SHADER_DEFINES_H
