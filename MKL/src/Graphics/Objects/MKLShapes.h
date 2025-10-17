#ifndef _MKL_MODELS_H_
#define _MKL_MODELS_H_

#include "../../Core/MKLCore.h"
#include "../MKLColors.h"
#include "../MKLRenderer.h"

#include <objc/NSObject.h>
#include <simd/vector.h>
#include <simd/vector_types.h>

typedef struct MKLLine
{
    vector_float2 p1;
    vector_float2 p2;
} MKLLine;

typedef struct MKLTriangle
{
    vector_float2 p1;
    vector_float2 p2;
    vector_float2 p3;
} MKLTriangle;

typedef struct MKLRect
{
    vector_float2 position;
    float width, height;
} MKLRect;

typedef struct MKLPlane
{
    vector_float3 position;
    vector_float2 dimensions;
    simd_uint2 segments;
    vector_float3 rotation;
    vector_float3 *vertices;
    int vertexCount;
} MKLPlane;

typedef struct MKLCube
{
    vector_float3 position;
    vector_float3 rotation;
    float width, height, depth;
} MKLCube;

typedef struct MKLSphere
{
    vector_float3 position;
    vector_float3 rotation;
    float radius;
    int segments; // Number of segments for sphere generation
} MKLSphere;

typedef struct MKLCylinder
{
    vector_float3 position;
    vector_float3 rotation;
    float radius;
    float height;
    int segments; // Number of segments around the cylinder
} MKLCylinder;

typedef struct MKLCone
{
    vector_float3 position;
    vector_float3 rotation;
    float radius;
    float height;
    int segments; // Number of segments around the cone
} MKLCone;

typedef struct MKLTorus
{
    vector_float3 position;
    vector_float3 rotation;
    float majorRadius; // Distance from center to tube center
    float minorRadius; // Tube radius
    int majorSegments; // Segments around the major radius
    int minorSegments; // Segments around the minor radius
} MKLTorus;

// 2D Shapes
typedef struct MKLCircle
{
    vector_float2 position;
    float radius;
    int segments; // Number of segments for circle generation
} MKLCircle;

typedef struct MKLPolygon
{
    vector_float2 position;
    float radius;
    int sides; // Number of sides (3 = triangle, 4 = square, etc.)
    float rotation; // Rotation in radians
} MKLPolygon;

// 3D Shape Drawing Functions
MKLAPI void MKLDrawCube(MKLRenderer *renderer, MKLCube cube, MKLColor color);
MKLAPI void MKLDrawSphere(MKLRenderer *renderer, MKLSphere sphere, MKLColor color);
MKLAPI void MKLDrawCylinder(MKLRenderer *renderer, MKLCylinder cylinder, MKLColor color);
MKLAPI void MKLDrawCone(MKLRenderer *renderer, MKLCone cone, MKLColor color);
MKLAPI void MKLDrawTorus(MKLRenderer *renderer, MKLTorus torus, MKLColor color);
MKLAPI void MKLDrawPlane(MKLRenderer *renderer, MKLPlane plane, MKLColor color);

// Instanced Rendering (for drawing multiple identical shapes efficiently)
MKLAPI void MKLDrawCubesInstanced(MKLRenderer *renderer, MKLCube *cubes, MKLColor *colors, int count);
MKLAPI void MKLDrawSpheresInstanced(MKLRenderer *renderer, MKLSphere *spheres, MKLColor *colors, int count);

// 2D Shape Drawing Functions
MKLAPI void MKLDrawCircle(MKLRenderer *renderer, MKLCircle circle, MKLColor color);
MKLAPI void MKLDrawPolygon(MKLRenderer *renderer, MKLPolygon polygon, MKLColor color);
MKLAPI void MKLDrawRectangle(MKLRenderer *renderer, MKLRect rect, MKLColor color);
MKLAPI void MKLDrawTriangle(MKLRenderer *renderer, MKLTriangle triangle, MKLColor color);
MKLAPI void MKLDrawLine(MKLRenderer *renderer, MKLLine line, MKLColor color);

// Utility Functions
MKLAPI void MKLGetPlaneVertices(MKLPlane *plane);
MKLAPI void MKLGetSphereVertices(MKLSphere *sphere, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount);
MKLAPI void MKLGetCylinderVertices(MKLCylinder *cylinder, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount);
MKLAPI void MKLGetConeVertices(MKLCone *cone, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount);
MKLAPI void MKLGetTorusVertices(MKLTorus *torus, vector_float3 **vertices, int *vertexCount, unsigned short **indices, int *indexCount);

// Memory Management
MKLAPI void MKLCleanupShapeCache(void);

#endif // _MKL_MODELS_H_
