#import "MKLLibraries.h"
#import "MKLTypes.h"
#import "MKLRenderer.h"
#import "../MKLUtils.h"

#include <stdio.h>

void MKLShaderLib(MKLRenderer *renderer, const char *shaderPath)
{
    
    NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *shaderPathString = [currentDirectory stringByAppendingPathComponent:@(shaderPath)];
    
    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:shaderPathString
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (error != nil) 
    {
        NSLog(@"MKLShaderLib: %@", error);
        return;
    }

    renderer->_library = [renderer->_device newLibraryWithSource:shaderSource
                                                          options:nil
                                                            error:&error];

    if (error != nil)
    {
        NSLog(@"MKLShaderLib: %@", error);
        return;
    }

    [shaderSource release];
}

void MKLRenderPipelineLib(MKLRenderer *renderer)
{
    if (renderer == nil) 
    {
        NSLog(@"MKLRenderPipeline: renderer is nil");
        return;
    }

    NSError *error = nil;
    id<MTLFunction> vertexFunction = [renderer->_library newFunctionWithName:@"vertexShader"];
    if (vertexFunction == nil) 
    {
        NSLog(@"MKLRenderPipeline: vertexFunction is nil");
        return;
    }
    id<MTLFunction> fragmentFunction = [renderer->_library newFunctionWithName:@"fragmentShader"];
    if (fragmentFunction == nil) 
    {
        NSLog(@"MKLRenderPipeline: fragmentFunction is nil");
        return;
    }

    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    if (pipelineDescriptor == nil) 
    {
        NSLog(@"MKLRenderPipeline: pipelineDescriptor is nil");
        return;
    }
    pipelineDescriptor.colorAttachments[0].pixelFormat = renderer->_metalLayer.pixelFormat;
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = renderer->_vertexDescriptor;

    renderer->_pipelineState = [renderer->_device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                                 error:&error];

    if (error != nil)
    {
        NSLog(@"MKLRenderPipeline: %@", error);
        return;
    }

    [pipelineDescriptor release];

}

void MKLVertexDescriptorLib(MKLRenderer *renderer)
{
    if (renderer == nil) 
    {
        NSLog(@"MKLVertexDescriptor: renderer is nil");
        return;
    }

    renderer->_vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    if (renderer->_vertexDescriptor == nil) 
    {
        NSLog(@"MKLVertexDescriptor: vertexDescriptor is nil");
        return;
    }

    // Position
    renderer->_vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    renderer->_vertexDescriptor.attributes[0].offset = 0;
    renderer->_vertexDescriptor.attributes[0].bufferIndex = 0;

    // Color
    renderer->_vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
    renderer->_vertexDescriptor.attributes[1].offset = sizeof(vector_float3);
    renderer->_vertexDescriptor.attributes[1].bufferIndex = 0;

    renderer->_vertexDescriptor.layouts[0].stride = sizeof(MKLVertex);
}