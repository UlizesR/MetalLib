#import "MKLLibraries.h"
#import "MKLTypes.h"
#import "MKLRenderer.h"
#import "../Core/MKLError.h"

#include <stdio.h>

void MKLShaderLib(MKLRenderer *renderer, const char *shaderPath)
{
    
    NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *shaderPathString = [currentDirectory stringByAppendingPathComponent:@(shaderPath)];
    
    NSString *shaderSource = [NSString stringWithContentsOfFile:shaderPathString
                                                       encoding:NSUTF8StringEncoding
                                                          error:&gError._error];

    gError.message = [[NSString stringWithFormat:@"MKLShaderLib: %s", [[gError._error localizedDescription] UTF8String]] UTF8String];
    MKL_NULL_CHECK_VOID(shaderSource, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message)

    renderer->_library = [renderer->_device newLibraryWithSource:shaderSource
                                                          options:nil
                                                            error:&gError._error];

    gError.message = [[NSString stringWithFormat:@"MKLShaderLib: %s", [[gError._error localizedDescription] UTF8String]] UTF8String];
    MKL_NULL_CHECK_VOID(renderer->_library, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message)

    [shaderSource release];
}

void MKLVertexDescriptorLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLVertexDescriptor: Failed to create MKLVertexDescriptor because renderer is null")

    renderer->_vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(renderer->_vertexDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLVertexDescriptor: Failed to create MTLVertexDescriptor")

    NSUInteger offset = 0;
    // Position
    renderer->_vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    renderer->_vertexDescriptor.attributes[0].offset = 0;
    renderer->_vertexDescriptor.attributes[0].bufferIndex = 0;
    offset += sizeof(vector_float4);

    renderer->_vertexDescriptor.layouts[0].stride = offset;
}

void MKLRenderPipelineLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLRenderPipeline: Failed to create MKLRenderPipeline because renderer is null")

    id<MTLFunction> vertexFunction = [renderer->_library newFunctionWithName:@"vertexShader"];
    MKL_NULL_CHECK_VOID(vertexFunction, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLRenderPipeline: Failed to create vertexFunction")

    id<MTLFunction> fragmentFunction = [renderer->_library newFunctionWithName:@"fragmentShader"];
    MKL_NULL_CHECK_VOID(fragmentFunction, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLRenderPipeline: Failed to create fragmentFunction")

    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(pipelineDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLRenderPipeline: Failed to create MTLRenderPipelineDescriptor")

    pipelineDescriptor.colorAttachments[0].pixelFormat = renderer->_metalLayer.pixelFormat;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = renderer->_vertexDescriptor;

    renderer->_pipelineState = [renderer->_device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                                 error:&gError._error];

    gError.message = [[NSString stringWithFormat:@"MKLRenderPipeline: %s", [[gError._error localizedDescription] UTF8String]] UTF8String];
    MKL_NULL_CHECK_VOID(renderer->_pipelineState, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message)

    // Release resources
    [pipelineDescriptor release];
    [vertexFunction release];
    [fragmentFunction release];
    [renderer->_library release];
    // [renderer->_vertexDescriptor release];
}

void MKLDepetStencilStateLib(MKLRenderer *renderer)
{
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLDepthStencilState: Failed to create MKLDepthStencilState because renderer is null")

    MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    MKL_NULL_CHECK_VOID(depthStencilDescriptor, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLDepthStencilState: Failed to create MTLDepthStencilDescriptor")

    depthStencilDescriptor.depthWriteEnabled = YES;
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    renderer->_depthStencilState = [renderer->_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    MKL_NULL_CHECK_VOID(renderer->_depthStencilState, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLDepthStencilState: Failed to create MTLDepthStencilState")

    // Release resources
    [depthStencilDescriptor release];
}