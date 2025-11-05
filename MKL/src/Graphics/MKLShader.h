//
// MKLShader.h
// MetalLib - Custom Shader Support
//
// Provides raylib-style custom shader loading and uniform management for Metal
//

#ifndef MKLShader_h
#define MKLShader_h

#include "../Core/MKLCore.h"
#include "MKLColors.h"
#include <simd/simd.h>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ========== Shader Types ==========

/**
 * @brief Shader uniform types
 */
typedef enum MKLShaderUniformType {
    MKL_SHADER_UNIFORM_FLOAT = 0,
    MKL_SHADER_UNIFORM_VEC2,
    MKL_SHADER_UNIFORM_VEC3,
    MKL_SHADER_UNIFORM_VEC4,
    MKL_SHADER_UNIFORM_INT,
    MKL_SHADER_UNIFORM_IVEC2,
    MKL_SHADER_UNIFORM_IVEC3,
    MKL_SHADER_UNIFORM_IVEC4,
    MKL_SHADER_UNIFORM_MAT4,
    MKL_SHADER_UNIFORM_SAMPLER2D
} MKLShaderUniformType;

/**
 * @brief Custom shader object
 */
typedef struct MKLShader {
#ifdef __OBJC__
    id<MTLLibrary> _library;
    id<MTLFunction> _vertexFunction;
    id<MTLFunction> _fragmentFunction;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLDevice> _device;

    // Uniform buffer management
    id<MTLBuffer> _uniformBuffer;
    id<MTLBuffer> _fullscreenQuadBuffer;
    size_t _uniformBufferSize;
    void *_uniformData;
#else
    void *_library;
    void *_vertexFunction;
    void *_fragmentFunction;
    void *_pipelineState;
    void *_device;
    void *_uniformBuffer;
    void *_fullscreenQuadBuffer;
    size_t _uniformBufferSize;
    void *_uniformData;
#endif

    // Track if this is a valid shader
    bool _isValid;
} MKLShader;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Shader Management Functions ==========

/**
 * @brief Load shader from Metal source file
 * @param renderer The renderer context
 * @param shaderPath Path to the .metal shader file
 * @param vertexFunc Name of the vertex function
 * @param fragmentFunc Name of the fragment function
 * @return Custom shader object
 */
MKLAPI MKLShader *MKLLoadShader(MKLRenderer *renderer,
                                 const char *shaderPath,
                                 const char *vertexFunc,
                                 const char *fragmentFunc);

/**
 * @brief Load shader from Metal source code strings
 * @param renderer The renderer context
 * @param shaderCode Metal shader source code
 * @param vertexFunc Name of the vertex function
 * @param fragmentFunc Name of the fragment function
 * @return Custom shader object
 */
MKLAPI MKLShader *MKLLoadShaderFromMemory(MKLRenderer *renderer,
                                            const char *shaderCode,
                                            const char *vertexFunc,
                                            const char *fragmentFunc);

/**
 * @brief Check if a shader is valid
 * @param shader The shader to check
 * @return true if valid, false otherwise
 */
MKLAPI bool MKLIsShaderValid(const MKLShader *shader);

/**
 * @brief Unload shader and free resources
 * @param shader The shader to unload
 */
MKLAPI void MKLUnloadShader(MKLShader *shader);

// ========== Uniform Management Functions ==========

/**
 * @brief Set shader uniform value (float)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value Pointer to the value
 */
MKLAPI void MKLSetShaderFloat(MKLShader *shader, const char *uniformName, float value);

/**
 * @brief Set shader uniform value (vec2)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value The vector value
 */
MKLAPI void MKLSetShaderVec2(MKLShader *shader, const char *uniformName, vector_float2 value);

/**
 * @brief Set shader uniform value (vec3)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value The vector value
 */
MKLAPI void MKLSetShaderVec3(MKLShader *shader, const char *uniformName, vector_float3 value);

/**
 * @brief Set shader uniform value (vec4)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value The vector value
 */
MKLAPI void MKLSetShaderVec4(MKLShader *shader, const char *uniformName, vector_float4 value);

/**
 * @brief Set shader uniform value (int)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value The integer value
 */
MKLAPI void MKLSetShaderInt(MKLShader *shader, const char *uniformName, int value);

/**
 * @brief Set shader uniform value (matrix 4x4)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value The matrix value
 */
MKLAPI void MKLSetShaderMatrix(MKLShader *shader, const char *uniformName, matrix_float4x4 value);

/**
 * @brief Set shader uniform value (generic)
 * @param shader The shader
 * @param uniformName Name of the uniform
 * @param value Pointer to the value
 * @param uniformType Type of the uniform
 * @param count Number of elements (for arrays)
 */
MKLAPI void MKLSetShaderValue(MKLShader *shader,
                                const char *uniformName,
                                const void *value,
                                MKLShaderUniformType uniformType,
                                int count);

// ========== Shader Activation ==========

/**
 * @brief Begin using a custom shader for rendering
 * @param renderer The renderer context
 * @param shader The custom shader to use (NULL for default)
 */
MKLAPI void MKLBeginShaderMode(MKLRenderer *renderer, MKLShader *shader);

/**
 * @brief End custom shader mode
 * @param renderer The renderer context
 */
MKLAPI void MKLEndShaderMode(MKLRenderer *renderer);

// ========== Fullscreen Shader Functions ==========

/**
 * @brief Begin fullscreen shader rendering (direct to Metal layer)
 * @param renderer The renderer context
 * @param shader The custom shader to use
 */
MKLAPI void MKLBeginFullscreenShader(MKLRenderer *renderer, MKLShader *shader);

/**
 * @brief End fullscreen shader rendering
 * @param renderer The renderer context
 */
MKLAPI void MKLEndFullscreenShader(MKLRenderer *renderer);

// ========== 2D Rectangle Drawing for Shaders ==========
/**
 * @brief Draw a 2D rectangle for shader rendering (similar to raylib's DrawRectangle)
 * @param renderer The renderer context
 * @param x X position
 * @param y Y position
 * @param width Rectangle width
 * @param height Rectangle height
 * @param color Rectangle color
 */
MKLAPI void MKLDrawRectangle2D(MKLRenderer *renderer, float x, float y, float width, float height, MKLColor color);

#ifdef __cplusplus
}
#endif

#endif /* MKLShader_h */

