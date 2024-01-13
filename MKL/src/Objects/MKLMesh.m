#import "MKLMesh.h"
#include <simd/vector_types.h>
#include <simd/conversion.h>
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
    MDLMesh *mdlMesh = [MDLMesh newPlaneWithDimensions:dimensions
                                            segments:segments
                                        geometryType:MDLGeometryTypeTriangles
                                           allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = renderer->_mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = (vector_float3){1, 0, 1};
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};

    [mdlMesh release];
}

void MKLMeshBox(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float3 dimensions, simd_uint3 segments, vector_float3 rotation)
{
    // Create a new box mesh
    MDLMesh *mdlMesh = [MDLMesh newBoxWithDimensions:dimensions
                                          segments:segments
                                      geometryType:MDLGeometryTypeTriangles
                                         inwardNormals:NO
                                           allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = renderer->_mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = segments;

    [mdlMesh release];
}

void MKLMeshSphere(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float3 dimensions, simd_uint2 segments, vector_float3 rotation)
{
    // Create a new sphere mesh
    MDLMesh *mdlMesh = [MDLMesh newEllipsoidWithRadii:dimensions
                                            radialSegments:segments.x
                                            verticalSegments:segments.y
                                            geometryType:MDLGeometryTypeTriangles
                                            inwardNormals:NO
                                            hemisphere:NO
                                            allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = renderer->_mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};

    [mdlMesh release];
}

void MKLMeshCylinder(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float3 dimensions, simd_uint3 segments, vector_float3 rotation)
{
    // Create a new cylinder mesh
    MDLMesh *mdlMesh = [MDLMesh newCylinderWithHeight:dimensions.y
                                            radii:(vector_float2){dimensions.x, dimensions.z}
                                            radialSegments:segments.x
                                            verticalSegments:segments.z
                                            geometryType:MDLGeometryTypeTriangles
                                            inwardNormals:NO
                                            allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = renderer->_mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = (vector_float3){dimensions.x, dimensions.y, 1.0f};
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};

    [mdlMesh release];
}

void MKLMeshCapsule(MKLMesh *mesh, MKLRenderer *renderer, vector_float3 position, vector_float3 dimensions, simd_uint2 segments, vector_float3 rotation)
{
    // Create a new capsule mesh
    MDLMesh *mdlMesh = [[MDLMesh alloc] initCapsuleWithExtent:dimensions
                              cylinderSegments:segments.x
                              hemisphereSegments:segments.y
                              inwardNormals:NO
                              geometryType:MDLGeometryTypeTriangles
                              allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = renderer->_mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&gError._error];
    MKL_NULL_CHECK_VOID(mesh->_mtkMesh, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, gError.message);

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;

    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};

    [mdlMesh release];
}

void MKLDrawMesh(MKLRenderer *renderer, MKLMesh *mesh, MKLColor color)
{
    MKL_NULL_CHECK_VOID(mesh, NULL, MKL_ERROR_NULL_POINTER, "Failed to draw mesh. Mesh is NULL.")
    matrix_float4x4 rotationM = MRotate(mesh->rotation);
    matrix_float4x4 scaleM = MScale((vector_float3){mesh->dimensions.x, mesh->dimensions.y, mesh->dimensions.z});
    matrix_float4x4 translateM = MTranslate(mesh->position);
    matrix_float4x4 modelM = matrix_multiply(rotationM, scaleM);
    modelM = matrix_multiply(translateM, modelM);

    [renderer->_renderEncoder setVertexBytes:&color length:sizeof(vector_float4) atIndex:2];
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