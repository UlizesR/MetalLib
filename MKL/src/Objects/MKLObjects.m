#import "MKLObjects.h"
#include <simd/vector_make.h>
#include <simd/conversion.h>
#import "../Renderer/MKLTypes.h"
#import "../Math/MKLMath.h"

#import <Metal/Metal.h>

void MKLDrawAxis(MKLRenderer* renderer, float length)
{
    if (renderer == nil)
    {
        NSLog(@"MKLDrawAxis: renderer is nil");
        return;
    }

    vector_float3 x_axis = simd_make_float3(length, 0.0f, 0.0f);
    vector_float3 y_axis = simd_make_float3(0.0f, length, 0.0f);
    vector_float3 z_axis = simd_make_float3(0.0f, 0.0f, length);


    MKLVertex lineVertices[3][2] = {
    {
        {.position = WORLD_ORIGIN, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_RED)},
        {.position = x_axis, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_RED)},
    },
    {
        {.position = WORLD_ORIGIN, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_GREEN)},
        {.position = y_axis, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_GREEN)},
    },
    {
        {.position = WORLD_ORIGIN, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_BLUE)},
        {.position = z_axis, .color = MKL_COLOR2VECTOR_F4(MKL_COLOR_BLUE)},
    }
    };

    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];

    for (int i = 0; i < 3; i++)
    {
        id<MTLBuffer> vertexBuffer = [renderer->_device newBufferWithBytes:&lineVertices[i]
                                                                     length:sizeof(MKLVertex) * 2
                                                                    options:MTLResourceStorageModeShared];

        if (vertexBuffer == nil) 
        {
            NSLog(@"MKLDrawAxisHelper: Failed to create vertex buffer");
            return;
        }

        [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        [renderer->_renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:2];
    }
}