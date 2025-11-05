//
// MKLCompute.m
// MetalLib - Compute Shader Implementation
//

#import "MKLCompute.h"
#import "MKLRenderer.h"
#import "../Core/MKLError.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <string.h>

// ========== Internal Helper Functions ==========

static id<MTLLibrary> _compileComputeShaderFromSource(id<MTLDevice> device, const char *source, NSError **error) {
    NSString *sourceStr = [NSString stringWithUTF8String:source];

    MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
    options.languageVersion = MTLLanguageVersion2_4;

    id<MTLLibrary> library = [device newLibraryWithSource:sourceStr
                                                  options:options
                                                    error:error];
    return library;
}

static id<MTLComputePipelineState> _createComputePipelineState(id<MTLDevice> device,
                                                                 id<MTLFunction> computeFunc,
                                                                 NSError **error) {
    id<MTLComputePipelineState> pipelineState = [device newComputePipelineStateWithFunction:computeFunc
                                                                                       error:error];
    return pipelineState;
}

// ========== Compute Shader Management ==========

MKLComputeShader *MKLLoadComputeShader(MKLRenderer *renderer,
                                         const char *shaderPath,
                                         const char *functionName) {
    if (renderer == NULL || shaderPath == NULL || functionName == NULL) {
        fprintf(stderr, "MKL Error: Invalid parameters for MKLLoadComputeShader\n");
        return NULL;
    }

    // Read shader file
    NSString *path = [NSString stringWithUTF8String:shaderPath];
    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

    if (error != nil) {
        fprintf(stderr, "MKL Error: Failed to load compute shader file '%s': %s\n",
                shaderPath, [[error localizedDescription] UTF8String]);
        return NULL;
    }

    return MKLLoadComputeShaderFromMemory(renderer, [shaderSource UTF8String], functionName);
}

MKLComputeShader *MKLLoadComputeShaderFromMemory(MKLRenderer *renderer,
                                                   const char *shaderCode,
                                                   const char *functionName) {
    if (renderer == NULL || shaderCode == NULL || functionName == NULL) {
        fprintf(stderr, "MKL Error: Invalid parameters for MKLLoadComputeShaderFromMemory\n");
        return NULL;
    }

    MKLComputeShader *shader = (MKLComputeShader *)calloc(1, sizeof(MKLComputeShader));
    if (shader == NULL) {
        fprintf(stderr, "MKL Error: Failed to allocate compute shader\n");
        return NULL;
    }

    shader->_device = renderer->_device;
    shader->_commandQueue = renderer->_commandQueue;

    // Compile shader
    NSError *error = nil;
    shader->_library = _compileComputeShaderFromSource(shader->_device, shaderCode, &error);

    if (error != nil) {
        fprintf(stderr, "MKL Error: Failed to compile compute shader: %s\n",
                [[error localizedDescription] UTF8String]);
        free(shader);
        return NULL;
    }

    // Get compute function
    NSString *funcName = [NSString stringWithUTF8String:functionName];
    shader->_computeFunction = [shader->_library newFunctionWithName:funcName];

    if (shader->_computeFunction == nil) {
        fprintf(stderr, "MKL Error: Compute function '%s' not found in shader\n", functionName);
        free(shader);
        return NULL;
    }

    // Create pipeline state
    shader->_pipelineState = _createComputePipelineState(shader->_device,
                                                           shader->_computeFunction,
                                                           &error);

    if (error != nil) {
        fprintf(stderr, "MKL Error: Failed to create compute pipeline state: %s\n",
                [[error localizedDescription] UTF8String]);
        free(shader);
        return NULL;
    }

    // Get thread limits
    shader->_maxThreadsPerThreadgroup = shader->_pipelineState.maxTotalThreadsPerThreadgroup;
    shader->_threadExecutionWidth = shader->_pipelineState.threadExecutionWidth;
    shader->_isValid = true;

    return shader;
}

bool MKLIsComputeShaderValid(const MKLComputeShader *shader) {
    return shader != NULL && shader->_isValid;
}

void MKLUnloadComputeShader(MKLComputeShader *shader) {
    if (shader == NULL) return;

    shader->_isValid = false;
    free(shader);
}

size_t MKLGetMaxThreadsPerThreadgroup(const MKLComputeShader *shader) {
    if (!MKLIsComputeShaderValid(shader)) return 0;
    return shader->_maxThreadsPerThreadgroup;
}

size_t MKLGetThreadExecutionWidth(const MKLComputeShader *shader) {
    if (!MKLIsComputeShaderValid(shader)) return 0;
    return shader->_threadExecutionWidth;
}

// ========== Buffer Management ==========

MKLComputeBuffer MKLCreateComputeBuffer(MKLRenderer *renderer,
                                         size_t size,
                                         MKLComputeBufferMode mode) {
    MKLComputeBuffer buffer = {0};

    if (renderer == NULL || size == 0) {
        fprintf(stderr, "MKL Error: Invalid parameters for MKLCreateComputeBuffer\n");
        return buffer;
    }

    MTLResourceOptions options;
    switch (mode) {
        case MKL_COMPUTE_BUFFER_READ:
            options = MTLResourceStorageModeShared;
            break;
        case MKL_COMPUTE_BUFFER_WRITE:
            options = MTLResourceStorageModeShared;
            break;
        case MKL_COMPUTE_BUFFER_READ_WRITE:
            options = MTLResourceStorageModeShared;
            break;
        default:
            options = MTLResourceStorageModeShared;
    }

    buffer._buffer = [renderer->_device newBufferWithLength:size options:options];

    if (buffer._buffer == nil) {
        fprintf(stderr, "MKL Error: Failed to create compute buffer of size %zu\n", size);
        return buffer;
    }

    buffer._size = size;
    buffer._mode = mode;
    buffer._isValid = true;

    return buffer;
}

MKLComputeBuffer MKLCreateComputeBufferWithData(MKLRenderer *renderer,
                                                  const void *data,
                                                  size_t size,
                                                  MKLComputeBufferMode mode) {
    MKLComputeBuffer buffer = MKLCreateComputeBuffer(renderer, size, mode);

    if (buffer._isValid && data != NULL) {
        memcpy([buffer._buffer contents], data, size);
    }

    return buffer;
}

bool MKLIsComputeBufferValid(const MKLComputeBuffer *buffer) {
    return buffer != NULL && buffer->_isValid;
}

void MKLUpdateComputeBuffer(MKLComputeBuffer *buffer,
                             const void *data,
                             size_t size,
                             size_t offset) {
    if (!MKLIsComputeBufferValid(buffer) || data == NULL) {
        fprintf(stderr, "MKL Error: Invalid buffer or data for MKLUpdateComputeBuffer\n");
        return;
    }

    if (offset + size > buffer->_size) {
        fprintf(stderr, "MKL Error: Write would exceed buffer bounds\n");
        return;
    }

    void *bufferContents = [buffer->_buffer contents];
    memcpy((uint8_t *)bufferContents + offset, data, size);
}

void MKLReadComputeBuffer(MKLComputeBuffer *buffer,
                          void *data,
                          size_t size,
                          size_t offset) {
    if (!MKLIsComputeBufferValid(buffer) || data == NULL) {
        fprintf(stderr, "MKL Error: Invalid buffer or data for MKLReadComputeBuffer\n");
        return;
    }

    if (offset + size > buffer->_size) {
        fprintf(stderr, "MKL Error: Read would exceed buffer bounds\n");
        return;
    }

    void *bufferContents = [buffer->_buffer contents];
    memcpy(data, (uint8_t *)bufferContents + offset, size);
}

void *MKLGetComputeBufferPointer(MKLComputeBuffer *buffer) {
    if (!MKLIsComputeBufferValid(buffer)) {
        return NULL;
    }
    return [buffer->_buffer contents];
}

void MKLReleaseComputeBuffer(MKLComputeBuffer *buffer) {
    if (buffer == NULL) return;
    buffer->_isValid = false;
    buffer->_buffer = nil;
}

// ========== Compute Dispatch ==========

// Buffer and uniform tracking for next dispatch
static id<MTLBuffer> _boundBuffers[32] = {nil};
static NSData *_boundBytes[32] = {nil};

void MKLSetComputeBuffer(MKLComputeShader *shader,
                          MKLComputeBuffer *buffer,
                          int index) {
    if (!MKLIsComputeShaderValid(shader) || !MKLIsComputeBufferValid(buffer)) {
        fprintf(stderr, "MKL Error: Invalid shader or buffer for MKLSetComputeBuffer\n");
        return;
    }

    if (index < 0 || index >= 32) {
        fprintf(stderr, "MKL Error: Buffer index out of range (0-31): %d\n", index);
        return;
    }

    _boundBuffers[index] = buffer->_buffer;
}

void MKLSetComputeBytes(MKLComputeShader *shader,
                        const void *data,
                        size_t size,
                        int index) {
    if (!MKLIsComputeShaderValid(shader) || data == NULL) {
        fprintf(stderr, "MKL Error: Invalid shader or data for MKLSetComputeBytes\n");
        return;
    }

    if (index < 0 || index >= 32) {
        fprintf(stderr, "MKL Error: Buffer index out of range (0-31): %d\n", index);
        return;
    }

    _boundBytes[index] = [NSData dataWithBytes:data length:size];
}

void MKLSetComputeFloat(MKLComputeShader *shader, float value, int index) {
    MKLSetComputeBytes(shader, &value, sizeof(float), index);
}

void MKLSetComputeInt(MKLComputeShader *shader, int value, int index) {
    MKLSetComputeBytes(shader, &value, sizeof(int), index);
}

void MKLSetComputeVec3(MKLComputeShader *shader, vector_float3 value, int index) {
    MKLSetComputeBytes(shader, &value, sizeof(vector_float3), index);
}

void MKLDispatchCompute(MKLComputeShader *shader,
                        size_t threadsX,
                        size_t threadsY,
                        size_t threadsZ) {
    if (!MKLIsComputeShaderValid(shader)) {
        fprintf(stderr, "MKL Error: Invalid shader for MKLDispatchCompute\n");
        return;
    }

    // Calculate optimal threadgroup size
    size_t maxThreads = shader->_maxThreadsPerThreadgroup;
    size_t width = shader->_threadExecutionWidth;

    // Simple heuristic: use power-of-2 sizes
    size_t threadGroupWidth = width;
    size_t threadGroupHeight = 1;
    size_t threadGroupDepth = 1;

    // Adjust for 2D/3D workloads
    if (threadsY > 1) {
        threadGroupHeight = 8;
        while (threadGroupWidth * threadGroupHeight > maxThreads) {
            threadGroupHeight /= 2;
        }
    }

    if (threadsZ > 1) {
        threadGroupDepth = 4;
        while (threadGroupWidth * threadGroupHeight * threadGroupDepth > maxThreads) {
            threadGroupDepth /= 2;
        }
    }

    MKLThreadGroupSize gridSize = {threadsX, threadsY, threadsZ};
    MKLThreadGroupSize threadGroupSize = {threadGroupWidth, threadGroupHeight, threadGroupDepth};

    MKLDispatchComputeExplicit(shader, gridSize, threadGroupSize);
}

void MKLDispatchComputeExplicit(MKLComputeShader *shader,
                                 MKLThreadGroupSize gridSize,
                                 MKLThreadGroupSize threadGroupSize) {
    if (!MKLIsComputeShaderValid(shader)) {
        fprintf(stderr, "MKL Error: Invalid shader for MKLDispatchComputeExplicit\n");
        return;
    }

    @autoreleasepool {
        id<MTLCommandBuffer> commandBuffer = [shader->_commandQueue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];

        [encoder setComputePipelineState:shader->_pipelineState];

        // Bind buffers
        for (int i = 0; i < 32; i++) {
            if (_boundBuffers[i] != nil) {
                [encoder setBuffer:_boundBuffers[i] offset:0 atIndex:i];
            } else if (_boundBytes[i] != nil) {
                [encoder setBytes:[_boundBytes[i] bytes]
                          length:[_boundBytes[i] length]
                         atIndex:i];
            }
        }

        // Dispatch
        MTLSize gridSizeMTL = MTLSizeMake(gridSize.width, gridSize.height, gridSize.depth);
        MTLSize threadGroupSizeMTL = MTLSizeMake(threadGroupSize.width,
                                                  threadGroupSize.height,
                                                  threadGroupSize.depth);

        [encoder dispatchThreads:gridSizeMTL
           threadsPerThreadgroup:threadGroupSizeMTL];

        [encoder endEncoding];
        [commandBuffer commit];

        // Clear bound buffers for next dispatch
        for (int i = 0; i < 32; i++) {
            _boundBuffers[i] = nil;
            _boundBytes[i] = nil;
        }
    }
}

void MKLWaitForComputeCompletion(MKLComputeShader *shader) {
    if (!MKLIsComputeShaderValid(shader)) {
        return;
    }

    @autoreleasepool {
        id<MTLCommandBuffer> commandBuffer = [shader->_commandQueue commandBuffer];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
    }
}

// ========== Helper Functions ==========

MKLThreadGroupSize MKLGetOptimalThreadGroupSize(const MKLComputeShader *shader,
                                                  size_t totalThreads) {
    MKLThreadGroupSize size = {1, 1, 1};

    if (!MKLIsComputeShaderValid(shader)) {
        return size;
    }

    size_t maxThreads = shader->_maxThreadsPerThreadgroup;
    size_t width = shader->_threadExecutionWidth;

    // Use multiples of thread execution width for best performance
    size.width = width;
    while (size.width * 2 <= maxThreads && size.width * 2 <= totalThreads) {
        size.width *= 2;
    }

    return size;
}

MKLThreadGroupSize MKLCalculateGridSize(size_t totalThreads,
                                         MKLThreadGroupSize threadGroupSize) {
    MKLThreadGroupSize gridSize;

    gridSize.width = (totalThreads + threadGroupSize.width - 1) / threadGroupSize.width;
    gridSize.height = threadGroupSize.height > 1 ?
        (totalThreads + threadGroupSize.height - 1) / threadGroupSize.height : 1;
    gridSize.depth = threadGroupSize.depth > 1 ?
        (totalThreads + threadGroupSize.depth - 1) / threadGroupSize.depth : 1;

    return gridSize;
}

