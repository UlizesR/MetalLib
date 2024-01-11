#import "MKLShapes.h"
#include <simd/matrix_types.h>
#import "../Core/MKLError.h"
#import "../Renderer/MKLTypes.h"
#import "../Math/MKLMath.h"

#include <simd/matrix.h>

#include <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

void MKLDrawShape(MKLRenderer *renderer, MKLVertex *vertices, NSUInteger vertexCount, MTLPrimitiveType primitiveType)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLDrawShape: Failed to draw shape because renderer is null", )

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:vertices
                                                             length:sizeof(MKLVertex) * vertexCount
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    // culled for now because it's not needed
    // [renderer->_renderEncoder setCullMode:MTLCullModeNone];
    [renderer->_renderEncoder drawPrimitives:primitiveType vertexStart:0 vertexCount:vertexCount];
}

void MKLDrawShape3D(MKLRenderer *renderer, MKLVertex *vertices, NSUInteger vertexCount, MTLPrimitiveType primitiveType)
{
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, "MKLDrawShape: Failed to draw shape because renderer is null", )

    [renderer->_renderEncoder setVertexBytes:&renderer->uniforms length:sizeof(MKLUniforms) atIndex:1];

    id<MTLBuffer> indexBuffer = [renderer->_device newBufferWithBytes:vertices
                                                               length:sizeof(MKLVertex) * vertexCount
                                                              options:MTLResourceStorageModeShared];

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:vertices
                                                             length:sizeof(MKLVertex) * vertexCount
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    // culled for now because it's not needed
    [renderer->_renderEncoder setCullMode:MTLCullModeFront];
    [renderer->_renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
    [renderer->_renderEncoder setFrontFacingWinding:MTLWindingClockwise];
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
        {.position = {rect.position.x - rect.width / 2, rect.position.y - rect.height / 2, 0.0f}, .color = vcolor},
        {.position = {rect.position.x + rect.width / 2, rect.position.y - rect.height / 2, 0.0f}, .color = vcolor},
        {.position = {rect.position.x - rect.width / 2, rect.position.y + rect.height / 2, 0.0f}, .color = vcolor},
        {.position = {rect.position.x + rect.width / 2, rect.position.y + rect.height / 2, 0.0f}, .color = vcolor}
    };

    // use triangle strip to draw rect so we only need 4 vertices instead of 6
    MKLDrawShape(renderer, rectVertices, 4, MTLPrimitiveTypeTriangleStrip);
}

void MKLDrawCube(MKLRenderer *renderer, MKLCube cube, MKLColor color)
{
    matrix_float4x4 scaleM = MScale((vector_float3){cube.width, cube.height, cube.depth});
    matrix_float4x4 translateM = MTranslate(cube.position);
    matrix_float4x4 modelM = matrix_multiply(translateM, scaleM);
    renderer->uniforms.modelMatrix = modelM;

    vector_float4 vcolor = { color.r, color.g, color.b, color.a };
    // using 8 vertices to draw cube
    MKLVertex cubeVertices[] = {
        {.position = {-1.0f, -1.0f, 1.0f}, .color = vcolor},
        {.position = { 1.0f, -1.0f,  1.0f}, .color = vcolor},
        {.position = { 1.0f,  1.0f,  1.0f}, .color = vcolor},
        {.position = {-1.0f,  1.0f,  1.0f}, .color = vcolor},
        {.position = {-1.0f,  1.0f, -1.0f}, .color = vcolor},
        {.position = {-1.0f, -1.0f, -1.0f}, .color = vcolor},
        {.position = {1.0f,  -1.0f, -1.0f}, .color = vcolor},
        {.position = { 1.0f,  1.0f, -1.0f}, .color = vcolor}
    };

    // Define the order of the vertices
    ushort cubeIndices[] = {
        0, 2, 3,0, 1, 2,
        1, 7, 2, 1, 6, 7,
        6, 5, 4, 4, 7, 6,
        3, 4, 5, 3, 5, 0,
        3, 7, 4, 3, 2, 7,
        0, 6, 1, 0, 5, 6

    };
    [renderer->_renderEncoder setVertexBytes:&renderer->uniforms length:sizeof(MKLUniforms) atIndex:1];

    id<MTLBuffer> indexBuffer = [renderer->_device newBufferWithBytes:cubeIndices
                                                               length:36 * sizeof(ushort)
                                                              options:MTLResourceStorageModeShared];

    renderer->_vertexBuffer = [renderer->_device newBufferWithBytes:cubeVertices
                                                             length:sizeof(cubeVertices)
                                                            options:MTLResourceStorageModeShared];

    [renderer->_renderEncoder setVertexBuffer:renderer->_vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder setCullMode:MTLCullModeFront];
    // [renderer->_renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:36 indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:0];

    [indexBuffer release];
    [renderer->_vertexBuffer release];
}