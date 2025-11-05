#import "MKLCommandBuffer.h"
#import "Objects/MKLShapes.h"
#import "Objects/MKLMesh.h"
#import "../Core/MKLError.h"
#import <Metal/Metal.h>
#include <stdlib.h>
#include <string.h>

void MKLInitCommandBuffer(MKLCommandBuffer *cmdBuffer) {
    MKL_NULL_CHECK_VOID(cmdBuffer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLInitCommandBuffer: cmdBuffer is NULL");

    cmdBuffer->count = 0;
    cmdBuffer->batchingEnabled = false;
    memset(cmdBuffer->commands, 0, sizeof(cmdBuffer->commands));
}

void MKLClearCommandBuffer(MKLCommandBuffer *cmdBuffer) {
    MKL_NULL_CHECK_VOID(cmdBuffer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLClearCommandBuffer: cmdBuffer is NULL");

    cmdBuffer->count = 0;
}

void MKLPushDrawCommand(MKLCommandBuffer *cmdBuffer, MKLDrawCommand cmd) {
    MKL_NULL_CHECK_VOID(cmdBuffer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLPushDrawCommand: cmdBuffer is NULL");

    if (cmdBuffer->count >= MKL_MAX_DRAW_COMMANDS) {
        fprintf(stderr, "MKL Warning: Command buffer full (%d commands), increasing limit recommended\n",
                MKL_MAX_DRAW_COMMANDS);
        return;
    }

    cmdBuffer->commands[cmdBuffer->count++] = cmd;
}

// Comparison function for sorting by pipeline state
static int compareDrawCommands(const void *a, const void *b) {
    const MKLDrawCommand *cmdA = (const MKLDrawCommand *)a;
    const MKLDrawCommand *cmdB = (const MKLDrawCommand *)b;

    // First, sort by lighting (groups lit vs unlit)
    if (cmdA->useLighting != cmdB->useLighting) {
        return cmdA->useLighting ? 1 : -1;
    }

    // Then by command type (groups same geometry types)
    if (cmdA->type != cmdB->type) {
        return (int)cmdA->type - (int)cmdB->type;
    }

    // For planes, sort by segment configuration (groups same cached geometry)
    if (cmdA->type == MKL_DRAW_CMD_PLANE && cmdB->type == MKL_DRAW_CMD_PLANE) {
        if (cmdA->geometryCacheIndex != cmdB->geometryCacheIndex) {
            return cmdA->geometryCacheIndex - cmdB->geometryCacheIndex;
        }
    }

    return 0;
}

void MKLExecuteCommandBuffer(MKLRenderer *renderer, MKLCommandBuffer *cmdBuffer) {
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLExecuteCommandBuffer: renderer is NULL");
    MKL_NULL_CHECK_VOID(cmdBuffer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLExecuteCommandBuffer: cmdBuffer is NULL");

    if (cmdBuffer->count == 0) {
        return; // Nothing to execute
    }

    // OPTIMIZATION: Sort commands by pipeline state to minimize state changes
    qsort(cmdBuffer->commands, cmdBuffer->count, sizeof(MKLDrawCommand), compareDrawCommands);

    // Track current pipeline state to avoid redundant switches
    bool currentlyLit = false;
    // Future: Could optimize further by tracking geometry cache and type
    // MKLDrawCommandType currentType = (MKLDrawCommandType)-1;
    // int currentGeometryCache = -1;

    // Execute commands in batches
    for (int i = 0; i < cmdBuffer->count; i++) {
        MKLDrawCommand *cmd = &cmdBuffer->commands[i];

        // Switch pipeline if needed
        if (cmd->useLighting != currentlyLit) {
            if (cmd->useLighting && renderer->_pipelineStateLit) {
                [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineStateLit];
            } else {
                [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
            }
            currentlyLit = cmd->useLighting;
        }

        // Execute command based on type
        switch (cmd->type) {
            case MKL_DRAW_CMD_CUBE: {
                MKLCube cube = {
                    .position = {cmd->modelMatrix.columns[3].x,
                                cmd->modelMatrix.columns[3].y,
                                cmd->modelMatrix.columns[3].z},
                    .rotation = {0, 0, 0},  // Rotation baked into matrix
                    .width = cmd->data.cube.width,
                    .height = cmd->data.cube.height,
                    .depth = cmd->data.cube.depth
                };
                MKLDrawCube(renderer, cube, cmd->color);
                break;
            }

            case MKL_DRAW_CMD_PLANE: {
                MKLPlane plane = {
                    .position = {cmd->modelMatrix.columns[3].x,
                                cmd->modelMatrix.columns[3].y,
                                cmd->modelMatrix.columns[3].z},
                    .dimensions = {1.0f, 1.0f},  // Baked into matrix
                    .segments = cmd->data.plane.segments,
                    .rotation = {0, 0, 0}
                };
                MKLDrawPlane(renderer, plane, cmd->color);
                break;
            }

            case MKL_DRAW_CMD_SPHERE: {
                MKLSphere sphere = {
                    .position = {cmd->modelMatrix.columns[3].x,
                                cmd->modelMatrix.columns[3].y,
                                cmd->modelMatrix.columns[3].z},
                    .rotation = {0, 0, 0},
                    .radius = cmd->data.sphere.radius,
                    .segments = cmd->data.sphere.segments
                };
                MKLDrawSphere(renderer, sphere, cmd->color);
                break;
            }

            case MKL_DRAW_CMD_CUBES_INSTANCED: {
                // Already batched, execute directly
                MKLDrawCubesInstanced(renderer,
                                     (MKLCube *)cmd->data.instanced.data,
                                     (MKLColor *)cmd->data.instanced.colors,
                                     cmd->data.instanced.count);
                break;
            }

            case MKL_DRAW_CMD_SPHERES_INSTANCED: {
                // Already batched, execute directly
                MKLDrawSpheresInstanced(renderer,
                                       (MKLSphere *)cmd->data.instanced.data,
                                       (MKLColor *)cmd->data.instanced.colors,
                                       cmd->data.instanced.count);
                break;
            }

            default:
                fprintf(stderr, "MKL Warning: Unknown draw command type: %d\n", cmd->type);
                break;
        }

        // Future: Track current state for additional optimizations
        // currentType = cmd->type;
        // if (cmd->type == MKL_DRAW_CMD_PLANE) {
        //     currentGeometryCache = cmd->geometryCacheIndex;
        // }
    }

    // Restore default pipeline if needed
    if (currentlyLit) {
        [renderer->_renderEncoder setRenderPipelineState:renderer->_pipelineState];
    }
}

void MKLEnableBatching(MKLRenderer *renderer, bool enable) {
    MKL_NULL_CHECK_VOID(renderer, NULL, MKL_ERROR_NULL_POINTER,
                        "MKLEnableBatching: renderer is NULL");

    renderer->_batchingEnabled = enable;

    if (renderer->_drawCommandBuffer) {
        MKLCommandBuffer *cmdBuffer = (MKLCommandBuffer *)renderer->_drawCommandBuffer;
        cmdBuffer->batchingEnabled = enable;
        if (!enable) {
            // If disabling, execute and clear any pending commands
            MKLExecuteCommandBuffer(renderer, cmdBuffer);
            MKLClearCommandBuffer(cmdBuffer);
        }
    }
}

