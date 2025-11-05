//
// MKLCompute.h
// MetalLib - Compute Shader Support
//
// Provides GPU compute shader support for parallel processing and GPGPU tasks
//

#ifndef MKLCompute_h
#define MKLCompute_h

#include "../Core/MKLCore.h"
#include <simd/simd.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ========== Compute Shader Types ==========

/**
 * @brief Compute buffer access mode
 */
typedef enum MKLComputeBufferMode {
    MKL_COMPUTE_BUFFER_READ = 0,        ///< Read-only buffer
    MKL_COMPUTE_BUFFER_WRITE,           ///< Write-only buffer
    MKL_COMPUTE_BUFFER_READ_WRITE       ///< Read-write buffer
} MKLComputeBufferMode;

/**
 * @brief Compute shader object
 */
typedef struct MKLComputeShader {
#ifdef __OBJC__
    id<MTLDevice> _device;
    id<MTLLibrary> _library;
    id<MTLFunction> _computeFunction;
    id<MTLComputePipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
#else
    void *_device;
    void *_library;
    void *_computeFunction;
    void *_pipelineState;
    void *_commandQueue;
#endif
    size_t _maxThreadsPerThreadgroup;
    size_t _threadExecutionWidth;
    bool _isValid;
} MKLComputeShader;

/**
 * @brief Compute buffer for GPU data
 */
typedef struct MKLComputeBuffer {
#ifdef __OBJC__
    id<MTLBuffer> _buffer;
#else
    void *_buffer;
#endif
    size_t _size;
    MKLComputeBufferMode _mode;
    bool _isValid;
} MKLComputeBuffer;

/**
 * @brief Thread group size configuration
 */
typedef struct MKLThreadGroupSize {
    size_t width;
    size_t height;
    size_t depth;
} MKLThreadGroupSize;

// Forward declaration
typedef struct MKLRenderer MKLRenderer;

// ========== Compute Shader Management ==========

/**
 * @brief Load compute shader from Metal source file
 * @param renderer The renderer context (needed for Metal device)
 * @param shaderPath Path to the .metal shader file
 * @param functionName Name of the compute kernel function
 * @return Compute shader object or NULL on failure
 */
MKLAPI MKLComputeShader *MKLLoadComputeShader(MKLRenderer *renderer,
                                                const char *shaderPath,
                                                const char *functionName);

/**
 * @brief Load compute shader from Metal source code string
 * @param renderer The renderer context
 * @param shaderCode Metal shader source code
 * @param functionName Name of the compute kernel function
 * @return Compute shader object or NULL on failure
 */
MKLAPI MKLComputeShader *MKLLoadComputeShaderFromMemory(MKLRenderer *renderer,
                                                          const char *shaderCode,
                                                          const char *functionName);

/**
 * @brief Check if a compute shader is valid
 * @param shader The shader to check
 * @return true if valid, false otherwise
 */
MKLAPI bool MKLIsComputeShaderValid(const MKLComputeShader *shader);

/**
 * @brief Unload compute shader and free resources
 * @param shader The shader to unload
 */
MKLAPI void MKLUnloadComputeShader(MKLComputeShader *shader);

/**
 * @brief Get maximum threads per threadgroup for this shader
 * @param shader The compute shader
 * @return Maximum threads per threadgroup
 */
MKLAPI size_t MKLGetMaxThreadsPerThreadgroup(const MKLComputeShader *shader);

/**
 * @brief Get thread execution width (SIMD width) for this shader
 * @param shader The compute shader
 * @return Thread execution width
 */
MKLAPI size_t MKLGetThreadExecutionWidth(const MKLComputeShader *shader);

// ========== Buffer Management ==========

/**
 * @brief Create a compute buffer for GPU data
 * @param renderer The renderer context
 * @param size Buffer size in bytes
 * @param mode Access mode (read/write/read-write)
 * @return Compute buffer or invalid buffer on failure
 */
MKLAPI MKLComputeBuffer MKLCreateComputeBuffer(MKLRenderer *renderer,
                                                 size_t size,
                                                 MKLComputeBufferMode mode);

/**
 * @brief Create compute buffer with initial data
 * @param renderer The renderer context
 * @param data Initial data to copy
 * @param size Data size in bytes
 * @param mode Access mode
 * @return Compute buffer or invalid buffer on failure
 */
MKLAPI MKLComputeBuffer MKLCreateComputeBufferWithData(MKLRenderer *renderer,
                                                         const void *data,
                                                         size_t size,
                                                         MKLComputeBufferMode mode);

/**
 * @brief Check if a compute buffer is valid
 * @param buffer The buffer to check
 * @return true if valid, false otherwise
 */
MKLAPI bool MKLIsComputeBufferValid(const MKLComputeBuffer *buffer);

/**
 * @brief Upload data to compute buffer
 * @param buffer The buffer to write to
 * @param data Data to upload
 * @param size Data size in bytes
 * @param offset Offset in buffer to start writing
 */
MKLAPI void MKLUpdateComputeBuffer(MKLComputeBuffer *buffer,
                                     const void *data,
                                     size_t size,
                                     size_t offset);

/**
 * @brief Download data from compute buffer
 * @param buffer The buffer to read from
 * @param data Destination for data
 * @param size Size to read in bytes
 * @param offset Offset in buffer to start reading
 */
MKLAPI void MKLReadComputeBuffer(MKLComputeBuffer *buffer,
                                   void *data,
                                   size_t size,
                                   size_t offset);

/**
 * @brief Get pointer to buffer contents (for direct access)
 * @param buffer The buffer
 * @return Pointer to buffer contents or NULL on failure
 * @warning This pointer is only valid until the buffer is destroyed
 */
MKLAPI void *MKLGetComputeBufferPointer(MKLComputeBuffer *buffer);

/**
 * @brief Release compute buffer resources
 * @param buffer The buffer to release
 */
MKLAPI void MKLReleaseComputeBuffer(MKLComputeBuffer *buffer);

// ========== Compute Dispatch ==========

/**
 * @brief Set compute buffer at index
 * @param shader The compute shader
 * @param buffer The buffer to bind
 * @param index Buffer index (matches [[buffer(N)]] in shader)
 */
MKLAPI void MKLSetComputeBuffer(MKLComputeShader *shader,
                                  MKLComputeBuffer *buffer,
                                  int index);

/**
 * @brief Set compute shader uniform value (bytes)
 * @param shader The compute shader
 * @param data Pointer to data
 * @param size Size of data in bytes
 * @param index Buffer index
 */
MKLAPI void MKLSetComputeBytes(MKLComputeShader *shader,
                                 const void *data,
                                 size_t size,
                                 int index);

/**
 * @brief Set compute shader float value
 * @param shader The compute shader
 * @param value Float value
 * @param index Buffer index
 */
MKLAPI void MKLSetComputeFloat(MKLComputeShader *shader, float value, int index);

/**
 * @brief Set compute shader int value
 * @param shader The compute shader
 * @param value Integer value
 * @param index Buffer index
 */
MKLAPI void MKLSetComputeInt(MKLComputeShader *shader, int value, int index);

/**
 * @brief Set compute shader vector value
 * @param shader The compute shader
 * @param value Vector value
 * @param index Buffer index
 */
MKLAPI void MKLSetComputeVec3(MKLComputeShader *shader, vector_float3 value, int index);

/**
 * @brief Dispatch compute shader with thread count
 * @param shader The compute shader
 * @param threadsX Number of threads in X dimension
 * @param threadsY Number of threads in Y dimension
 * @param threadsZ Number of threads in Z dimension
 *
 * This function automatically calculates optimal threadgroup size.
 */
MKLAPI void MKLDispatchCompute(MKLComputeShader *shader,
                                 size_t threadsX,
                                 size_t threadsY,
                                 size_t threadsZ);

/**
 * @brief Dispatch compute shader with explicit threadgroup configuration
 * @param shader The compute shader
 * @param gridSize Total number of threads (grid size)
 * @param threadGroupSize Threads per threadgroup
 *
 * For advanced users who want explicit control over thread layout.
 */
MKLAPI void MKLDispatchComputeExplicit(MKLComputeShader *shader,
                                         MKLThreadGroupSize gridSize,
                                         MKLThreadGroupSize threadGroupSize);

/**
 * @brief Wait for compute operations to complete
 * @param shader The compute shader
 *
 * Blocks until all pending compute operations finish.
 */
MKLAPI void MKLWaitForComputeCompletion(MKLComputeShader *shader);

// ========== Helper Functions ==========

/**
 * @brief Calculate optimal threadgroup size for a given problem size
 * @param shader The compute shader
 * @param totalThreads Total number of threads needed
 * @return Recommended threadgroup size
 */
MKLAPI MKLThreadGroupSize MKLGetOptimalThreadGroupSize(const MKLComputeShader *shader,
                                                         size_t totalThreads);

/**
 * @brief Calculate grid size (number of threadgroups) needed
 * @param totalThreads Total threads needed
 * @param threadGroupSize Threads per threadgroup
 * @return Number of threadgroups needed
 */
MKLAPI MKLThreadGroupSize MKLCalculateGridSize(size_t totalThreads,
                                                 MKLThreadGroupSize threadGroupSize);

#ifdef __cplusplus
}
#endif

#endif /* MKLCompute_h */

