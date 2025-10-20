#import "MKLMesh.h"
#import "../MKLTypes.h"
#import "../../Core/MKLError.h"
#import "../../Math/MKLMath.h"

#include <math.h>
#include <stdio.h>
#include <simd/vector_types.h>
#include <simd/conversion.h>

#include <ModelIO/ModelIO.h>
#include <Metal/Metal.h>
#import <simd/matrix.h>

void MKLMeshPlane(MKLMesh *mesh, MKLRenderer *renderer, const vector_float3 position, const vector_float2 dimensions, const simd_uint2 segments, const vector_float3 rotation)
{
    // Use enhanced vertex descriptor if available (has normals and UVs)
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor)
    {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Create a new plane mesh
    MDLMesh *mdlMesh = [MDLMesh newPlaneWithDimensions:dimensions
                                            segments:segments
                                        geometryType:MDLGeometryTypeTriangles
                                           allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&error];
    
    if (!mesh->_mtkMesh)
    {
        fprintf(stderr, "MKL Error: Failed to create plane mesh: %s\n", 
                error ? [[error localizedDescription] UTF8String] : "unknown error");
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create plane mesh";
        return;
    }

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;
    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = (vector_float3){1.0f, 0.0f, 1.0f};
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};
}

void MKLMeshBox(MKLMesh *mesh, MKLRenderer *renderer, const vector_float3 position, const vector_float3 dimensions, const simd_uint3 segments, const vector_float3 rotation)
{
    // Use enhanced vertex descriptor if available
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor)
    {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Create a new box mesh
    MDLMesh *mdlMesh = [MDLMesh newBoxWithDimensions:dimensions
                                          segments:segments
                                      geometryType:MDLGeometryTypeTriangles
                                         inwardNormals:NO
                                           allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&error];
    if (!mesh->_mtkMesh)
    {
        fprintf(stderr, "MKL Error: Failed to create box mesh: %s\n", 
                [[error localizedDescription] UTF8String]);
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create box mesh";
        return;
    }

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;
    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = segments;
}

void MKLMeshSphere(MKLMesh *mesh, MKLRenderer *renderer, const vector_float3 position, const vector_float3 dimensions, const simd_uint2 segments, const vector_float3 rotation)
{
    // Use enhanced vertex descriptor if available
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor)
    {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Create a new sphere mesh
    MDLMesh *mdlMesh = [MDLMesh newEllipsoidWithRadii:dimensions
                                            radialSegments:segments.x
                                            verticalSegments:segments.y
                                            geometryType:MDLGeometryTypeTriangles
                                            inwardNormals:NO
                                            hemisphere:NO
                                            allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&error];
    if (!mesh->_mtkMesh)
    {
        fprintf(stderr, "MKL Error: Failed to create sphere mesh: %s\n", 
                [[error localizedDescription] UTF8String]);
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create sphere mesh";
        return;
    }

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;
    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};
}

void MKLMeshCylinder(MKLMesh *mesh, MKLRenderer *renderer, const vector_float3 position, const vector_float3 dimensions, const simd_uint3 segments, const vector_float3 rotation)
{
    // Use enhanced vertex descriptor if available
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor)
    {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Create a new cylinder mesh
    MDLMesh *mdlMesh = [MDLMesh newCylinderWithHeight:dimensions.y
                                            radii:(vector_float2){dimensions.x, dimensions.z}
                                            radialSegments:segments.x
                                            verticalSegments:segments.z
                                            geometryType:MDLGeometryTypeTriangles
                                            inwardNormals:NO
                                            allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&error];
    if (!mesh->_mtkMesh)
    {
        fprintf(stderr, "MKL Error: Failed to create cylinder mesh: %s\n", 
                [[error localizedDescription] UTF8String]);
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create cylinder mesh";
        return;
    }

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;
    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = (vector_float3){dimensions.x, dimensions.y, 1.0f};
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};
}

void MKLMeshCapsule(MKLMesh *mesh, MKLRenderer *renderer, const vector_float3 position, const vector_float3 dimensions, const simd_uint2 segments, const vector_float3 rotation)
{
    // Use enhanced vertex descriptor if available
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor)
    {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Create a new capsule mesh
    MDLMesh *mdlMesh = [[MDLMesh alloc] initCapsuleWithExtent:dimensions
                              cylinderSegments:segments.x
                              hemisphereSegments:segments.y
                              inwardNormals:NO
                              geometryType:MDLGeometryTypeTriangles
                              allocator:renderer->_bufferAllocator];

    // Set up the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh->_mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                             device:renderer->_device
                                              error:&error];
    if (!mesh->_mtkMesh)
    {
        fprintf(stderr, "MKL Error: Failed to create capsule mesh: %s\n", 
                [[error localizedDescription] UTF8String]);
        gError.type = MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY;
        gError.message = "Failed to create capsule mesh";
        return;
    }

    mesh->vertexCount = mesh->_mtkMesh.vertexCount;
    mesh->position = position;
    mesh->rotation = rotation;
    mesh->dimensions = dimensions;
    mesh->segments = (simd_uint3){segments.x, segments.y, 0};
}

MKLMesh MKLMeshCreateWithFile(MKLRenderer *renderer, const char* path)
{
    MKLMesh mesh = {0};
    
    MKL_NULL_CHECK(renderer, NULL, MKL_ERROR_NULL_POINTER, 
                   "MKLMeshCreateWithFile: renderer is NULL", mesh);
    
    if (!path) {
        fprintf(stderr, "MKL Error: MKLMeshCreateWithFile: path is NULL\n");
        return mesh;
    }
    
    // Convert C string to NSString
    NSString *filePath = [NSString stringWithUTF8String:path];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (!fileURL) {
        fprintf(stderr, "MKL Error: MKLMeshCreateWithFile: Invalid file path: %s\n", path);
        return mesh;
    }
    
    // Check if file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        fprintf(stderr, "MKL Error: MKLMeshCreateWithFile: File does not exist: %s\n", path);
        return mesh;
    }
    
    // Create asset loader with options to handle missing material files
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:fileURL
                                   vertexDescriptor:nil
                                    bufferAllocator:renderer->_bufferAllocator
                                 preserveTopology:YES
                                            error:nil];
    
    if (!asset || asset.count == 0) {
        fprintf(stderr, "MKL Error: MKLMeshCreateWithFile: Failed to load asset: %s\n", path);
        return mesh;
    }
    
    // Get the first object from the asset
    MDLObject *object = [asset objectAtIndex:0];
    
    if (![object isKindOfClass:[MDLMesh class]]) {
        fprintf(stderr, "MKL Error: MKLMeshCreateWithFile: Object is not a mesh: %s\n", path);
        return mesh;
    }
    
    MDLMesh *mdlMesh = (MDLMesh *)object;
    
    // Use enhanced vertex descriptor to load normals and UVs from OBJ
    MTLVertexDescriptor *metalDesc = renderer->_vertexDescriptorEnhanced ? renderer->_vertexDescriptorEnhanced : renderer->_vertexDescriptor;
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalDesc);
    if (mdlVertexDescriptor) {
        mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
        if (renderer->_vertexDescriptorEnhanced) {
            mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
            mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
        }
    }
    
    // Set the vertex descriptor
    mdlMesh.vertexDescriptor = mdlVertexDescriptor;
    
    // Add normals if using enhanced rendering (will generate if not present)
    if (renderer->_vertexDescriptorEnhanced) {
        [mdlMesh addNormalsWithAttributeNamed:MDLVertexAttributeNormal creaseThreshold:0.0];
    }
    
    // Create a MetalKit mesh from the Model I/O mesh
    NSError *error = nil;
    mesh._mtkMesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                           device:renderer->_device
                                            error:&error];
    
    if (!mesh._mtkMesh) {
        fprintf(stderr, "MKL Error: Failed to create mesh from OBJ file: %s\n", 
                error ? [[error localizedDescription] UTF8String] : "unknown error");
        return mesh;
    }
    
    mesh.vertexCount = (int)mesh._mtkMesh.vertexCount;
    mesh.position = (vector_float3){0.0f, 0.0f, 0.0f};
    mesh.rotation = (vector_float3){0.0f, 0.0f, 0.0f};
    mesh.dimensions = (vector_float3){1.0f, 1.0f, 1.0f};
    mesh.segments = (simd_uint3){0, 0, 0};
    
    printf("✓ Successfully loaded OBJ file: %s (%d vertices)\n", path, mesh.vertexCount);
    
    return mesh;
}

void MKLDrawMesh(MKLRenderer *renderer, MKLMesh *mesh, const MKLColor color)
{
    MKL_NULL_CHECK_VOID(mesh, NULL, MKL_ERROR_NULL_POINTER, "Failed to draw mesh: mesh is NULL");
    
    const matrix_float4x4 rotationM = MRotate(mesh->rotation);
    const matrix_float4x4 scaleM = MScale((vector_float3){mesh->dimensions.x, mesh->dimensions.y, mesh->dimensions.z});
    const matrix_float4x4 translateM = MTranslate(mesh->position);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);

    // Check if we should use enhanced rendering (MTKMesh already has normals from ModelIO!)
    bool useLighting = renderer->_enhancedRenderingEnabled && renderer->_pipelineStateLit;
    
    if (useLighting) {
        // Use enhanced pipeline - MTKMesh from ModelIO already has normals!
        [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineStateLit];
        [renderer->_renderEncoder setVertexBytes:&color length:sizeof(vector_float4) atIndex:2];
        [renderer->_renderEncoder setVertexBytes:&modelM length:sizeof(matrix_float4x4) atIndex:3];
        [renderer->_renderEncoder setVertexBuffer:mesh->_mtkMesh.vertexBuffers[0].buffer offset:0 atIndex:0];
        
        // OPTIMIZATION: Lighting buffers already bound in MKLBeginDrawing
        
        for (MTKSubmesh *submesh in mesh->_mtkMesh.submeshes) {
            [renderer->_renderEncoder drawIndexedPrimitives:submesh.primitiveType
                                                indexCount:submesh.indexCount
                                                 indexType:submesh.indexType
                                              indexBuffer:submesh.indexBuffer.buffer
                                        indexBufferOffset:submesh.indexBuffer.offset];
        }
        
        // Restore default pipeline
        [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    } else {
        // Use simple rendering (backwards compatible)
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
}
