#import "Graphics/Metal/guli_metal.h"
#import "Graphics/Metal/guli_metal_shader.h"
#import "Graphics/guli_texture.h"
#import "Graphics/guli_shader_defines.h"
#import "Core/guli_file.h"
#import "Core/guli_hash.h"

#include <stdlib.h>
#include <string.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/* -----------------------------------------------------------------------------
 * Metal shader backend
 * ----------------------------------------------------------------------------- */

/* Default MSL shader - fullscreen triangle, color uniform */
static const char* default_msl =
    "#include <metal_stdlib>\n"
    "using namespace metal;\n"
    "struct Uniforms { float4 colDiffuse; };\n"
    "struct VertexOut { float4 position [[position]]; float4 color; };\n"
    "vertex VertexOut vertexMain(uint vid [[vertex_id]]) {\n"
    "    float2 positions[3] = { float2(-1,-1), float2(3,-1), float2(-1,3) };\n"
    "    VertexOut out;\n"
    "    out.position = float4(positions[vid], 0.0, 1.0);\n"
    "    out.color = float4(1.0);\n"
    "    return out;\n"
    "}\n"
    "fragment float4 fragmentMain(VertexOut in [[stage_in]], constant Uniforms& u [[buffer(0)]]) {\n"
    "    return u.colDiffuse * in.color;\n"
    "}\n";

_Thread_local static char g_metal_shader_error[GULI_SHADER_ERROR_MAX];

#define GULI_UNIFORM_HASH_EMPTY -1

typedef struct { char name[32]; int offset; } MetalUniformLoc;

typedef struct {
    MetalUniformLoc* entries;
    int count;
    int hashTable[GULI_UNIFORM_HASH_SIZE];
} MetalUniformHash;

static void MetalHashInsert(MetalUniformHash* h, const char* name, int offset)
{
    uint32_t idx = GuliHashFNV1a(name) % GULI_UNIFORM_HASH_SIZE;
    while (h->hashTable[idx] != GULI_UNIFORM_HASH_EMPTY)
        idx = (idx + 1) % GULI_UNIFORM_HASH_SIZE;
    h->hashTable[idx] = h->count;
    size_t len = strlen(name);
    if (len >= 31) len = 31;
    memcpy(h->entries[h->count].name, name, len);
    h->entries[h->count].name[len] = '\0';
    h->entries[h->count].offset = offset;
    h->count++;
}

static int MetalHashLookup(const MetalUniformHash* h, const char* name)
{
    uint32_t idx = GuliHashFNV1a(name) % GULI_UNIFORM_HASH_SIZE;
    for (int probe = 0; probe < GULI_UNIFORM_HASH_SIZE; probe++)
    {
        int ei = h->hashTable[idx];
        if (ei == GULI_UNIFORM_HASH_EMPTY) return -1;
        if (strcmp(h->entries[ei].name, name) == 0)
            return h->entries[ei].offset;
        idx = (idx + 1) % GULI_UNIFORM_HASH_SIZE;
    }
    return -1;
}

struct GuliShader {
    id<MTLRenderPipelineState> pipeline;
    id<MTLBuffer> uniformBuffer;
    id<MTLBuffer> vertexUniformBuffer;
    NSUInteger colorOffset;
    MetalUniformHash uniformHash;
    MetalUniformHash vertexUniformHash;
};

static void MetalBuildUniformHash(MetalUniformHash* outHash, NSArray<MTLArgument*>* args)
{
    outHash->entries = NULL;
    outHash->count = 0;
    for (int i = 0; i < GULI_UNIFORM_HASH_SIZE; i++)
        outHash->hashTable[i] = GULI_UNIFORM_HASH_EMPTY;
    if (!args) return;

    for (MTLArgument* arg in args)
    {
        if (arg.type != MTLArgumentTypeBuffer || arg.bufferDataType != MTLDataTypeStruct)
            continue;

        MTLStructType* st = arg.bufferStructType;
        if (!st || st.members.count == 0) continue;

        int cnt = (int)st.members.count;
        MetalUniformLoc* entries = (MetalUniformLoc*)calloc((size_t)cnt, sizeof(MetalUniformLoc));
        if (!entries) return;

        outHash->entries = entries;
        for (MTLStructMember* member in st.members)
        {
            if (outHash->count >= cnt) break;
            const char* n = [member.name UTF8String];
            if (n)
                MetalHashInsert(outHash, n, (int)member.offset);
        }
        break;
    }
}

static NSUInteger MetalFindColorOffset(NSArray<MTLArgument*>* args)
{
    if (!args) return 0;
    for (MTLArgument* arg in args)
    {
        if (arg.type != MTLArgumentTypeBuffer || arg.bufferDataType != MTLDataTypeStruct)
            continue;
        for (MTLStructMember* member in arg.bufferStructType.members)
        {
            if ([member.name isEqualToString:@(GULI_SHADER_UNIFORM_COLOR)])
                return member.offset;
        }
        break;
    }
    return 0;
}

static const char* kMetalVertexEntry = "vertexMain";
static const char* kMetalFragmentEntry = "fragmentMain";

GuliShader* MetalShaderLoadDefault(void)
{
    return MetalShaderLoadFromMemoryEx(default_msl, NULL, kMetalVertexEntry, kMetalFragmentEntry);
}

GuliShader* MetalShaderLoadFromMemory(const char* vsCode, const char* fsCode)
{
    return MetalShaderLoadFromMemoryEx(vsCode, fsCode, NULL, NULL);
}

GuliShader* MetalShaderLoadFromMemoryEx(const char* vsCode, const char* fsCode, const char* vertexName, const char* fragmentName)
{
    if (!vsCode && !fsCode)
        return MetalShaderLoadDefault();

    const char* vName = vertexName ? vertexName : kMetalVertexEntry;
    const char* fName = fragmentName ? fragmentName : kMetalFragmentEntry;
    const char* source = vsCode ? vsCode : fsCode;

    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_device) return NULL;

    NSError* err = nil;
    g_metal_shader_error[0] = '\0';
    id<MTLLibrary> lib = [m->_device newLibraryWithSource:@(source) options:nil error:&err];
    if (!lib)
    {
        const char* msg = err ? [[err localizedDescription] UTF8String] : "Unknown Metal library error";
        if (msg) { strncpy(g_metal_shader_error, msg, GULI_SHADER_ERROR_MAX - 1); g_metal_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0'; }
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, msg);
        return NULL;
    }

    id<MTLFunction> vs = [lib newFunctionWithName:@(vName)];
    id<MTLFunction> fs = [lib newFunctionWithName:@(fName)];
    if (!vs || !fs) return NULL;

    MTLRenderPipelineDescriptor* desc = [MTLRenderPipelineDescriptor new];
    desc.vertexFunction = vs;
    desc.fragmentFunction = fs;
    desc.colorAttachments[0].pixelFormat = m->_colorFormat;

    MTLRenderPipelineReflection* refl = nil;
    MTLPipelineOption opts = MTLPipelineOptionArgumentInfo | MTLPipelineOptionBufferTypeInfo;
    id<MTLRenderPipelineState> pipeline = [m->_device newRenderPipelineStateWithDescriptor:desc
                                                                                   options:opts
                                                                                reflection:&refl
                                                                                     error:&err];
    if (!pipeline)
    {
        const char* msg = err ? [[err localizedDescription] UTF8String] : "Unknown Metal pipeline error";
        if (msg) { strncpy(g_metal_shader_error, msg, GULI_SHADER_ERROR_MAX - 1); g_metal_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0'; }
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, msg);
        return NULL;
    }

    NSUInteger colorOffset = MetalFindColorOffset(refl.fragmentArguments);
    size_t uniformBufSize = (source == default_msl) ? 16 : 256;
    id<MTLBuffer> uniformBuffer = [m->_device newBufferWithLength:uniformBufSize options:MTLResourceStorageModeShared];

    id<MTLBuffer> vertexUniformBuffer = nil;
    for (MTLArgument* arg in refl.vertexArguments)
    {
        if (arg.type == MTLArgumentTypeBuffer && arg.bufferDataType == MTLDataTypeStruct)
        {
            vertexUniformBuffer = [m->_device newBufferWithLength:256 options:MTLResourceStorageModeShared];
            break;
        }
    }

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) return NULL;

    shader->pipeline = pipeline;
    shader->uniformBuffer = uniformBuffer;
    shader->vertexUniformBuffer = vertexUniformBuffer;
    shader->colorOffset = colorOffset;
    MetalBuildUniformHash(&shader->uniformHash, refl.fragmentArguments);
    MetalBuildUniformHash(&shader->vertexUniformHash, refl.vertexArguments);

    return shader;
}

GuliShader* MetalShaderLoadFromFile(const char* path, const char* unused)
{
    return MetalShaderLoadFromFileEx(path, unused, NULL, NULL);
}

GuliShader* MetalShaderLoadFromFileEx(const char* path, const char* unused, const char* vertexName, const char* fragmentName)
{
    (void)unused;
    if (!path) return NULL;

    g_metal_shader_error[0] = '\0';
    char* source = GuliLoadFileText(path);
    if (!source)
    {
        strncpy(g_metal_shader_error, "Failed to load shader file", GULI_SHADER_ERROR_MAX - 1);
        g_metal_shader_error[GULI_SHADER_ERROR_MAX - 1] = '\0';
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to load shader file");
        return NULL;
    }

    GuliShader* shader = MetalShaderLoadFromMemoryEx(source, NULL, vertexName, fragmentName);
    free(source);
    return shader;
}

void MetalShaderUnload(GuliShader* shader)
{
    if (!shader) return;
    shader->pipeline = nil;
    shader->uniformBuffer = nil;
    shader->vertexUniformBuffer = nil;
    free(shader->uniformHash.entries);
    shader->uniformHash.entries = NULL;
    shader->uniformHash.count = 0;
    free(shader->vertexUniformHash.entries);
    shader->vertexUniformHash.entries = NULL;
    shader->vertexUniformHash.count = 0;
    free(shader);
}

int MetalShaderIsValid(const GuliShader* shader)
{
    return (shader && shader->pipeline != nil) ? 1 : 0;
}

const char* MetalShaderGetCompileError(void)
{
    return (g_metal_shader_error[0] != '\0') ? g_metal_shader_error : NULL;
}

int MetalShaderGetLocation(const GuliShader* shader, const char* uniformName)
{
    if (!shader || !uniformName || !shader->uniformHash.entries) return -1;
    return MetalHashLookup(&shader->uniformHash, uniformName);
}

int MetalShaderGetVertexLocation(const GuliShader* shader, const char* uniformName)
{
    if (!shader || !uniformName || !shader->vertexUniformHash.entries) return -1;
    return MetalHashLookup(&shader->vertexUniformHash, uniformName);
}

int MetalShaderGetDefaultLocation(GuliShader* shader, GuliShaderLocationIndex idx)
{
    if (!shader) return -1;
    switch (idx)
    {
        case GULI_SHADER_LOC_COLOR: return (int)shader->colorOffset;
        case GULI_SHADER_LOC_MVP:   return -1; /* Not used in default */
        case GULI_SHADER_LOC_COUNT: return -1;
    }
    return -1;
}

void MetalShaderUse(GuliShader* shader)
{
    if (!shader || !shader->pipeline) return;
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_enc) return;

    [m->_enc setRenderPipelineState:shader->pipeline];
    if (shader->vertexUniformBuffer)
        [m->_enc setVertexBuffer:shader->vertexUniformBuffer offset:0 atIndex:0];
    [m->_enc setFragmentBuffer:shader->uniformBuffer offset:0 atIndex:0];
}

void MetalShaderSetFloat(GuliShader* restrict shader, int loc, float value)
{
    if (!shader || !shader->uniformBuffer || loc < 0) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    *ptr = value;
}

void MetalShaderSetVertexFloat(GuliShader* restrict shader, int loc, float value)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0) return;
    float* ptr = (float*)((char*)shader->vertexUniformBuffer.contents + loc);
    *ptr = value;
}

void MetalShaderSetVertexVec2(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->vertexUniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1];
}

void MetalShaderSetVertexVec3(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->vertexUniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1]; ptr[2] = v[2];
}

void MetalShaderSetVertexVec4(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->vertexUniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1]; ptr[2] = v[2]; ptr[3] = v[3];
}

void MetalShaderSetVertexInt(GuliShader* restrict shader, int loc, int value)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0) return;
    int* ptr = (int*)((char*)shader->vertexUniformBuffer.contents + loc);
    *ptr = value;
}

void MetalShaderSetVertexMatrix4(GuliShader* restrict shader, int loc, const float* restrict m)
{
    if (!shader || !shader->vertexUniformBuffer || loc < 0 || !m) return;
    memcpy((char*)shader->vertexUniformBuffer.contents + loc, m, 16 * sizeof(float));
}

void MetalShaderSetVec2(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->uniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1];
}

void MetalShaderSetVec3(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->uniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1]; ptr[2] = v[2];
}

void MetalShaderSetVec4(GuliShader* restrict shader, int loc, const float* restrict v)
{
    if (!shader || !shader->uniformBuffer || loc < 0 || !v) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1]; ptr[2] = v[2]; ptr[3] = v[3];
}

void MetalShaderSetInt(GuliShader* restrict shader, int loc, int value)
{
    if (!shader || !shader->uniformBuffer || loc < 0) return;
    int* ptr = (int*)((char*)shader->uniformBuffer.contents + loc);
    *ptr = value;
}

void MetalShaderSetMatrix4(GuliShader* restrict shader, int loc, const float* restrict m)
{
    if (!shader || !shader->uniformBuffer || loc < 0 || !m) return;
    memcpy((char*)shader->uniformBuffer.contents + loc, m, 16 * sizeof(float));
}

void MetalShaderSetColor(GuliShader* shader, int loc, GULI_COLOR color)
{
    MetalShaderSetVec4(shader, loc, color);
}

void MetalShaderSetTexture(GuliShader* shader, int loc, GuliTexture* texture)
{
    MetalShaderSetTextureEx(shader, loc, texture, 0);
}

void MetalShaderSetTextureEx(GuliShader* shader, int loc, GuliTexture* texture, int slot)
{
    (void)loc;
    if (!shader || !texture || !texture->_backend) return;
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_enc) return;

    id<MTLTexture> mtlTex = (__bridge id<MTLTexture>)texture->_backend;
    [m->_enc setFragmentTexture:mtlTex atIndex:(NSUInteger)slot];
}

#pragma clang diagnostic pop
