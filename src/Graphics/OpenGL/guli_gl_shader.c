#include "Graphics/OpenGL/guli_gl.h"
#include "Graphics/OpenGL/guli_gl_shader.h"
#include "Graphics/guli_texture.h"
#include "Graphics/guli_shader_defines.h"
#include "Core/guli_file.h"
#include "Core/guli_hash.h"

#include <glad/glad.h>
#include <stdlib.h>
#include <string.h>

/* -----------------------------------------------------------------------------
 * OpenGL shader backend
 * ----------------------------------------------------------------------------- */

_Thread_local static char g_gl_shader_error[GULI_SHADER_ERROR_MAX];

static unsigned int g_gl_current_program;

static void GlEnsureProgram(unsigned int program)
{
    if (program != g_gl_current_program)
    {
        glUseProgram(program);
        g_gl_current_program = program;
    }
}

#define GULI_GL_HASH_EMPTY -1
#define GULI_GL_CACHE_MISS -2  /* distinct from -1 (valid: uniform optimized out) */

typedef struct {
    char name[32];
    int location;
} GlUniformCacheEntry;

typedef struct {
    GlUniformCacheEntry entries[GULI_UNIFORM_CACHE_MAX];
    int count;
    int hashTable[GULI_UNIFORM_HASH_SIZE];
} GlUniformCache;

struct GuliShader {
    unsigned int program;
    int locs[GULI_SHADER_LOC_COUNT];
    GlUniformCache uniformCache;
};

static int GlCacheLookup(GlUniformCache* cache, const char* name)
{
    uint32_t idx = GuliHashFNV1a(name) % GULI_UNIFORM_HASH_SIZE;
    for (int probe = 0; probe < GULI_UNIFORM_HASH_SIZE; probe++)
    {
        int ei = cache->hashTable[idx];
        if (ei == GULI_GL_HASH_EMPTY) return GULI_GL_CACHE_MISS;
        if (strcmp(cache->entries[ei].name, name) == 0)
            return cache->entries[ei].location;
        idx = (idx + 1) % GULI_UNIFORM_HASH_SIZE;
    }
    return GULI_GL_CACHE_MISS;
}

static int GlCacheInsert(GlUniformCache* cache, const char* name, int location)
{
    if (cache->count >= GULI_UNIFORM_CACHE_MAX) return location;
    uint32_t idx = GuliHashFNV1a(name) % GULI_UNIFORM_HASH_SIZE;
    while (cache->hashTable[idx] != GULI_GL_HASH_EMPTY)
        idx = (idx + 1) % GULI_UNIFORM_HASH_SIZE;
    int ei = cache->count++;
    size_t len = strlen(name);
    if (len >= 31) len = 31;
    memcpy(cache->entries[ei].name, name, len);
    cache->entries[ei].name[len] = '\0';
    cache->entries[ei].location = location;
    cache->hashTable[idx] = ei;
    return location;
}

static unsigned int compile_glsl(const char* source, unsigned int type)
{
    unsigned int shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    int success = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        char log[512];
        glGetShaderInfoLog(shader, sizeof(log), NULL, log);
        strncpy(g_gl_shader_error, log, GULI_SHADER_ERROR_MAX - 1);
        g_gl_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0';
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, log);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

static unsigned int link_program(unsigned int vs, unsigned int fs)
{
    unsigned int program = glCreateProgram();
    glAttachShader(program, vs);
    glAttachShader(program, fs);
    glLinkProgram(program);

    int success = 0;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success)
    {
        char log[512];
        glGetProgramInfoLog(program, sizeof(log), NULL, log);
        strncpy(g_gl_shader_error, log, GULI_SHADER_ERROR_MAX - 1);
        g_gl_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0';
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, log);
        glDeleteProgram(program);
        return 0;
    }
    glDetachShader(program, vs);
    glDetachShader(program, fs);
    glDeleteShader(vs);
    glDeleteShader(fs);
    return program;
}

/* Default vertex shader - fullscreen triangle */
static const char* default_vs_glsl =
    "#version 330 core\n"
    "out vec2 fragTexCoord;\n"
    "out vec4 fragColor;\n"
    "out vec3 vertexPosition;\n"
    "void main() {\n"
    "    vec2 positions[3] = vec2[](vec2(-1,-1), vec2(3,-1), vec2(-1,3));\n"
    "    vec2 uvs[3] = vec2[](vec2(0,0), vec2(2,0), vec2(0,2));\n"
    "    gl_Position = vec4(positions[gl_VertexID], 0.0, 1.0);\n"
    "    fragTexCoord = uvs[gl_VertexID];\n"
    "    fragColor = vec4(1.0);\n"
    "    vertexPosition = vec3(positions[gl_VertexID], 0.0);\n"
    "}\n";

/* Default fragment shader - output color uniform */
static const char* default_fs_glsl =
    "#version 330 core\n"
    "in vec2 fragTexCoord;\n"
    "in vec4 fragColor;\n"
    "in vec3 vertexPosition;\n"
    "uniform vec4 colDiffuse;\n"
    "out vec4 finalColor;\n"
    "void main() {\n"
    "    finalColor = colDiffuse * fragColor;\n"
    "}\n";

GuliShader* GlShaderLoadDefault(void)
{
    g_gl_shader_error[0] = '\0';
    unsigned int vs = compile_glsl(default_vs_glsl, GL_VERTEX_SHADER);
    if (!vs) return NULL;

    unsigned int fs = compile_glsl(default_fs_glsl, GL_FRAGMENT_SHADER);
    if (!fs) { glDeleteShader(vs); return NULL; }

    unsigned int program = link_program(vs, fs);
    if (!program) return NULL;

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) { glDeleteProgram(program); return NULL; }

    shader->program = program;
    for (int i = 0; i < GULI_UNIFORM_HASH_SIZE; i++)
        shader->uniformCache.hashTable[i] = GULI_GL_HASH_EMPTY;
    shader->locs[GULI_SHADER_LOC_COLOR] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_COLOR);
    shader->locs[GULI_SHADER_LOC_MVP] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_MVP);

    return shader;
}

GuliShader* GlShaderLoadFromMemory(const char* vsCode, const char* fsCode)
{
    g_gl_shader_error[0] = '\0';
    const char* vs = vsCode ? vsCode : default_vs_glsl;
    const char* fs = fsCode ? fsCode : default_fs_glsl;

    unsigned int vsId = compile_glsl(vs, GL_VERTEX_SHADER);
    if (!vsId) return NULL;

    unsigned int fsId = compile_glsl(fs, GL_FRAGMENT_SHADER);
    if (!fsId) { glDeleteShader(vsId); return NULL; }

    unsigned int program = link_program(vsId, fsId);
    if (!program) return NULL;

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) { glDeleteProgram(program); return NULL; }

    shader->program = program;
    for (int i = 0; i < GULI_UNIFORM_HASH_SIZE; i++)
        shader->uniformCache.hashTable[i] = GULI_GL_HASH_EMPTY;
    for (int i = 0; i < GULI_SHADER_LOC_COUNT; i++)
        shader->locs[i] = -1;
    shader->locs[GULI_SHADER_LOC_COLOR] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_COLOR);
    shader->locs[GULI_SHADER_LOC_MVP] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_MVP);

    return shader;
}

GuliShader* GlShaderLoadFromMemoryEx(const char* vsCode, const char* fsCode,
    const char* vertexName, const char* fragmentName)
{
    (void)vertexName;
    (void)fragmentName;
    return GlShaderLoadFromMemory(vsCode, fsCode);
}

GuliShader* GlShaderLoadFromFileEx(const char* vertPath, const char* fragPath,
    const char* vertexName, const char* fragmentName)
{
    (void)vertexName;
    (void)fragmentName;
    return GlShaderLoadFromFile(vertPath, fragPath);
}

GuliShader* GlShaderLoadFromFile(const char* vertPath, const char* fragPath)
{
    if (!vertPath || !fragPath) return NULL;

    g_gl_shader_error[0] = '\0';
    char* vs = GuliLoadFileText(vertPath);
    if (!vs)
    {
        strncpy(g_gl_shader_error, "Failed to load vertex shader file", GULI_SHADER_ERROR_MAX - 1);
        g_gl_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0';
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to load vertex shader file");
        return NULL;
    }

    char* fs = GuliLoadFileText(fragPath);
    if (!fs)
    {
        strncpy(g_gl_shader_error, "Failed to load fragment shader file", GULI_SHADER_ERROR_MAX - 1);
        g_gl_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0';
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to load fragment shader file");
        free(vs);
        return NULL;
    }

    GuliShader* shader = GlShaderLoadFromMemory(vs, fs);
    free(vs);
    free(fs);
    return shader;
}

void GlShaderUnload(GuliShader* shader)
{
    if (!shader) return;
    if (shader->program) glDeleteProgram(shader->program);
    free(shader);
}

int GlShaderIsValid(const GuliShader* shader)
{
    return (shader && shader->program) ? 1 : 0;
}

int GlShaderGetLocation(const GuliShader* shader, const char* uniformName)
{
    if (!shader || !shader->program || !uniformName) return -1;
    GlUniformCache* cache = (GlUniformCache*)&shader->uniformCache;
    int loc = GlCacheLookup(cache, uniformName);
    if (loc != GULI_GL_CACHE_MISS) return loc;
    loc = glGetUniformLocation(shader->program, uniformName);
    GlCacheInsert(cache, uniformName, loc);
    return loc;
}

int GlShaderGetVertexLocation(const GuliShader* shader, const char* uniformName)
{
    return GlShaderGetLocation(shader, uniformName);
}

void GlShaderUse(GuliShader* shader)
{
    unsigned int program = (shader && shader->program) ? shader->program : 0;
    if (program != g_gl_current_program)
    {
        glUseProgram(program);
        g_gl_current_program = program;
    }
}

void GlShaderSetFloat(GuliShader* restrict shader, int loc, float value)
{
    if (!shader || !shader->program || loc < 0) return;
    GlEnsureProgram(shader->program);
    glUniform1f(loc, value);
}

void GlShaderSetVec2(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->program || loc < 0 || !v) return;
    GlEnsureProgram(shader->program);
    glUniform2fv(loc, 1, v);
}

void GlShaderSetVec3(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->program || loc < 0 || !v) return;
    GlEnsureProgram(shader->program);
    glUniform3fv(loc, 1, v);
}

void GlShaderSetVec4(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->program || loc < 0 || !v) return;
    GlEnsureProgram(shader->program);
    glUniform4fv(loc, 1, v);
}

void GlShaderSetInt(GuliShader* restrict shader, int loc, int value)
{
    if (!shader || !shader->program || loc < 0) return;
    GlEnsureProgram(shader->program);
    glUniform1i(loc, value);
}

void GlShaderSetMatrix4(GuliShader* restrict shader, int loc, const float* restrict m)
{
    if (!shader || !shader->program || loc < 0 || !m) return;
    GlEnsureProgram(shader->program);
    glUniformMatrix4fv(loc, 1, GL_FALSE, m);
}

void GlShaderSetColor(GuliShader* restrict shader, int loc, GULI_COLOR color)
{
    if (!shader || !shader->program || loc < 0) return;
    GlEnsureProgram(shader->program);
    glUniform4fv(loc, 1, color);
}

void GlShaderSetTexture(GuliShader* shader, int loc, GuliTexture* texture)
{
    GlShaderSetTextureEx(shader, loc, texture, 0);
}

void GlShaderSetTextureEx(GuliShader* restrict shader, int loc, GuliTexture* texture, int slot)
{
    if (!shader || !shader->program || loc < 0 || !texture || !texture->_backend) return;
    GlEnsureProgram(shader->program);
    glUniform1i(loc, slot);
    glActiveTexture(GL_TEXTURE0 + (unsigned int)slot);
    glBindTexture(GL_TEXTURE_2D, (unsigned int)(uintptr_t)texture->_backend);
}

int GlShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx)
{
    if (!shader || idx < 0 || idx >= GULI_SHADER_LOC_COUNT) return -1;
    return shader->locs[idx];
}

const char* GlShaderGetCompileError(void)
{
    return (g_gl_shader_error[0] != '\0') ? g_gl_shader_error : NULL;
}
