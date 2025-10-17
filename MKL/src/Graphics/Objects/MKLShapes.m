#import "MKLShapes.h"
#import "../MKLTypes.h"
#import "../../Core/MKLError.h"
#import "../../Math/MKLMath.h"

#include <simd/matrix.h>
#include <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#pragma mark - Shape Geometry Cache

// Cached geometry for parametric shapes
static struct {
    vector_float3 *vertices;
    unsigned short *indices;
    int vertexCount;
    int indexCount;
    int segments;
    bool initialized;
} _sphereCache = {NULL, NULL, 0, 0, 0, false};

static struct {
    vector_float3 *vertices;
    unsigned short *indices;
    int vertexCount;
    int indexCount;
    int segments;
    bool initialized;
} _cylinderCache = {NULL, NULL, 0, 0, 0, false};

static struct {
    vector_float3 *vertices;
    unsigned short *indices;
    int vertexCount;
    int indexCount;
    int segments;
    bool initialized;
} _coneCache = {NULL, NULL, 0, 0, 0, false};

static struct {
    vector_float3 *vertices;
    unsigned short *indices;
    int vertexCount;
    int indexCount;
    int majorSegments;
    int minorSegments;
    bool initialized;
} _torusCache = {NULL, NULL, 0, 0, 0, 0, false};

#pragma mark - Helper Functions

static inline void DrawIndexedPrimitive(MKLRenderer *renderer, 
                                       id<MTLBuffer> vertexBuffer,
                                       id<MTLBuffer> indexBuffer,
                                       int indexCount,
                                       const matrix_float4x4 *modelM,
                                       const MKLColor *color)
{
    [renderer->_renderEncoder setVertexBytes:color length:sizeof(vector_float4) atIndex:2];
    [renderer->_renderEncoder setVertexBytes:modelM length:sizeof(matrix_float4x4) atIndex:3];
    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                         indexCount:indexCount
                                          indexType:MTLIndexTypeUInt16
                                        indexBuffer:indexBuffer
                                  indexBufferOffset:0];
}

#pragma mark - Cube Drawing

void MKLDrawCube(MKLRenderer *renderer, const MKLCube cube, const MKLColor color)
{
    // Calculate model matrix
    const matrix_float4x4 scaleM = MScale((vector_float3){cube.width, cube.height, cube.depth});
    const matrix_float4x4 translateM = MTranslate(cube.position);
    const matrix_float4x4 rotationM = MRotate(cube.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);

    // Get static cube data
    MKLVertex *cubeVertices = [MklDefs cubeVertices];
    ushort *cubeIndices = [MklDefs cubeIndices];
    
    // Get reusable buffers from pool
    const NSUInteger vertexSize = sizeof(MKLVertex) * 8;
    const NSUInteger indexSize = sizeof(ushort) * 36;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer)
    {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for cube\n");
        return;
    }
    
    // Copy data to buffers
    memcpy(vertexBuffer.contents, cubeVertices, vertexSize);
    memcpy(indexBuffer.contents, cubeIndices, indexSize);
    
    // Draw using helper
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, 36, &modelM, &color);
}

#pragma mark - Plane Drawing

void MKLDrawPlane(MKLRenderer *renderer, const MKLPlane plane, const MKLColor color)
{
    // Calculate model matrix
    const matrix_float4x4 rotationM = MRotate(plane.rotation);
    const matrix_float4x4 scaleM = MScale((vector_float3){plane.dimensions.x, plane.dimensions.y, 1.0f});
    const matrix_float4x4 translateM = MTranslate(plane.position);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);

    // Calculate vertex and index counts
    const unsigned int vertexCount = (plane.segments.x + 1) * (plane.segments.y + 1);
    const unsigned int indexCount = plane.segments.x * plane.segments.y * 6;
    
    // Allocate buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer)
    {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for plane\n");
        return;
    }
    
    // Fill vertex buffer
    MKLVertex *vertices = (MKLVertex *)vertexBuffer.contents;
    for (unsigned int i = 0; i < plane.segments.x + 1; i++) 
    {
        for (unsigned int j = 0; j < plane.segments.y + 1; j++) 
        {
            const unsigned int index = i * (plane.segments.x + 1) + j;
            vertices[index].position = (vector_float4){
                plane.vertices[index].x, 
                plane.vertices[index].y, 
                plane.vertices[index].z, 
                1.0f
            };
        }
    }

    // Fill index buffer
    ushort *indices = (ushort *)indexBuffer.contents;
    unsigned int idx = 0;
    for (unsigned int i = 0; i < plane.segments.x; i++) 
    {
        for (unsigned int j = 0; j < plane.segments.y; j++) 
        {
            const unsigned int base = i * (plane.segments.x + 1) + j;
            const unsigned int next = base + (plane.segments.x + 1);
            
            // First triangle
            indices[idx++] = base;
            indices[idx++] = next;
            indices[idx++] = next + 1;
            
            // Second triangle
            indices[idx++] = base;
            indices[idx++] = next + 1;
            indices[idx++] = base + 1;
        }
    }

    // Set per-draw state
    [renderer->_renderEncoder setVertexBytes:&modelM length:sizeof(matrix_float4x4) atIndex:3];
    [renderer->_renderEncoder setVertexBytes:&color length:sizeof(vector_float4) atIndex:2];
    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    
    // Set wireframe mode for plane visualization
    [renderer->_renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
    
    // Draw
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle 
                                         indexCount:indexCount 
                                          indexType:MTLIndexTypeUInt16 
                                        indexBuffer:indexBuffer 
                                  indexBufferOffset:0];
    
    // Reset fill mode for subsequent draws
    [renderer->_renderEncoder setTriangleFillMode:MTLTriangleFillModeFill];
}

#pragma mark - Sphere Drawing

void MKLDrawSphere(MKLRenderer *renderer, const MKLSphere sphere, const MKLColor color)
{
    const int segments = sphere.segments > 0 ? sphere.segments : 32;
    
    // Check cache and generate if needed
    if (!_sphereCache.initialized || _sphereCache.segments != segments) {
        // Free old cache if exists
        if (_sphereCache.vertices) free(_sphereCache.vertices);
        if (_sphereCache.indices) free(_sphereCache.indices);
        
        // Generate new geometry
        MKLSphere templateSphere = {.position = {0, 0, 0}, .rotation = {0, 0, 0}, .radius = 1.0f, .segments = segments};
        MKLGetSphereVertices(&templateSphere, &_sphereCache.vertices, &_sphereCache.vertexCount, 
                            &_sphereCache.indices, &_sphereCache.indexCount);
        _sphereCache.segments = segments;
        _sphereCache.initialized = true;
    }
    
    if (!_sphereCache.vertices || !_sphereCache.indices) {
        fprintf(stderr, "MKL Error: Failed to get cached sphere vertices\n");
        return;
    }
    
    // Calculate model matrix
    const matrix_float4x4 scaleM = MScale((vector_float3){sphere.radius, sphere.radius, sphere.radius});
    const matrix_float4x4 translateM = MTranslate(sphere.position);
    const matrix_float4x4 rotationM = MRotate(sphere.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);
    
    // Get buffers from pool
    const NSUInteger vertexSize = sizeof(MKLVertex) * _sphereCache.vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * _sphereCache.indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for sphere\n");
        return;
    }
    
    // Convert vertices to MKLVertex format
    MKLVertex *mklVertices = (MKLVertex *)vertexBuffer.contents;
    for (int i = 0; i < _sphereCache.vertexCount; i++) {
        mklVertices[i].position = (vector_float4){_sphereCache.vertices[i].x, _sphereCache.vertices[i].y, _sphereCache.vertices[i].z, 1.0f};
    }
    
    // Copy indices
    memcpy(indexBuffer.contents, _sphereCache.indices, indexSize);
    
    // Draw using helper
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, _sphereCache.indexCount, &modelM, &color);
}

#pragma mark - Cylinder Drawing

void MKLDrawCylinder(MKLRenderer *renderer, const MKLCylinder cylinder, const MKLColor color)
{
    const int segments = cylinder.segments > 0 ? cylinder.segments : 32;
    
    // Check cache and generate if needed
    if (!_cylinderCache.initialized || _cylinderCache.segments != segments) {
        if (_cylinderCache.vertices) free(_cylinderCache.vertices);
        if (_cylinderCache.indices) free(_cylinderCache.indices);
        
        MKLCylinder templateCylinder = {.position = {0, 0, 0}, .rotation = {0, 0, 0}, .radius = 1.0f, .height = 1.0f, .segments = segments};
        MKLGetCylinderVertices(&templateCylinder, &_cylinderCache.vertices, &_cylinderCache.vertexCount, 
                              &_cylinderCache.indices, &_cylinderCache.indexCount);
        _cylinderCache.segments = segments;
        _cylinderCache.initialized = true;
    }
    
    if (!_cylinderCache.vertices || !_cylinderCache.indices) return;
    
    // Calculate model matrix
    const matrix_float4x4 scaleM = MScale((vector_float3){cylinder.radius, cylinder.height, cylinder.radius});
    const matrix_float4x4 translateM = MTranslate(cylinder.position);
    const matrix_float4x4 rotationM = MRotate(cylinder.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);
    
    // Get buffers from pool
    const NSUInteger vertexSize = sizeof(MKLVertex) * _cylinderCache.vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * _cylinderCache.indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) return;
    
    // Convert vertices
    MKLVertex *mklVertices = (MKLVertex *)vertexBuffer.contents;
    for (int i = 0; i < _cylinderCache.vertexCount; i++) {
        mklVertices[i].position = (vector_float4){_cylinderCache.vertices[i].x, _cylinderCache.vertices[i].y, _cylinderCache.vertices[i].z, 1.0f};
    }
    memcpy(indexBuffer.contents, _cylinderCache.indices, indexSize);
    
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, _cylinderCache.indexCount, &modelM, &color);
}

#pragma mark - Cone Drawing

void MKLDrawCone(MKLRenderer *renderer, const MKLCone cone, const MKLColor color)
{
    const int segments = cone.segments > 0 ? cone.segments : 32;
    
    // Check cache and generate if needed
    if (!_coneCache.initialized || _coneCache.segments != segments) {
        if (_coneCache.vertices) free(_coneCache.vertices);
        if (_coneCache.indices) free(_coneCache.indices);
        
        MKLCone templateCone = {.position = {0, 0, 0}, .rotation = {0, 0, 0}, .radius = 1.0f, .height = 1.0f, .segments = segments};
        MKLGetConeVertices(&templateCone, &_coneCache.vertices, &_coneCache.vertexCount, 
                          &_coneCache.indices, &_coneCache.indexCount);
        _coneCache.segments = segments;
        _coneCache.initialized = true;
    }
    
    if (!_coneCache.vertices || !_coneCache.indices) return;
    
    // Calculate model matrix
    const matrix_float4x4 scaleM = MScale((vector_float3){cone.radius, cone.height, cone.radius});
    const matrix_float4x4 translateM = MTranslate(cone.position);
    const matrix_float4x4 rotationM = MRotate(cone.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);
    
    // Get buffers from pool
    const NSUInteger vertexSize = sizeof(MKLVertex) * _coneCache.vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * _coneCache.indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) return;
    
    // Convert vertices
    MKLVertex *mklVertices = (MKLVertex *)vertexBuffer.contents;
    for (int i = 0; i < _coneCache.vertexCount; i++) {
        mklVertices[i].position = (vector_float4){_coneCache.vertices[i].x, _coneCache.vertices[i].y, _coneCache.vertices[i].z, 1.0f};
    }
    memcpy(indexBuffer.contents, _coneCache.indices, indexSize);
    
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, _coneCache.indexCount, &modelM, &color);
}

#pragma mark - Torus Drawing

void MKLDrawTorus(MKLRenderer *renderer, const MKLTorus torus, const MKLColor color)
{
    const int majorSegments = torus.majorSegments > 0 ? torus.majorSegments : 32;
    const int minorSegments = torus.minorSegments > 0 ? torus.minorSegments : 16;
    
    // Check cache and generate if needed
    if (!_torusCache.initialized || _torusCache.majorSegments != majorSegments || _torusCache.minorSegments != minorSegments) {
        if (_torusCache.vertices) free(_torusCache.vertices);
        if (_torusCache.indices) free(_torusCache.indices);
        
        MKLTorus templateTorus = {.position = {0, 0, 0}, .rotation = {0, 0, 0}, .majorRadius = 1.0f, .minorRadius = 0.3f, 
                                  .majorSegments = majorSegments, .minorSegments = minorSegments};
        MKLGetTorusVertices(&templateTorus, &_torusCache.vertices, &_torusCache.vertexCount, 
                           &_torusCache.indices, &_torusCache.indexCount);
        _torusCache.majorSegments = majorSegments;
        _torusCache.minorSegments = minorSegments;
        _torusCache.initialized = true;
    }
    
    if (!_torusCache.vertices || !_torusCache.indices) return;
    
    // Calculate model matrix
    const matrix_float4x4 scaleM = MScale((vector_float3){torus.majorRadius, torus.majorRadius, torus.majorRadius});
    const matrix_float4x4 translateM = MTranslate(torus.position);
    const matrix_float4x4 rotationM = MRotate(torus.rotation);
    matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
    modelM = matrix_multiply(modelM, scaleM);
    
    // Get buffers from pool
    const NSUInteger vertexSize = sizeof(MKLVertex) * _torusCache.vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * _torusCache.indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) return;
    
    // Convert vertices
    MKLVertex *mklVertices = (MKLVertex *)vertexBuffer.contents;
    for (int i = 0; i < _torusCache.vertexCount; i++) {
        mklVertices[i].position = (vector_float4){_torusCache.vertices[i].x, _torusCache.vertices[i].y, _torusCache.vertices[i].z, 1.0f};
    }
    memcpy(indexBuffer.contents, _torusCache.indices, indexSize);
    
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, _torusCache.indexCount, &modelM, &color);
}

#pragma mark - 2D Shape Drawing

void MKLDrawCircle(MKLRenderer *renderer, const MKLCircle circle, const MKLColor color)
{
    const int segments = circle.segments > 0 ? circle.segments : 32;
    const int vertexCount = segments + 2; // Center + perimeter + duplicate first
    const int indexCount = segments * 3;
    
    // Allocate buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for circle\n");
        return;
    }
    
    // Generate circle vertices
    MKLVertex *vertices = (MKLVertex *)vertexBuffer.contents;
    
    // Center vertex
    vertices[0].position = (vector_float4){circle.position.x, circle.position.y, 0.0f, 1.0f};
    
    // Perimeter vertices
    for (int i = 0; i <= segments; i++) {
        const float angle = 2.0f * M_PI * i / segments;
        const float x = circle.position.x + circle.radius * cosf(angle);
        const float y = circle.position.y + circle.radius * sinf(angle);
        vertices[i + 1].position = (vector_float4){x, y, 0.0f, 1.0f};
    }
    
    // Generate indices
    ushort *indices = (ushort *)indexBuffer.contents;
    int idx = 0;
    for (int i = 0; i < segments; i++) {
        indices[idx++] = 0;           // Center
        indices[idx++] = i + 1;       // Current perimeter vertex
        indices[idx++] = i + 2;       // Next perimeter vertex
    }
    
    // Identity matrix for 2D (vertices already in world space)
    matrix_float4x4 modelM = matrix_identity_float4x4;
    
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, indexCount, &modelM, &color);
}

void MKLDrawPolygon(MKLRenderer *renderer, const MKLPolygon polygon, const MKLColor color)
{
    const int sides = polygon.sides > 2 ? polygon.sides : 3;
    const int vertexCount = sides + 2; // Center + vertices + duplicate first
    const int indexCount = sides * 3;
    
    // Allocate buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for polygon\n");
        return;
    }
    
    // Generate polygon vertices
    MKLVertex *vertices = (MKLVertex *)vertexBuffer.contents;
    
    // Center vertex
    vertices[0].position = (vector_float4){polygon.position.x, polygon.position.y, 0.0f, 1.0f};
    
    // Perimeter vertices
    for (int i = 0; i <= sides; i++) {
        const float angle = 2.0f * M_PI * i / sides + polygon.rotation;
        const float x = polygon.position.x + polygon.radius * cosf(angle);
        const float y = polygon.position.y + polygon.radius * sinf(angle);
        vertices[i + 1].position = (vector_float4){x, y, 0.0f, 1.0f};
    }
    
    // Generate indices
    ushort *indices = (ushort *)indexBuffer.contents;
    int idx = 0;
    for (int i = 0; i < sides; i++) {
        indices[idx++] = 0;           // Center
        indices[idx++] = i + 1;       // Current vertex
        indices[idx++] = i + 2;       // Next vertex
    }
    
    matrix_float4x4 modelM = matrix_identity_float4x4;
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, indexCount, &modelM, &color);
}

void MKLDrawRectangle(MKLRenderer *renderer, const MKLRect rect, const MKLColor color)
{
    const vector_float3 position = {rect.position.x, rect.position.y, 0.0f};
    
    MKLCube quad = {
        .position = position,
        .rotation = {0.0f, 0.0f, 0.0f},
        .width = rect.width,
        .height = rect.height,
        .depth = 0.0f
    };
    
    MKLDrawCube(renderer, quad, color);
}

void MKLDrawTriangle(MKLRenderer *renderer, const MKLTriangle triangle, const MKLColor color)
{
    const int vertexCount = 3;
    const int indexCount = 3;
    
    // Allocate buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for triangle\n");
        return;
    }
    
    // Generate triangle vertices
    MKLVertex *vertices = (MKLVertex *)vertexBuffer.contents;
    vertices[0].position = (vector_float4){triangle.p1.x, triangle.p1.y, 0.0f, 1.0f};
    vertices[1].position = (vector_float4){triangle.p2.x, triangle.p2.y, 0.0f, 1.0f};
    vertices[2].position = (vector_float4){triangle.p3.x, triangle.p3.y, 0.0f, 1.0f};
    
    // Generate indices
    ushort *indices = (ushort *)indexBuffer.contents;
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    
    matrix_float4x4 modelM = matrix_identity_float4x4;
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, indexCount, &modelM, &color);
}

void MKLDrawLine(MKLRenderer *renderer, const MKLLine line, const MKLColor color)
{
    const float lineThickness = 0.02f; // Thin line
    const int vertexCount = 4;
    const int indexCount = 6;
    
    // Allocate buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) {
        fprintf(stderr, "MKL Error: Failed to allocate buffers for line\n");
        return;
    }
    
    // Calculate line direction and perpendicular
    const float dx = line.p2.x - line.p1.x;
    const float dy = line.p2.y - line.p1.y;
    const float length = sqrtf(dx * dx + dy * dy);
    
    if (length < 0.0001f) {
        return; // Line is too short to render
    }
    
    // Normalized direction
    const float dirX = dx / length;
    const float dirY = dy / length;
    
    // Perpendicular vector (rotated 90 degrees)
    const float perpX = -dirY * lineThickness;
    const float perpY = dirX * lineThickness;
    
    // Generate line vertices (as a thin quad)
    MKLVertex *vertices = (MKLVertex *)vertexBuffer.contents;
    vertices[0].position = (vector_float4){line.p1.x + perpX, line.p1.y + perpY, 0.0f, 1.0f};
    vertices[1].position = (vector_float4){line.p1.x - perpX, line.p1.y - perpY, 0.0f, 1.0f};
    vertices[2].position = (vector_float4){line.p2.x + perpX, line.p2.y + perpY, 0.0f, 1.0f};
    vertices[3].position = (vector_float4){line.p2.x - perpX, line.p2.y - perpY, 0.0f, 1.0f};
    
    // Generate indices
    ushort *indices = (ushort *)indexBuffer.contents;
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 1;
    indices[4] = 3;
    indices[5] = 2;
    
    matrix_float4x4 modelM = matrix_identity_float4x4;
    DrawIndexedPrimitive(renderer, vertexBuffer, indexBuffer, indexCount, &modelM, &color);
}

#pragma mark - Utility Functions

void MKLGetPlaneVertices(MKLPlane *plane)
{
    MKL_NULL_CHECK_VOID(plane, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLGetPlaneVertices: plane is NULL");
    
    const unsigned int vertexCount = (plane->segments.x + 1) * (plane->segments.y + 1);
    plane->vertexCount = vertexCount;
    
    plane->vertices = (vector_float3 *)malloc(sizeof(vector_float3) * vertexCount);
    MKL_NULL_CHECK_VOID(plane->vertices, NULL, MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY, 
                        "MKLGetPlaneVertices: Failed to allocate memory for vertices");
    
    // Generate grid vertices
    for (unsigned int i = 0; i < plane->segments.x + 1; i++) 
    {
        for (unsigned int j = 0; j < plane->segments.y + 1; j++) 
        {
            const unsigned int index = i * (plane->segments.x + 1) + j;
            const float x = (float)i / (float)plane->segments.x - 0.5f;
            const float y = (float)j / (float)plane->segments.y - 0.5f;
            plane->vertices[index] = (vector_float3){x, y, 0.0f};
        }
    }
}

void MKLGetSphereVertices(MKLSphere *sphere, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount)
{
    MKL_NULL_CHECK_VOID(sphere, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLGetSphereVertices: sphere is NULL");
    
    const int segments = sphere->segments > 0 ? sphere->segments : 32;
    const int rings = segments / 2;
    
    *vertexCount = (rings + 1) * (segments + 1);
    *indexCount = rings * segments * 6;
    
    *vertices = (vector_float3 *)malloc(sizeof(vector_float3) * *vertexCount);
    *indices = (unsigned short *)malloc(sizeof(unsigned short) * *indexCount);
    
    if (!*vertices || !*indices) {
        fprintf(stderr, "MKL Error: Failed to allocate memory for sphere vertices\n");
        if (*vertices) free(*vertices);
        if (*indices) free(*indices);
        *vertices = NULL;
        *indices = NULL;
        return;
    }
    
    // Generate vertices
    int v = 0;
    for (int i = 0; i <= rings; i++) {
        const float phi = M_PI * i / rings;
        for (int j = 0; j <= segments; j++) {
            const float theta = 2.0f * M_PI * j / segments;
            
            (*vertices)[v].x = sinf(phi) * cosf(theta);
            (*vertices)[v].y = cosf(phi);
            (*vertices)[v].z = sinf(phi) * sinf(theta);
            v++;
        }
    }
    
    // Generate indices
    int idx = 0;
    for (int i = 0; i < rings; i++) {
        for (int j = 0; j < segments; j++) {
            const int current = i * (segments + 1) + j;
            const int next = current + segments + 1;
            
            // First triangle
            (*indices)[idx++] = current;
            (*indices)[idx++] = next;
            (*indices)[idx++] = next + 1;
            
            // Second triangle
            (*indices)[idx++] = current;
            (*indices)[idx++] = next + 1;
            (*indices)[idx++] = current + 1;
        }
    }
}

void MKLGetCylinderVertices(MKLCylinder *cylinder, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount)
{
    MKL_NULL_CHECK_VOID(cylinder, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLGetCylinderVertices: cylinder is NULL");
    
    const int segments = cylinder->segments > 0 ? cylinder->segments : 32;
    
    // Vertices: 2 circles + side vertices
    *vertexCount = (segments + 1) * 2 + segments * 2;
    *indexCount = segments * 6 + segments * 6; // Top + bottom + sides
    
    *vertices = (vector_float3 *)malloc(sizeof(vector_float3) * *vertexCount);
    *indices = (unsigned short *)malloc(sizeof(unsigned short) * *indexCount);
    
    if (!*vertices || !*indices) {
        fprintf(stderr, "MKL Error: Failed to allocate memory for cylinder vertices\n");
        if (*vertices) free(*vertices);
        if (*indices) free(*indices);
        *vertices = NULL;
        *indices = NULL;
        return;
    }
    
    // Generate vertices
    int v = 0;
    
    // Top circle center
    (*vertices)[v++] = (vector_float3){0.0f, 0.5f, 0.0f};
    
    // Top circle
    for (int i = 0; i <= segments; i++) {
        const float angle = 2.0f * M_PI * i / segments;
        (*vertices)[v].x = cosf(angle);
        (*vertices)[v].y = 0.5f;
        (*vertices)[v].z = sinf(angle);
        v++;
    }
    
    // Bottom circle center
    (*vertices)[v++] = (vector_float3){0.0f, -0.5f, 0.0f};
    
    // Bottom circle
    for (int i = 0; i <= segments; i++) {
        const float angle = 2.0f * M_PI * i / segments;
        (*vertices)[v].x = cosf(angle);
        (*vertices)[v].y = -0.5f;
        (*vertices)[v].z = sinf(angle);
        v++;
    }
    
    // Generate indices
    int idx = 0;
    
    // Top face
    for (int i = 0; i < segments; i++) {
        (*indices)[idx++] = 0; // Center
        (*indices)[idx++] = i + 1;
        (*indices)[idx++] = i + 2;
    }
    
    // Bottom face
    const int bottomCenter = segments + 2;
    for (int i = 0; i < segments; i++) {
        (*indices)[idx++] = bottomCenter; // Center
        (*indices)[idx++] = bottomCenter + i + 2;
        (*indices)[idx++] = bottomCenter + i + 1;
    }
    
    // Side faces
    for (int i = 0; i < segments; i++) {
        const int top1 = i + 1;
        const int top2 = i + 2;
        const int bottom1 = bottomCenter + i + 1;
        const int bottom2 = bottomCenter + i + 2;
        
        // First triangle
        (*indices)[idx++] = top1;
        (*indices)[idx++] = bottom1;
        (*indices)[idx++] = top2;
        
        // Second triangle
        (*indices)[idx++] = top2;
        (*indices)[idx++] = bottom1;
        (*indices)[idx++] = bottom2;
    }
}

void MKLGetConeVertices(MKLCone *cone, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount)
{
    MKL_NULL_CHECK_VOID(cone, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLGetConeVertices: cone is NULL");
    
    const int segments = cone->segments > 0 ? cone->segments : 32;
    
    *vertexCount = segments + 2; // Base circle + apex
    *indexCount = segments * 6; // Base + sides
    
    *vertices = (vector_float3 *)malloc(sizeof(vector_float3) * *vertexCount);
    *indices = (unsigned short *)malloc(sizeof(unsigned short) * *indexCount);
    
    if (!*vertices || !*indices) {
        fprintf(stderr, "MKL Error: Failed to allocate memory for cone vertices\n");
        if (*vertices) free(*vertices);
        if (*indices) free(*indices);
        *vertices = NULL;
        *indices = NULL;
        return;
    }
    
    // Generate vertices
    int v = 0;
    
    // Apex
    (*vertices)[v++] = (vector_float3){0.0f, 0.5f, 0.0f};
    
    // Base circle
    for (int i = 0; i < segments; i++) {
        const float angle = 2.0f * M_PI * i / segments;
        (*vertices)[v].x = cosf(angle);
        (*vertices)[v].y = -0.5f;
        (*vertices)[v].z = sinf(angle);
        v++;
    }
    
    // Base center
    (*vertices)[v++] = (vector_float3){0.0f, -0.5f, 0.0f};
    
    // Generate indices
    int idx = 0;
    
    // Base face
    for (int i = 0; i < segments; i++) {
        (*indices)[idx++] = segments + 1; // Base center
        (*indices)[idx++] = i + 1;
        (*indices)[idx++] = (i + 1) % segments + 1;
    }
    
    // Side faces
    for (int i = 0; i < segments; i++) {
        (*indices)[idx++] = 0; // Apex
        (*indices)[idx++] = (i + 1) % segments + 1;
        (*indices)[idx++] = i + 1;
    }
}

void MKLGetTorusVertices(MKLTorus *torus, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount)
{
    MKL_NULL_CHECK_VOID(torus, NULL, MKL_ERROR_NULL_POINTER, 
                        "MKLGetTorusVertices: torus is NULL");
    
    const int majorSegments = torus->majorSegments > 0 ? torus->majorSegments : 32;
    const int minorSegments = torus->minorSegments > 0 ? torus->minorSegments : 16;
    
    *vertexCount = (majorSegments + 1) * (minorSegments + 1);
    *indexCount = majorSegments * minorSegments * 6;
    
    *vertices = (vector_float3 *)malloc(sizeof(vector_float3) * *vertexCount);
    *indices = (unsigned short *)malloc(sizeof(unsigned short) * *indexCount);
    
    if (!*vertices || !*indices) {
        fprintf(stderr, "MKL Error: Failed to allocate memory for torus vertices\n");
        if (*vertices) free(*vertices);
        if (*indices) free(*indices);
        *vertices = NULL;
        *indices = NULL;
        return;
    }
    
    // Generate vertices
    int v = 0;
    for (int i = 0; i <= majorSegments; i++) {
        const float u = 2.0f * M_PI * i / majorSegments;
        for (int j = 0; j <= minorSegments; j++) {
            const float v_angle = 2.0f * M_PI * j / minorSegments;
            
            const float x = (1.0f + 0.3f * cosf(v_angle)) * cosf(u);
            const float y = 0.3f * sinf(v_angle);
            const float z = (1.0f + 0.3f * cosf(v_angle)) * sinf(u);
            
            (*vertices)[v].x = x;
            (*vertices)[v].y = y;
            (*vertices)[v].z = z;
            v++;
        }
    }
    
    // Generate indices
    int idx = 0;
    for (int i = 0; i < majorSegments; i++) {
        for (int j = 0; j < minorSegments; j++) {
            const int current = i * (minorSegments + 1) + j;
            const int next = current + minorSegments + 1;
            
            // First triangle
            (*indices)[idx++] = current;
            (*indices)[idx++] = next;
            (*indices)[idx++] = next + 1;
            
            // Second triangle
            (*indices)[idx++] = current;
            (*indices)[idx++] = next + 1;
            (*indices)[idx++] = current + 1;
        }
    }
}


#pragma mark - Memory Management

void MKLCleanupShapeCache(void)
{
    // Free sphere cache
    if (_sphereCache.vertices) {
        free(_sphereCache.vertices);
        _sphereCache.vertices = NULL;
    }
    if (_sphereCache.indices) {
        free(_sphereCache.indices);
        _sphereCache.indices = NULL;
    }
    _sphereCache.initialized = false;
    
    // Free cylinder cache
    if (_cylinderCache.vertices) {
        free(_cylinderCache.vertices);
        _cylinderCache.vertices = NULL;
    }
    if (_cylinderCache.indices) {
        free(_cylinderCache.indices);
        _cylinderCache.indices = NULL;
    }
    _cylinderCache.initialized = false;
    
    // Free cone cache
    if (_coneCache.vertices) {
        free(_coneCache.vertices);
        _coneCache.vertices = NULL;
    }
    if (_coneCache.indices) {
        free(_coneCache.indices);
        _coneCache.indices = NULL;
    }
    _coneCache.initialized = false;
    
    // Free torus cache
    if (_torusCache.vertices) {
        free(_torusCache.vertices);
        _torusCache.vertices = NULL;
    }
    if (_torusCache.indices) {
        free(_torusCache.indices);
        _torusCache.indices = NULL;
    }
    _torusCache.initialized = false;
}

#pragma mark - Instanced Rendering

void MKLDrawCubesInstanced(MKLRenderer *renderer, MKLCube *cubes, MKLColor *colors, int count)
{
    if (count <= 0 || !renderer->_instancedPipelineState) {
        // Fall back to individual draw calls if instanced pipeline not available
        for (int i = 0; i < count; i++) {
            MKLDrawCube(renderer, cubes[i], colors[i]);
        }
        return;
    }
    
    // Get static cube data
    MKLVertex *cubeVertices = [MklDefs cubeVertices];
    ushort *cubeIndices = [MklDefs cubeIndices];
    
    // Get vertex and index buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * 8;
    const NSUInteger indexSize = sizeof(ushort) * 36;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) return;
    
    // Copy cube data once
    memcpy(vertexBuffer.contents, cubeVertices, vertexSize);
    memcpy(indexBuffer.contents, cubeIndices, indexSize);
    
    // Create instance data buffer (array of InstanceData structs)
    typedef struct {
        matrix_float4x4 modelMatrix;
        vector_float4 color;
    } InstanceData;
    
    const NSUInteger instanceDataSize = sizeof(InstanceData) * count;
    id<MTLBuffer> instanceBuffer = [renderer->_bufferPool getReuseableBufferWithLength:instanceDataSize];
    
    if (!instanceBuffer) return;
    
    // Fill instance data
    InstanceData *instanceData = (InstanceData *)instanceBuffer.contents;
    for (int i = 0; i < count; i++) {
        // Calculate model matrix
        const matrix_float4x4 scaleM = MScale((vector_float3){cubes[i].width, cubes[i].height, cubes[i].depth});
        const matrix_float4x4 translateM = MTranslate(cubes[i].position);
        const matrix_float4x4 rotationM = MRotate(cubes[i].rotation);
        matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
        modelM = matrix_multiply(modelM, scaleM);
        
        instanceData[i].modelMatrix = modelM;
        instanceData[i].color = colors[i];
    }
    
    // Switch to instanced pipeline
    [renderer->_renderEncoder setRenderPipelineState:renderer->_instancedPipelineState];
    
    // Set buffers
    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder setVertexBuffer:instanceBuffer offset:0 atIndex:2];
    
    // Draw all instances in one call
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                         indexCount:36
                                          indexType:MTLIndexTypeUInt16
                                        indexBuffer:indexBuffer
                                  indexBufferOffset:0
                                      instanceCount:count];
    
    // Restore normal pipeline for subsequent draws
    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
}

void MKLDrawSpheresInstanced(MKLRenderer *renderer, MKLSphere *spheres, MKLColor *colors, int count)
{
    if (count <= 0 || !renderer->_instancedPipelineState) {
        // Fall back to individual draw calls if instanced pipeline not available
        for (int i = 0; i < count; i++) {
            MKLDrawSphere(renderer, spheres[i], colors[i]);
        }
        return;
    }
    
    const int segments = spheres[0].segments > 0 ? spheres[0].segments : 32;
    
    // Ensure cache is initialized
    if (!_sphereCache.initialized || _sphereCache.segments != segments) {
        if (_sphereCache.vertices) free(_sphereCache.vertices);
        if (_sphereCache.indices) free(_sphereCache.indices);
        
        MKLSphere templateSphere = {.position = {0, 0, 0}, .rotation = {0, 0, 0}, .radius = 1.0f, .segments = segments};
        MKLGetSphereVertices(&templateSphere, &_sphereCache.vertices, &_sphereCache.vertexCount, 
                            &_sphereCache.indices, &_sphereCache.indexCount);
        _sphereCache.segments = segments;
        _sphereCache.initialized = true;
    }
    
    if (!_sphereCache.vertices || !_sphereCache.indices) return;
    
    // Get buffers
    const NSUInteger vertexSize = sizeof(MKLVertex) * _sphereCache.vertexCount;
    const NSUInteger indexSize = sizeof(ushort) * _sphereCache.indexCount;
    
    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:vertexSize];
    id<MTLBuffer> indexBuffer = [renderer->_bufferPool getReuseableBufferWithLength:indexSize];
    
    if (!vertexBuffer || !indexBuffer) return;
    
    // Convert vertices
    MKLVertex *mklVertices = (MKLVertex *)vertexBuffer.contents;
    for (int i = 0; i < _sphereCache.vertexCount; i++) {
        mklVertices[i].position = (vector_float4){_sphereCache.vertices[i].x, _sphereCache.vertices[i].y, _sphereCache.vertices[i].z, 1.0f};
    }
    memcpy(indexBuffer.contents, _sphereCache.indices, indexSize);
    
    // Create instance data buffer
    typedef struct {
        matrix_float4x4 modelMatrix;
        vector_float4 color;
    } InstanceData;
    
    const NSUInteger instanceDataSize = sizeof(InstanceData) * count;
    id<MTLBuffer> instanceBuffer = [renderer->_bufferPool getReuseableBufferWithLength:instanceDataSize];
    
    if (!instanceBuffer) return;
    
    // Fill instance data
    InstanceData *instanceData = (InstanceData *)instanceBuffer.contents;
    for (int i = 0; i < count; i++) {
        const matrix_float4x4 scaleM = MScale((vector_float3){spheres[i].radius, spheres[i].radius, spheres[i].radius});
        const matrix_float4x4 translateM = MTranslate(spheres[i].position);
        const matrix_float4x4 rotationM = MRotate(spheres[i].rotation);
        matrix_float4x4 modelM = matrix_multiply(translateM, rotationM);
        modelM = matrix_multiply(modelM, scaleM);
        
        instanceData[i].modelMatrix = modelM;
        instanceData[i].color = colors[i];
    }
    
    // Switch to instanced pipeline
    [renderer->_renderEncoder setRenderPipelineState:renderer->_instancedPipelineState];
    
    // Set buffers
    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [renderer->_renderEncoder setVertexBuffer:instanceBuffer offset:0 atIndex:2];
    
    // Draw all instances in one call
    [renderer->_renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                         indexCount:_sphereCache.indexCount
                                          indexType:MTLIndexTypeUInt16
                                        indexBuffer:indexBuffer
                                  indexBufferOffset:0
                                      instanceCount:count];
    
    // Restore normal pipeline
    [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
}
