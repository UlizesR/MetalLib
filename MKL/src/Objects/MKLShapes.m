#import "MKLShapes.h"
#include <Metal/Metal.h>
#import "../Core/MKLError.h"
#import "../Renderer/MKLTypes.h"

#import <MetalKit/MetalKit.h>

void MKLDrawShape(MKLRenderer *renderer, MKLVertex *vertices, NSUInteger vertexCount, MTLPrimitiveType primitiveType)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLDrawShape: Failed to draw shape because renderer is null", )

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:vertices
                                                             length:sizeof(MKLVertex) * vertexCount
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    // culled for now because it's not needed
    [renderer->_renderEncoder setCullMode:MTLCullModeNone];
    [renderer->_renderEncoder drawPrimitives:primitiveType vertexStart:0 vertexCount:vertexCount];
}

void MKLDrawLine2D(MKLRenderer *renderer, MKLLine line, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex lineVertices[] = { 
        {.position = {line.p1.x, line.p1.y, 0.0f}, .color = vcolor},
        {.position = {line.p2.x, line.p2.y, 0.0f}, .color = vcolor}
    };
    MKLDrawShape(renderer, lineVertices, 2, MTLPrimitiveTypeLine);
}

void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle triangle, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex triangleVertices[] = {
        {.position = {triangle.p1.x, triangle.p1.y, 0.0f}, .color = vcolor},
        {.position = {triangle.p2.x, triangle.p2.y, 0.0f}, .color = vcolor},
        {.position = {triangle.p3.x, triangle.p3.y, 0.0f}, .color = vcolor}
    };
    MKLDrawShape(renderer, triangleVertices, 3, MTLPrimitiveTypeTriangle);
}

void MKLDrawRect(MKLRenderer *renderer, MKLRect rect, MKLColor color)
{
    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    MKLVertex rectVertices[] = {
        {.position = {rect.origin.x, rect.origin.y, 0.0f}, .color = vcolor},
        {.position = {rect.origin.x + rect.width, rect.origin.y, 0.0f}, .color = vcolor},
        {.position = {rect.origin.x, rect.origin.y + rect.height, 0.0f}, .color = vcolor},
        {.position = {rect.origin.x + rect.width, rect.origin.y + rect.height, 0.0f}, .color = vcolor}
    };

    // use triangle strip to draw rect so we only need 4 vertices instead of 6
    MKLDrawShape(renderer, rectVertices, 4, MTLPrimitiveTypeTriangleStrip);
}