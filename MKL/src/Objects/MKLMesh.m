#import "MKLMesh.h"
#import "../Renderer/MKLTypes.h"
#import "../Core/MKLError.h"
#import "../Math/MKLMath.h"

#include <math.h>
#include <stdio.h>

#include <ModelIO/ModelIO.h>
#include <Metal/Metal.h>
#import <simd/matrix.h>

void MKLMeshPlane(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float2 dimensions, simd_uint2 segments, vector_float3 rotation)
{
    // Create a new plane mesh
    mesh->_mdlMesh = [MDLMesh newPlaneWithDimensions:dimensions
                                            segments:segments
                                        geometryType:MDLGeometryTypeTriangles
                                           allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    MDLVertexDescriptor *meshDescriptor = MTKModelIOVertexDescriptorFromMetal(renderer->_vertexDescriptor);
    meshDescriptor.attributes[0].name = MDLVertexAttributePosition;
    meshDescriptor.attributes[1].name = MDLVertexAttributeColor;
    mesh->_mdlMesh.vertexDescriptor = meshDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mesh->_mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
}

void MKLDrawMesh(MKLRenderer *renderer, MKLMesh *mesh, MKLColor color)
{
    MKL_NULL_CHECK_VOID(mesh, NULL, MKL_ERROR_NULL_POINTER, "Failed to draw mesh. Mesh is NULL.")
    matrix_float4x4 modelM = MTranslate(mesh->position);
    modelM = simd_mul(modelM, MRotate(mesh->rotation));

    vector_float4 vcolor = { color.r, color.g, color.b, color.a };

    [renderer->_renderEncoder setVertexBytes:&vcolor length:sizeof(vector_float4) atIndex:2];
    [renderer->_renderEncoder setVertexBytes:&modelM length:sizeof(matrix_float4x4) atIndex:3];
    
    [renderer->_renderEncoder setVertexBuffer:mesh->_mtkMesh.vertexBuffers[0].buffer offset:0 atIndex:0];

    for (MTKSubmesh *submesh in mesh->_mtkMesh.submeshes) {
        [renderer->_renderEncoder drawIndexedPrimitives:submesh.primitiveType
                                            indexCount:submesh.indexCount
                                             indexType:submesh.indexType
                                          indexBuffer:submesh.indexBuffer.buffer
                                    indexBufferOffset:submesh.indexBuffer.offset];
    }
}