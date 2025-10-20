#ifndef MKL_COMMAND_BUFFER_H
#define MKL_COMMAND_BUFFER_H

#include "../Core/MKLConfig.h"
#include "../Core/MKLCore.h"
#include "MKLColors.h"
#include "MKLRenderer.h"
#include "Objects/MKLShapes.h"

#include <simd/matrix.h>

// Use centralized constant from MKLConfig.h
// MKL_MAX_DRAW_COMMANDS is defined in MKLConfig.h

// Draw command types
typedef enum {
    MKL_DRAW_CMD_CUBE,
    MKL_DRAW_CMD_PLANE,
    MKL_DRAW_CMD_SPHERE,
    MKL_DRAW_CMD_CYLINDER,
    MKL_DRAW_CMD_CONE,
    MKL_DRAW_CMD_MESH,
    MKL_DRAW_CMD_CUBES_INSTANCED,  // For existing instanced API
    MKL_DRAW_CMD_SPHERES_INSTANCED
} MKLDrawCommandType;

// Draw command structure
typedef struct {
    MKLDrawCommandType type;
    matrix_float4x4 modelMatrix;
    MKLColor color;
    int geometryCacheIndex;  // For cached geometry lookup
    bool useLighting;
    
    // Union for type-specific data
    union {
        struct {
            float width, height, depth;
        } cube;
        
        struct {
            simd_uint2 segments;
            int indexCount;
        } plane;
        
        struct {
            float radius;
            int segments;
        } sphere;
        
        struct {
            void *meshPtr;  // MKLMesh pointer
        } mesh;
        
        struct {
            int count;
            void *data;  // Array of objects
            void *colors;  // Array of colors
        } instanced;
    } data;
} MKLDrawCommand;

// Command buffer for batching
typedef struct {
    MKLDrawCommand commands[MKL_MAX_DRAW_COMMANDS];
    int count;
    bool batchingEnabled;
} MKLCommandBuffer;

// API Functions
MKLAPI void MKLInitCommandBuffer(MKLCommandBuffer *cmdBuffer);
MKLAPI void MKLClearCommandBuffer(MKLCommandBuffer *cmdBuffer);
MKLAPI void MKLPushDrawCommand(MKLCommandBuffer *cmdBuffer, MKLDrawCommand cmd);
MKLAPI void MKLExecuteCommandBuffer(MKLRenderer *renderer, MKLCommandBuffer *cmdBuffer);
MKLAPI void MKLEnableBatching(MKLRenderer *renderer, bool enable);

#endif // MKL_COMMAND_BUFFER_H

