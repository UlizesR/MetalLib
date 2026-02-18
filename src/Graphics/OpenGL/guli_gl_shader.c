#include "Graphics/OpenGL/guli_gl.h"
#include "Graphics/OpenGL/guli_gl_shader.h"
#include "Graphics/guli_shader_defines.h"
#include "Core/guli_file.h"

#include <glad/glad.h>
#include <stdlib.h>
#include <string.h>

struct GuliShader {
    unsigned int program;
    int locs[GULI_SHADER_LOC_COUNT];
};

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
    unsigned int vs = compile_glsl(default_vs_glsl, GL_VERTEX_SHADER);
    if (!vs) return NULL;

    unsigned int fs = compile_glsl(default_fs_glsl, GL_FRAGMENT_SHADER);
    if (!fs) { glDeleteShader(vs); return NULL; }

    unsigned int program = link_program(vs, fs);
    if (!program) return NULL;

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) { glDeleteProgram(program); return NULL; }

    shader->program = program;
    shader->locs[GULI_SHADER_LOC_COLOR] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_COLOR);
    shader->locs[GULI_SHADER_LOC_MVP] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_MVP);

    return shader;
}

GuliShader* GlShaderLoadFromMemory(const char* vsCode, const char* fsCode)
{
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
    for (int i = 0; i < GULI_SHADER_LOC_COUNT; i++)
        shader->locs[i] = -1;
    shader->locs[GULI_SHADER_LOC_COLOR] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_COLOR);
    shader->locs[GULI_SHADER_LOC_MVP] = glGetUniformLocation(program, GULI_SHADER_UNIFORM_MVP);

    return shader;
}

GuliShader* GlShaderLoadFromFile(const char* vertPath, const char* fragPath)
{
    if (!vertPath || !fragPath) return NULL;

    char* vs = GuliLoadFileText(vertPath);
    if (!vs)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to load vertex shader file");
        return NULL;
    }

    char* fs = GuliLoadFileText(fragPath);
    if (!fs)
    {
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
    return glGetUniformLocation(shader->program, uniformName);
}

void GlShaderUse(GuliShader* shader)
{
    if (shader && shader->program)
        glUseProgram(shader->program);
    else
        glUseProgram(0);
}

void GlShaderSetFloat(GuliShader* shader, int loc, float value)
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform1f(loc, value);
}

void GlShaderSetVec2(GuliShader* shader, int loc, const float v[2])
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform2fv(loc, 1, v);
}

void GlShaderSetVec3(GuliShader* shader, int loc, const float v[3])
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform3fv(loc, 1, v);
}

void GlShaderSetVec4(GuliShader* shader, int loc, const float v[4])
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform4fv(loc, 1, v);
}

void GlShaderSetInt(GuliShader* shader, int loc, int value)
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform1i(loc, value);
}

void GlShaderSetMatrix4(GuliShader* shader, int loc, const float m[16])
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniformMatrix4fv(loc, 1, GL_FALSE, m);
}

void GlShaderSetColor(GuliShader* shader, int loc, GULI_COLOR color)
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform4fv(loc, 1, color);
}

void GlShaderSetTexture(GuliShader* shader, int loc, unsigned int texId)
{
    if (!shader || !shader->program || loc < 0) return;
    glUseProgram(shader->program);
    glUniform1i(loc, 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texId);
}

int GlShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx)
{
    if (!shader || idx < 0 || idx >= GULI_SHADER_LOC_COUNT) return -1;
    return shader->locs[idx];
}
