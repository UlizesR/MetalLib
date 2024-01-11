#import "MKLObjects.h"
#include <simd/matrix_types.h>
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

    vector_float4 x_axis = simd_make_float4(length, 0.0f, 0.0f, 1.0f);
    vector_float4 y_axis = simd_make_float4(0.0f, length, 0.0f, 1.0f);
    vector_float4 z_axis = simd_make_float4(0.0f, 0.0f, length, 1.0f);

    matrix_float4x4 axisModelMatrix = {
        .columns[0] = x_axis,
        .columns[1] = y_axis,
        .columns[2] = z_axis,
        .columns[3] = WORLD_ORIGIN
    };

    vector_float4 red = MKL_COLOR2VECTOR_F4(MKL_COLOR_RED);
    vector_float4 green = MKL_COLOR2VECTOR_F4(MKL_COLOR_GREEN);
    vector_float4 blue = MKL_COLOR2VECTOR_F4(MKL_COLOR_BLUE);

    MKLVertex lineVertices[6] = {
        {.position = WORLD_ORIGIN, .color = red},
        {.position = x_axis, .color = red},
        {.position = WORLD_ORIGIN, .color = green},
        {.position = y_axis, .color = green},
        {.position = WORLD_ORIGIN, .color = blue},
        {.position = z_axis, .color = blue}
    };

    renderer->uniforms.modelMatrix = axisModelMatrix;

    [renderer->_renderEncoder setVertexBytes:&renderer->uniforms length:sizeof(MKLUniforms) atIndex:1];

    id<MTLBuffer> vertexBuffer = [renderer->_device newBufferWithBytes:lineVertices
                                                                 length:sizeof(lineVertices)
                                                                options:MTLResourceStorageModeShared];

    if (vertexBuffer == nil) 
    {
        NSLog(@"MKLDrawAxisHelper: Failed to create vertex buffer");
        return;
    }

    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];

    for (int i = 0; i < 3; i++)
    {
        [renderer->_renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:i*2 vertexCount:2];
    }
}