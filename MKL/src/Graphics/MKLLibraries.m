#import "MKLLibraries.h"
#import "MKLTypes.h"
#import "MKLRenderer.h"
#import "../Core/MKLError.h"

#include <stdio.h>

#pragma mark - Shader Library Loading

void MKLShaderLib(MKLRenderer *renderer, const char *shaderPath)
{
    NSError *error = nil;
    
    // First, try to load default library embedded in app binary
    renderer->_library = [renderer->_device newDefaultLibrary];
    if (renderer->_library)
    {
        printf("✓ Loaded default Metal library from app binary\n");
        return;
    }
    
    // Second, try to load from the provided path (if it exists)
    if (shaderPath != NULL)
    {
        NSString *shaderPathStr = [NSString stringWithUTF8String:shaderPath];
        NSString *shaderString = [NSString stringWithContentsOfFile:shaderPathStr
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        
        // Also load instancing shaders if they exist
        NSString *instancingPath = [shaderPathStr stringByDeletingLastPathComponent];
        instancingPath = [instancingPath stringByAppendingPathComponent:@"InstancingShaders.metal"];
        NSString *instancingString = [NSString stringWithContentsOfFile:instancingPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
        
        // Combine both shader files
        NSMutableString *combinedShaders = [NSMutableString string];
        if (shaderString) {
            [combinedShaders appendString:shaderString];
            [combinedShaders appendString:@"\n\n"];
        }
        if (instancingString) {
            [combinedShaders appendString:instancingString];
        }
        
        if (combinedShaders.length > 0)
        {
            MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
            if (@available(macOS 15.0, *)) {
                options.mathMode = MTLMathModeFast;
            } else {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                options.fastMathEnabled = YES;
                #pragma clang diagnostic pop
            }
            options.languageVersion = MTLLanguageVersion2_4;
            
            renderer->_library = [renderer->_device newLibraryWithSource:combinedShaders
                                                                  options:options
                                                                    error:&error];
            if (renderer->_library)
            {
                printf("✓ Compiled Metal shaders from: %s", shaderPath);
                if (instancingString) {
                    printf(" (with instancing support)");
                }
                printf("\n");
                return;
            }
            else
            {
                fprintf(stderr, "MKL Warning: Failed to compile shader from %s: %s\n",
                        shaderPath, [[error localizedDescription] UTF8String]);
            }
        }
    }
    
    // If we got here, no shader library was found
    fprintf(stderr, "MKL FATAL ERROR: No Metal shader library found!\n");
    fprintf(stderr, "  - No default library embedded in binary\n");
    fprintf(stderr, "  - No shader file at: %s\n", shaderPath ? shaderPath : "(null)");
    gError.type = MKL_ERROR_FAILED_TO_OPEN_FILE;
    gError.message = "No Metal shader library found";
}

#pragma mark - Vertex Descriptor

void MKLVertexDescriptorLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLVertexDescriptor: renderer is NULL");

    renderer->_vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(renderer->_vertexDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLVertexDescriptor: Failed to create MTLVertexDescriptor");

    // Position attribute (float4)
    renderer->_vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    renderer->_vertexDescriptor.attributes[0].offset = 0;
    renderer->_vertexDescriptor.attributes[0].bufferIndex = 0;

    // Layout for buffer 0
    renderer->_vertexDescriptor.layouts[0].stride = sizeof(MKLVertex);
    renderer->_vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    renderer->_vertexDescriptor.layouts[0].stepRate = 1;

    printf("✓ Vertex descriptor configured\n");
}

#pragma mark - Render Pipeline

void MKLRenderPipelineLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLRenderPipeline: renderer is NULL");

    // Load shader functions
    id<MTLFunction> vertexFunction = [renderer->_library newFunctionWithName:@"vertexShader"];
    MKL_NULL_CHECK_VOID(vertexFunction, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLRenderPipeline: Failed to load vertex shader");

    id<MTLFunction> fragmentFunction = [renderer->_library newFunctionWithName:@"fragmentShader"];
    MKL_NULL_CHECK_VOID(fragmentFunction, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLRenderPipeline: Failed to load fragment shader");

    // Create pipeline descriptor
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(pipelineDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLRenderPipeline: Failed to create pipeline descriptor");

    pipelineDescriptor.label = @"MKL Main Pipeline";
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = renderer->_vertexDescriptor;
    
    // Color attachment configuration
    pipelineDescriptor.colorAttachments[0].pixelFormat = renderer->_metalLayer.pixelFormat;
    
    // Enable blending for alpha transparency
    pipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    // Depth configuration
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    // Sample count (for MSAA if needed in future)
    if (@available(macOS 13.0, *)) {
        pipelineDescriptor.rasterSampleCount = 1;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        pipelineDescriptor.sampleCount = 1;
        #pragma clang diagnostic pop
    }

    // Create pipeline state
    NSError *error = nil;
    renderer->_pipelineState = [renderer->_device newRenderPipelineStateWithDescriptor:pipelineDescriptor 
                                                                                 error:&error];

    if (!renderer->_pipelineState)
    {
        fprintf(stderr, "MKL Error: Failed to create pipeline state: %s\n", 
                [[error localizedDescription] UTF8String]);
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create Metal render pipeline";
        return;
    }
    
    printf("✓ Render pipeline created successfully\n");
    
    // Create instanced rendering pipeline
    id<MTLFunction> vertexFunctionInstanced = [renderer->_library newFunctionWithName:@"vertexShaderInstanced"];
    id<MTLFunction> fragmentFunctionInstanced = [renderer->_library newFunctionWithName:@"fragmentShaderInstanced"];
    
    if (vertexFunctionInstanced && fragmentFunctionInstanced) {
        MTLRenderPipelineDescriptor *instancedPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        instancedPipelineDescriptor.label = @"MKL Instanced Pipeline";
        instancedPipelineDescriptor.vertexFunction = vertexFunctionInstanced;
        instancedPipelineDescriptor.fragmentFunction = fragmentFunctionInstanced;
        instancedPipelineDescriptor.vertexDescriptor = renderer->_vertexDescriptor;
        instancedPipelineDescriptor.colorAttachments[0].pixelFormat = renderer->_metalLayer.pixelFormat;
        instancedPipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
        instancedPipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        instancedPipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        instancedPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
        instancedPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
        instancedPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        instancedPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        instancedPipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        if (@available(macOS 13.0, *)) {
            instancedPipelineDescriptor.rasterSampleCount = 1;
        } else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            instancedPipelineDescriptor.sampleCount = 1;
            #pragma clang diagnostic pop
        }
        
        renderer->_instancedPipelineState = [renderer->_device newRenderPipelineStateWithDescriptor:instancedPipelineDescriptor error:&error];
        
        if (renderer->_instancedPipelineState) {
            printf("✓ Instanced render pipeline created successfully\n");
        } else {
            fprintf(stderr, "MKL Warning: Failed to create instanced pipeline: %s\n", 
                    [[error localizedDescription] UTF8String]);
        }
    } else {
        fprintf(stderr, "MKL Warning: Instanced shaders not found in library, instanced rendering disabled\n");
    }
}

#pragma mark - Depth Stencil State

void MKLDepetStencilStateLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLDepthStencilState: renderer is NULL");

    MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(depthStencilDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLDepthStencilState: Failed to create descriptor");

    depthStencilDescriptor.label = @"MKL Depth Stencil State";
    depthStencilDescriptor.depthWriteEnabled = YES;
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    
    renderer->_depthStencilState = [renderer->_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    MKL_NULL_CHECK_VOID(renderer->_depthStencilState, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLDepthStencilState: Failed to create depth stencil state");
    
    printf("✓ Depth stencil state configured\n");
}
