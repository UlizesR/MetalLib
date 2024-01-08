#import "MKLShapes.h"

void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle *triangle)
{
    if (renderer == nil) 
    {
        NSLog(@"MKLDrawTriangle: renderer is nil");
        return;
    }

    if (triangle == nil) 
    {
        NSLog(@"MKLDrawTriangle: triangle is nil");
        return;
    }

    vector_float3 triangleVertices[] = {
        triangle->p1,
        triangle->p2,
        triangle->p3
    };

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:&triangleVertices
                                                             length:sizeof(triangleVertices)
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
}