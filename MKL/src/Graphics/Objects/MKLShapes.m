#import "MKLShapes.h"
#import "../MKLTypes.h"
#import "../../Core/MKLError.h"
#import "../../Math/MKLMath.h"

#include <simd/matrix.h>

#include <Metal/Metal.h>
#import <MetalKit/MetalKit.h>


void MKLDrawCube(MKLRenderer *renderer, MKLCube cube, MKLColor color)
{
    matrix_float4x4 scaleM = MScale((vector_float3){cube.width, cube.height, cube.depth});
    matrix_float4x4 translateM = MTranslate(cube.position);
    matrix_float4x4 rotationM = MRotate(cube.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, scaleM);
    modelM = matrix_multiply(modelM, rotationM);

    // using 8 vertices to draw cube
    MKLVertex *cubeVertices = [MklDefs cubeVertices];

    // Define the order of the vertices
    ushort *cubeIndices = [MklDefs cubeIndices];
    
    [renderer->_renderEncoder setVertexBytes:&color length:sizeof(vector_float4) atIndex:2];
    [renderer->_renderEncoder setVertexBytes:&modelM length:sizeof(matrix_float4x4) atIndex:3];

    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getBufferWithBytes:cubeIndices
                                                                   length:sizeof(ushort) * 36];

    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getBufferWithBytes:cubeVertices
                                                                    length:sizeof(MKLVertex) * 8];

    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:36 indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:0];

    [indexBuffer release];
    [vertexBuffer release];
}

void MKLDrawPlane(MKLRenderer *renderer, MKLPlane plane, MKLColor color)
{
    matrix_float4x4 rotationM = MRotate(plane.rotation);
    matrix_float4x4 scaleM = MScale((vector_float3){plane.dimensions.x, plane.dimensions.y, 1.0f});
    matrix_float4x4 translateM = MTranslate(plane.position);
    matrix_float4x4 modelM = matrix_multiply(rotationM, scaleM);
    modelM = matrix_multiply(translateM, modelM);

    // the number of vertices in the plane = (segments + 1)^2
    plane.vertexCount = (plane.segments.x + 1 ) * (plane.segments.y + 1);
    MKLVertex planeVertices[plane.vertexCount];

    // set the vertices
    for (int i = 0; i < plane.segments.x + 1; i++) {
        for (int j = 0; j < plane.segments.y + 1; j++) {
            int index = i * (plane.segments.x + 1) + j;
            planeVertices[index].position = (vector_float4){plane.vertices[index].x, plane.vertices[index].y, plane.vertices[index].z, 1.0f};
        }
    }

    // set the indices
    int indexCount = plane.segments.x * plane.segments.y * 6;
    ushort planeIndices[indexCount];
    int index = 0;
    for (int i = 0; i < plane.segments.x; i++) {
        for (int j = 0; j < plane.segments.y; j++) {
            planeIndices[index++] = i * (plane.segments.x + 1) + j;
            planeIndices[index++] = (i + 1) * (plane.segments.x + 1) + j;
            planeIndices[index++] = (i + 1) * (plane.segments.x + 1) + j + 1;
            planeIndices[index++] = i * (plane.segments.x + 1) + j;
            planeIndices[index++] = (i + 1) * (plane.segments.x + 1) + j + 1;
            planeIndices[index++] = i * (plane.segments.x + 1) + j + 1;
        }
    }

    [renderer->_renderEncoder setVertexBytes:&modelM length:sizeof(matrix_float4x4) atIndex:3];
    [renderer->_renderEncoder setVertexBytes:&color length:sizeof(vector_float4) atIndex:2];

    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getBufferWithBytes:planeIndices
                                                                   length:sizeof(planeIndices)];

    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getBufferWithBytes:planeVertices
                                                                  length:sizeof(planeVertices)];

    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:indexCount indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:0];

    [indexBuffer release];
    [vertexBuffer release];
}

void MKLGetPlaneVertices(MKLPlane *plane)
{
    plane->vertexCount = (plane->segments.x + 1 ) * (plane->segments.y + 1);
    plane->vertices = malloc(sizeof(vector_float3) * plane->vertexCount);
    MKL_NULL_CHECK_VOID(plane->vertices, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, "MKLGetPlaneVertices: Failed to allocate memory for vertices")
    for (int i = 0; i < plane->segments.x + 1; i++) {
        for (int j = 0; j < plane->segments.y + 1; j++) {
            int index = i * (plane->segments.x + 1) + j;
            plane->vertices[index] = (vector_float3){(float)i / plane->segments.x - 0.5f, (float)j / plane->segments.y - 0.5f, 0.0f};
        }
    }
}