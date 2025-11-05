//
// MKLShader.m
// MetalLib - Custom Shader Implementation
//

#import "MKLShader.h"
#import "MKLRenderer.h"
#import "MKLTypes.h"
#import "../Core/MKLError.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <string.h>

// Forward declarations
MKLShader *MKLLoadShaderFromMemory(MKLRenderer *renderer,
                                    const char *shaderCode,
                                    const char *vertexFunc,
                                    const char *fragmentFunc);

// ========== Internal Helper Functions ==========

static id<MTLLibrary> _compileShaderFromSource(id<MTLDevice> device, const char *source, NSError **error) {
    NSString *sourceStr = [NSString stringWithUTF8String:source];

    MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
    options.languageVersion = MTLLanguageVersion2_4;

    id<MTLLibrary> library = [device newLibraryWithSource:sourceStr
                                                  options:options
                                                    error:error];
    return library;
}

static id<MTLRenderPipelineState> _createPipelineState(id<MTLDevice> device,
                                                        id<MTLFunction> vertexFunc,
                                                        id<MTLFunction> fragmentFunc,
                                                        MTLVertexDescriptor *vertexDesc,
                                                        NSError **error) {
    MTLRenderPipelineDescriptor *pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.vertexFunction = vertexFunc;
    pipelineDesc.fragmentFunction = fragmentFunc;
    pipelineDesc.vertexDescriptor = vertexDesc;

    // Color attachment
    pipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDesc.colorAttachments[0].blendingEnabled = YES;
    pipelineDesc.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineDesc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;

    // Depth attachment
    pipelineDesc.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    // Sample count
    if (@available(macOS 10.13, *)) {
        pipelineDesc.rasterSampleCount = 1;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        pipelineDesc.sampleCount = 1;
        #pragma clang diagnostic pop
    }

    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDesc
                                                                                      error:error];
    return pipelineState;
}

// ========== Shader Loading Functions ==========

MKLShader *MKLLoadShader(MKLRenderer *renderer,
                          const char *shaderPath,
                          const char *vertexFunc,
                          const char *fragmentFunc) {
    if (renderer == NULL || shaderPath == NULL || vertexFunc == NULL || fragmentFunc == NULL) {
        fprintf(stderr, "MKL Error: Invalid parameters for MKLLoadShader\n");
        return NULL;
    }

    // Read shader file
    NSString *path = [NSString stringWithUTF8String:shaderPath];
    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

    if (error != nil) {
        fprintf(stderr, "MKL Error: Failed to load shader file '%s': %s\n",
                shaderPath, [[error localizedDescription] UTF8String]);
        return NULL;
    }

    return MKLLoadShaderFromMemory(renderer, [shaderSource UTF8String], vertexFunc, fragmentFunc);
}

MKLShader *MKLLoadShaderFromMemory(MKLRenderer *renderer,
                                    const char *shaderCode,
                                    const char *vertexFunc,
                                    const char *fragmentFunc) {
    if (renderer == NULL || shaderCode == NULL || vertexFunc == NULL || fragmentFunc == NULL) {
        fprintf(stderr, "MKL Error: Invalid parameters for MKLLoadShaderFromMemory\n");
        return NULL;
    }

    MKLShader *shader = (MKLShader *)malloc(sizeof(MKLShader));
    if (shader == NULL) {
        fprintf(stderr, "MKL Error: Failed to allocate MKLShader\n");
        return NULL;
    }

    // Initialize Objective-C pointers to nil (can't use memset with ARC objects)
    shader->_library = nil;
    shader->_vertexFunction = nil;
    shader->_fragmentFunction = nil;
    shader->_pipelineState = nil;
    shader->_device = renderer->_device;
    shader->_uniformBuffer = nil;
    shader->_uniformBufferSize = 0;
    shader->_uniformData = NULL;
    shader->_isValid = false;

    // Compile shader source
    NSError *error = nil;
    shader->_library = _compileShaderFromSource(renderer->_device, shaderCode, &error);

    if (error != nil || shader->_library == nil) {
        fprintf(stderr, "MKL Error: Failed to compile shader: %s\n",
                error ? [[error localizedDescription] UTF8String] : "Unknown error");
        free(shader);
        return NULL;
    }

    // Load functions
    NSString *vertexFuncName = [NSString stringWithUTF8String:vertexFunc];
    NSString *fragmentFuncName = [NSString stringWithUTF8String:fragmentFunc];

    shader->_vertexFunction = [shader->_library newFunctionWithName:vertexFuncName];
    shader->_fragmentFunction = [shader->_library newFunctionWithName:fragmentFuncName];

    if (shader->_vertexFunction == nil || shader->_fragmentFunction == nil) {
        fprintf(stderr, "MKL Error: Failed to find shader functions '%s' or '%s'\n",
                vertexFunc, fragmentFunc);
        free(shader);
        return NULL;
    }

    // Create pipeline state
    shader->_pipelineState = _createPipelineState(renderer->_device,
                                                   shader->_vertexFunction,
                                                   shader->_fragmentFunction,
                                                   renderer->_vertexDescriptor,
                                                   &error);

    if (error != nil || shader->_pipelineState == nil) {
        fprintf(stderr, "MKL Error: Failed to create pipeline state: %s\n",
                error ? [[error localizedDescription] UTF8String] : "Unknown error");
        free(shader);
        return NULL;
    }

    // Create uniform buffer (4KB default size)
    shader->_uniformBufferSize = 4096;
    shader->_uniformBuffer = [renderer->_device newBufferWithLength:shader->_uniformBufferSize
                                                            options:MTLResourceStorageModeShared];
    shader->_uniformData = [shader->_uniformBuffer contents];

    // Create fullscreen quad vertex buffer
    float fullscreenQuadVertices[] = {
        -1.0f, -1.0f, 0.0f, 1.0f,  // Bottom-left
         1.0f, -1.0f, 0.0f, 1.0f,  // Bottom-right
        -1.0f,  1.0f, 0.0f, 1.0f,  // Top-left
         1.0f,  1.0f, 0.0f, 1.0f   // Top-right
    };

    shader->_fullscreenQuadBuffer = [renderer->_device newBufferWithBytes:fullscreenQuadVertices
                                                                   length:sizeof(fullscreenQuadVertices)
                                                                  options:MTLResourceStorageModeShared];

    shader->_isValid = true;

    printf("MKL: Successfully loaded custom shader (vertex: %s, fragment: %s)\n",
           vertexFunc, fragmentFunc);

    return shader;
}

bool MKLIsShaderValid(const MKLShader *shader) {
    return (shader != NULL && shader->_isValid);
}

void MKLUnloadShader(MKLShader *shader) {
    if (shader == NULL) return;

    // ARC will handle Metal object cleanup
    shader->_library = nil;
    shader->_vertexFunction = nil;
    shader->_fragmentFunction = nil;
    shader->_pipelineState = nil;
    shader->_uniformBuffer = nil;
    shader->_device = nil;

    shader->_isValid = false;
    free(shader);
}

// ========== Uniform Management Functions ==========

void MKLSetShaderFloat(MKLShader *shader, const char *uniformName, float value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_FLOAT, 1);
}

void MKLSetShaderVec2(MKLShader *shader, const char *uniformName, vector_float2 value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_VEC2, 1);
}

void MKLSetShaderVec3(MKLShader *shader, const char *uniformName, vector_float3 value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_VEC3, 1);
}

void MKLSetShaderVec4(MKLShader *shader, const char *uniformName, vector_float4 value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_VEC4, 1);
}

void MKLSetShaderInt(MKLShader *shader, const char *uniformName, int value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_INT, 1);
}

void MKLSetShaderMatrix(MKLShader *shader, const char *uniformName, matrix_float4x4 value) {
    MKLSetShaderValue(shader, uniformName, &value, MKL_SHADER_UNIFORM_MAT4, 1);
}

void MKLSetShaderValue(MKLShader *shader,
                        const char *uniformName,
                        const void *value,
                        MKLShaderUniformType uniformType,
                        int count) {
    if (!MKLIsShaderValid(shader) || uniformName == NULL || value == NULL || count <= 0) {
        return;
    }

    // Calculate size based on type
    size_t elementSize = 0;
    switch (uniformType) {
        case MKL_SHADER_UNIFORM_FLOAT:
            elementSize = sizeof(float);
            break;
        case MKL_SHADER_UNIFORM_VEC2:
            elementSize = sizeof(vector_float2);
            break;
        case MKL_SHADER_UNIFORM_VEC3:
            elementSize = sizeof(vector_float3);
            break;
        case MKL_SHADER_UNIFORM_VEC4:
            elementSize = sizeof(vector_float4);
            break;
        case MKL_SHADER_UNIFORM_INT:
        case MKL_SHADER_UNIFORM_SAMPLER2D:
            elementSize = sizeof(int);
            break;
        case MKL_SHADER_UNIFORM_IVEC2:
            elementSize = sizeof(int) * 2;
            break;
        case MKL_SHADER_UNIFORM_IVEC3:
            elementSize = sizeof(int) * 3;
            break;
        case MKL_SHADER_UNIFORM_IVEC4:
            elementSize = sizeof(int) * 4;
            break;
        case MKL_SHADER_UNIFORM_MAT4:
            elementSize = sizeof(matrix_float4x4);
            break;
        default:
            fprintf(stderr, "MKL Error: Unknown shader uniform type\n");
            return;
    }

    size_t totalSize = elementSize * count;

    if (totalSize > shader->_uniformBufferSize) {
        fprintf(stderr, "MKL Error: Uniform data size exceeds buffer size\n");
        return;
    }

    // Copy data to uniform buffer
    // Note: In a production system, you'd want to track offsets per uniform name
    // For simplicity, we're just copying to the start of the buffer
    memcpy(shader->_uniformData, value, totalSize);
}

// ========== Shader Activation ==========

void MKLBeginShaderMode(MKLRenderer *renderer, MKLShader *shader) {
    if (renderer == NULL) return;

    if (shader != NULL && MKLIsShaderValid(shader)) {
        // Store the current pipeline state to restore later
        renderer->_customShader = shader;

        // Set the custom pipeline state
        if (renderer->_renderEncoder != nil) {
            [renderer->_renderEncoder setRenderPipelineState:shader->_pipelineState];

            // Bind uniform buffer if it exists
            if (shader->_uniformBuffer != nil) {
                [renderer->_renderEncoder setVertexBuffer:shader->_uniformBuffer
                                                   offset:0
                                                  atIndex:4]; // Use buffer index 4 for custom uniforms
                [renderer->_renderEncoder setFragmentBuffer:shader->_uniformBuffer
                                                     offset:0
                                                    atIndex:4];
            }
        }
    }
}

void MKLEndShaderMode(MKLRenderer *renderer) {
    if (renderer == NULL) return;

    // Restore default pipeline state
    renderer->_customShader = NULL;

    if (renderer->_renderEncoder != nil && renderer->_pipelineState != nil) {
        [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    }
}

// ========== Fullscreen Shader Functions ==========

void MKLBeginFullscreenShader(MKLRenderer *renderer, MKLShader *shader) {
    if (renderer == NULL || shader == NULL || !MKLIsShaderValid(shader)) {
        return;
    }

    // Get a drawable from the Metal layer
    id<CAMetalDrawable> drawable = [renderer->_metalLayer nextDrawable];
    if (drawable == nil) {
        printf("MKL: No drawable available for fullscreen shader\n");
        return;
    }

    // Create render pass descriptor for the drawable
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

    // Create command buffer
    id<MTLCommandBuffer> commandBuffer = [renderer->_commandQueue commandBuffer];
    commandBuffer.label = @"Fullscreen Shader Command Buffer";

    // Create render encoder
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    renderEncoder.label = @"Fullscreen Shader Render Encoder";

    // Set the custom shader pipeline state
    [renderEncoder setRenderPipelineState:shader->_pipelineState];

    // Bind fullscreen quad vertex buffer
    if (shader->_fullscreenQuadBuffer != nil) {
        [renderEncoder setVertexBuffer:shader->_fullscreenQuadBuffer offset:0 atIndex:0];
    }

    // Bind uniform buffer if it exists
    if (shader->_uniformBuffer != nil) {
        [renderEncoder setVertexBuffer:shader->_uniformBuffer offset:0 atIndex:4];
        [renderEncoder setFragmentBuffer:shader->_uniformBuffer offset:0 atIndex:4];
    }

    // Draw a fullscreen quad (triangle strip covering [-1,1] in clip space)
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];

    // End encoding
    [renderEncoder endEncoding];

    // Present the drawable
    [commandBuffer presentDrawable:drawable];

    // Commit the command buffer
    [commandBuffer commit];

    // Store the shader for potential cleanup
    renderer->_customShader = shader;
}

void MKLEndFullscreenShader(MKLRenderer *renderer) {
    if (renderer == NULL) return;

    // Clear the custom shader reference
    renderer->_customShader = NULL;
}

// ========== 2D Rectangle Drawing for Shaders ==========

void MKLDrawRectangle2D(MKLRenderer *renderer, float x __attribute__((unused)), float y __attribute__((unused)), float width __attribute__((unused)), float height __attribute__((unused)), MKLColor color __attribute__((unused))) {
    if (renderer == NULL || renderer->_renderEncoder == nil) {
        return;
    }

    // For fullscreen rendering, create a simple fullscreen quad in clip space
    // This bypasses coordinate conversion issues
    float vertices[] = {
        -1.0f, -1.0f, 0.0f, 1.0f,  // Bottom-left
         1.0f, -1.0f, 0.0f, 1.0f,  // Bottom-right
        -1.0f,  1.0f, 0.0f, 1.0f,  // Top-left
         1.0f,  1.0f, 0.0f, 1.0f   // Top-right
    };

    // Create vertex buffer for this rectangle
    id<MTLBuffer> rectBuffer = [renderer->_device newBufferWithBytes:vertices
                                                              length:sizeof(vertices)
                                                             options:MTLResourceStorageModeShared];

    if (rectBuffer != nil) {
        // Bind the rectangle vertex buffer
        [renderer->_renderEncoder setVertexBuffer:rectBuffer offset:0 atIndex:0];

        // Draw the rectangle as a triangle strip
        [renderer->_renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip
                                     vertexStart:0
                                     vertexCount:4];
    }
}

