#import "Graphics/Metal/guli_metal.h"
#import "Graphics/Metal/guli_metal_shader.h"
#import "Graphics/guli_shader_defines.h"
#import "Core/guli_file.h"

#include <stdlib.h>
#include <string.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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

typedef struct { char name[32]; int offset; } MetalUniformLoc;

struct GuliShader {
    id<MTLRenderPipelineState> pipeline;
    id<MTLBuffer> uniformBuffer;
    NSUInteger colorOffset;
    MetalUniformLoc* uniformMap;
    int uniformMapCount;
};

static void MetalBuildUniformMap(GuliShader* shader, MTLRenderPipelineReflection* refl)
{
    if (!shader || !refl) return;

    for (MTLArgument* arg in refl.fragmentArguments)
    {
        if (arg.type != MTLArgumentTypeBuffer || arg.bufferDataType != MTLDataTypeStruct)
            continue;

        MTLStructType* st = arg.bufferStructType;
        if (!st || st.members.count == 0) continue;

        shader->uniformMapCount = (int)st.members.count;
        shader->uniformMap = (MetalUniformLoc*)calloc((size_t)shader->uniformMapCount, sizeof(MetalUniformLoc));
        if (!shader->uniformMap) { shader->uniformMapCount = 0; return; }

        int i = 0;
        for (MTLStructMember* member in st.members)
        {
            if (i >= shader->uniformMapCount) break;
            const char* n = [member.name UTF8String];
            if (n)
            {
                size_t len = strlen(n);
                if (len >= sizeof(shader->uniformMap[i].name)) len = sizeof(shader->uniformMap[i].name) - 1;
                memcpy(shader->uniformMap[i].name, n, len);
                shader->uniformMap[i].name[len] = '\0';
            }
            shader->uniformMap[i].offset = (int)member.offset;
            i++;
        }
        break;
    }
}

GuliShader* MetalShaderLoadDefault(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_device) return NULL;

    NSError* err = nil;
    id<MTLLibrary> lib = [m->_device newLibraryWithSource:@(default_msl) options:nil error:&err];
    if (!lib)
    {
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, [[err localizedDescription] UTF8String]);
        return NULL;
    }

    id<MTLFunction> vs = [lib newFunctionWithName:@"vertexMain"];
    id<MTLFunction> fs = [lib newFunctionWithName:@"fragmentMain"];
    if (!vs || !fs) { return NULL; }

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
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, [[err localizedDescription] UTF8String]);
        return NULL;
    }

    /* Find colDiffuse offset and build uniform map from reflection */
    NSUInteger colorOffset = 0;
    for (MTLArgument* arg in refl.fragmentArguments)
    {
        if (arg.type == MTLArgumentTypeBuffer && arg.bufferDataType == MTLDataTypeStruct)
        {
            for (MTLStructMember* member in arg.bufferStructType.members)
            {
                if ([member.name isEqualToString:@"colDiffuse"])
                {
                    colorOffset = member.offset;
                    break;
                }
            }
            break;
        }
    }

    /* Uniform buffer: just the Uniforms struct (16 bytes for float4) */
    id<MTLBuffer> uniformBuffer = [m->_device newBufferWithLength:16 options:MTLResourceStorageModeShared];

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) { return NULL; }

    shader->pipeline = pipeline;
    shader->uniformBuffer = uniformBuffer;
    shader->colorOffset = colorOffset;
    MetalBuildUniformMap(shader, refl);

    return shader;
}

GuliShader* MetalShaderLoadFromMemory(const char* vsCode, const char* fsCode)
{
    /* For custom Metal shaders: user passes full MSL. vsCode = vertex function name/source, fsCode = fragment.
       Simplified: treat vsCode as optional (vertex), fsCode as optional (fragment). If both NULL, use default.
       For Metal, a single MSL source can define both. So we accept: (fullMSL, NULL) or (NULL, fullMSL) or (NULL,NULL)=default.
       If vsCode provided, use it as the main source. If only fsCode, use it. Metal compiles from one source. */
    if (!vsCode && !fsCode)
        return MetalShaderLoadDefault();

    const char* source = vsCode ? vsCode : fsCode;
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_device) return NULL;

    NSError* err = nil;
    id<MTLLibrary> lib = [m->_device newLibraryWithSource:@(source) options:nil error:&err];
    if (!lib)
    {
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, [[err localizedDescription] UTF8String]);
        return NULL;
    }

    /* Assume vertexMain and fragmentMain - user's custom MSL must use these names or we need to make it configurable */
    id<MTLFunction> vs = [lib newFunctionWithName:@"vertexMain"];
    id<MTLFunction> fs = [lib newFunctionWithName:@"fragmentMain"];
    if (!vs || !fs) { return NULL; }

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
        if (err) GULI_PRINT_ERROR(GULI_ERROR_FAILED, [[err localizedDescription] UTF8String]);
        return NULL;
    }

    NSUInteger colorOffset = 0;
    for (MTLArgument* arg in refl.fragmentArguments)
    {
        if (arg.type == MTLArgumentTypeBuffer && arg.bufferDataType == MTLDataTypeStruct)
        {
            for (MTLStructMember* member in arg.bufferStructType.members)
            {
                if ([member.name isEqualToString:@(GULI_SHADER_UNIFORM_COLOR)])
                {
                    colorOffset = member.offset;
                    break;
                }
            }
            break;
        }
    }

    id<MTLBuffer> uniformBuffer = [m->_device newBufferWithLength:256 options:MTLResourceStorageModeShared];

    GuliShader* shader = calloc(1, sizeof(GuliShader));
    if (!shader) { return NULL; }

    shader->pipeline = pipeline;
    shader->uniformBuffer = uniformBuffer;
    shader->colorOffset = colorOffset;
    MetalBuildUniformMap(shader, refl);

    return shader;
}

GuliShader* MetalShaderLoadFromFile(const char* path, const char* unused)
{
    (void)unused;
    if (!path) return NULL;

    char* source = GuliLoadFileText(path);
    if (!source)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to load shader file");
        return NULL;
    }

    GuliShader* shader = MetalShaderLoadFromMemory(source, NULL);
    free(source);
    return shader;
}

void MetalShaderUnload(GuliShader* shader)
{
    if (!shader) return;
    shader->pipeline = nil;
    shader->uniformBuffer = nil;
    free(shader->uniformMap);
    shader->uniformMap = NULL;
    shader->uniformMapCount = 0;
    free(shader);
}

int MetalShaderIsValid(const GuliShader* shader)
{
    return (shader && shader->pipeline != nil) ? 1 : 0;
}

int MetalShaderGetLocation(const GuliShader* shader, const char* uniformName)
{
    if (!shader || !uniformName || !shader->uniformMap) return -1;

    for (int i = 0; i < shader->uniformMapCount; i++)
    {
        if (strcmp(shader->uniformMap[i].name, uniformName) == 0)
            return shader->uniformMap[i].offset;
    }
    return -1;
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
    [m->_enc setFragmentBuffer:shader->uniformBuffer offset:0 atIndex:0];
}

void MetalShaderSetFloat(GuliShader* shader, int loc, float value)
{
    if (!shader || !shader->uniformBuffer || loc < 0) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    *ptr = value;
}

void MetalShaderSetVec2(GuliShader* shader, int loc, const float v[2])
{
    (void)shader; (void)loc; (void)v;
}

void MetalShaderSetVec3(GuliShader* shader, int loc, const float v[3])
{
    (void)shader; (void)loc; (void)v;
}

void MetalShaderSetVec4(GuliShader* shader, int loc, const float v[4])
{
    if (!shader || !shader->uniformBuffer || loc < 0) return;
    float* ptr = (float*)((char*)shader->uniformBuffer.contents + loc);
    ptr[0] = v[0]; ptr[1] = v[1]; ptr[2] = v[2]; ptr[3] = v[3];
}

void MetalShaderSetInt(GuliShader* shader, int loc, int value)
{
    (void)shader; (void)loc; (void)value;
}

void MetalShaderSetMatrix4(GuliShader* shader, int loc, const float m[16])
{
    (void)shader; (void)loc; (void)m;
}

void MetalShaderSetColor(GuliShader* shader, int loc, GULI_COLOR color)
{
    MetalShaderSetVec4(shader, loc, color);
}

void MetalShaderSetTexture(GuliShader* shader, int loc, unsigned int texId)
{
    (void)shader; (void)loc; (void)texId;
    /* Metal: setFragmentTexture:atIndex: - texId would need to be MTLTexture* cast */
}

#pragma clang diagnostic pop
