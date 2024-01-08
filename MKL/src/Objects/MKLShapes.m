#import "MKLShapes.h"
#import "../Renderer/MKLTypes.h"

#import <MetalKit/MetalKit.h>

void MKLDrawShape(MKLRenderer *renderer, MKLVertex *vertices, NSUInteger vertexCount, MTLPrimitiveType primitiveType)
{
    if (renderer == nil) 
    {
        NSLog(@"MKLDrawShape: renderer is nil");
        return;
    }

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:vertices
                                                             length:sizeof(MKLVertex) * vertexCount
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder drawPrimitives:primitiveType vertexStart:0 vertexCount:vertexCount];
}

void MKLDrawLine2D(MKLRenderer *renderer, MKLLine line, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex lineVertices[] = { 
        {.position = line.p1, .color = vcolor},
        {.position = line.p2, .color = vcolor}
    };
    MKLDrawShape(renderer, lineVertices, 2, MTLPrimitiveTypeLine);
}

void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle triangle, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex triangleVertices[] = {
        {.position = triangle.p1, .color = vcolor},
        {.position = triangle.p2, .color = vcolor},
        {.position = triangle.p3, .color = vcolor}
    };
    MKLDrawShape(renderer, triangleVertices, 3, MTLPrimitiveTypeTriangle);
}

void MKLDrawRect(MKLRenderer *renderer, MKLRect rect, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex rectVertices[] = {
        {.position = {rect.x, rect.y, 0.0}, .color = vcolor},
        {.position = {rect.x + rect.width, rect.y, 0.0}, .color = vcolor},
        {.position = {rect.x, rect.y + rect.height, 0.0}, .color = vcolor},
        {.position = {rect.x + rect.width, rect.y + rect.height, 0.0}, .color = vcolor}
    };

    MKLDrawShape(renderer, rectVertices, 4, MTLPrimitiveTypeTriangleStrip);
}