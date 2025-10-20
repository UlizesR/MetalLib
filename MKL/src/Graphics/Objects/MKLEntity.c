//
// MKLEntity.c
// Camera system implementation (based on raylib's rcamera.h)
//

#include "MKLEntity.h"
#include "../../Core/MKLError.h"
#include "../../Input/Mouse.h"
#include "../../Input/Keyboard.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// Camera configuration
#define CAMERA_MOVE_SPEED                    5.0f
#define CAMERA_ROTATION_SPEED                90.0f  // Degrees per second
#define CAMERA_PAN_SPEED                     0.2f
#define CAMERA_MOUSE_MOVE_SENSITIVITY        0.003f
#define CAMERA_ORBITAL_SPEED                 0.5f   // Radians per second

// ========== Utility Functions ==========

vector_float3 MKLGetCameraForward(const MKLCamera *camera) {
    if (!camera) return (vector_float3){0, 0, -1};
    return simd_normalize(simd_make_float3(
        camera->target.x - camera->position.x,
        camera->target.y - camera->position.y,
        camera->target.z - camera->position.z
    ));
}

vector_float3 MKLGetCameraUp(const MKLCamera *camera) {
    if (!camera) return (vector_float3){0, 1, 0};
    return simd_normalize(camera->up);
}

vector_float3 MKLGetCameraRight(const MKLCamera *camera) {
    if (!camera) return (vector_float3){1, 0, 0};
    vector_float3 forward = MKLGetCameraForward(camera);
    vector_float3 up = MKLGetCameraUp(camera);
    return simd_normalize(simd_cross(forward, up));
}

// ========== Camera Mode Functions ==========

void MKLSetCameraMode(MKLCamera *camera, MKLCameraMode mode) {
    if (camera) {
        camera->mode = mode;
        // Reset roll when switching modes
        camera->up = (vector_float3){0.0f, 1.0f, 0.0f};
        camera->roll = 0.0f;
    }
}

MKLCameraMode MKLGetCameraMode(const MKLCamera *camera) {
    return camera ? camera->mode : MKL_CAMERA_CUSTOM;
}

void MKLSetCameraTarget(MKLCamera *camera, vector_float3 target) {
    if (camera) {
        camera->target = target;
    }
}

void MKLSetCameraProjection(MKLCamera *camera, MKLCameraProjection projection) {
    if (camera) {
        camera->projection = projection;
    }
}

// ========== Camera Movement Functions ==========

void MKLCameraMoveForward(MKLCamera *camera, float distance, bool moveInWorldPlane) {
    if (!camera) return;
    
    vector_float3 forward = MKLGetCameraForward(camera);
    
    if (moveInWorldPlane) {
        // Project onto XZ plane (lock Y)
        forward.y = 0;
        forward = simd_normalize(forward);
    }
    
    forward = simd_make_float3(forward.x * distance, forward.y * distance, forward.z * distance);
    
    camera->position = simd_make_float3(
        camera->position.x + forward.x,
        camera->position.y + forward.y,
        camera->position.z + forward.z
    );
    camera->target = simd_make_float3(
        camera->target.x + forward.x,
        camera->target.y + forward.y,
        camera->target.z + forward.z
    );
}

void MKLCameraMoveUp(MKLCamera *camera, float distance) {
    if (!camera) return;
    
    vector_float3 up = MKLGetCameraUp(camera);
    up = simd_make_float3(up.x * distance, up.y * distance, up.z * distance);
    
    camera->position = simd_make_float3(
        camera->position.x + up.x,
        camera->position.y + up.y,
        camera->position.z + up.z
    );
    camera->target = simd_make_float3(
        camera->target.x + up.x,
        camera->target.y + up.y,
        camera->target.z + up.z
    );
}

void MKLCameraMoveRight(MKLCamera *camera, float distance, bool moveInWorldPlane) {
    if (!camera) return;
    
    vector_float3 right = MKLGetCameraRight(camera);
    
    if (moveInWorldPlane) {
        // Project onto XZ plane
        right.y = 0;
        right = simd_normalize(right);
    }
    
    right = simd_make_float3(right.x * distance, right.y * distance, right.z * distance);
    
    camera->position = simd_make_float3(
        camera->position.x + right.x,
        camera->position.y + right.y,
        camera->position.z + right.z
    );
    camera->target = simd_make_float3(
        camera->target.x + right.x,
        camera->target.y + right.y,
        camera->target.z + right.z
    );
}

void MKLCameraMoveToTarget(MKLCamera *camera, float delta) {
    if (!camera) return;
    
    float distance = simd_distance(camera->position, camera->target);
    distance += delta;
    
    if (distance <= 0.001f) distance = 0.001f;
    
    vector_float3 forward = MKLGetCameraForward(camera);
    camera->position = simd_make_float3(
        camera->target.x - forward.x * distance,
        camera->target.y - forward.y * distance,
        camera->target.z - forward.z * distance
    );
}

// ========== Camera Rotation Functions ==========

void MKLCameraYaw(MKLCamera *camera, float angle, bool rotateAroundTarget) {
    if (!camera) return;
    
    vector_float3 targetPosition = simd_make_float3(
        camera->target.x - camera->position.x,
        camera->target.y - camera->position.y,
        camera->target.z - camera->position.z
    );
    
    // Rotate around up axis
    float c = cosf(angle);
    float s = sinf(angle);
    vector_float3 rotated = {
        targetPosition.x * c - targetPosition.z * s,
        targetPosition.y,
        targetPosition.x * s + targetPosition.z * c
    };
    
    if (rotateAroundTarget) {
        // Move position relative to target (orbital)
        camera->position = simd_make_float3(
            camera->target.x - rotated.x,
            camera->target.y - rotated.y,
            camera->target.z - rotated.z
        );
    } else {
        // Move target relative to position (FPS)
        camera->target = simd_make_float3(
            camera->position.x + rotated.x,
            camera->position.y + rotated.y,
            camera->position.z + rotated.z
        );
    }
}

void MKLCameraPitch(MKLCamera *camera, float angle, bool lockView, bool rotateAroundTarget, bool rotateUp) {
    if (!camera) return;
    
    vector_float3 up = MKLGetCameraUp(camera);
    vector_float3 targetPosition = simd_make_float3(
        camera->target.x - camera->position.x,
        camera->target.y - camera->position.y,
        camera->target.z - camera->position.z
    );
    
    if (lockView) {
        // Clamp angle to prevent camera flipping
        float maxAngleUp = simd_length(simd_make_float2(targetPosition.x, targetPosition.z));
        maxAngleUp = atan2f(maxAngleUp, targetPosition.y);
        float maxAngleDown = atan2f(maxAngleUp, -targetPosition.y);
        
        angle = fmaxf(-maxAngleDown, fminf(maxAngleUp, angle));
    }
    
    vector_float3 right = MKLGetCameraRight(camera);
    
    // Rotate around right axis
    float c = cosf(angle);
    float s = sinf(angle);
    
    // Rodriguez rotation formula
    float dot = simd_dot(targetPosition, right);
    vector_float3 rotated = {
        targetPosition.x * c + (right.y * targetPosition.z - right.z * targetPosition.y) * s + right.x * dot * (1 - c),
        targetPosition.y * c + (right.z * targetPosition.x - right.x * targetPosition.z) * s + right.y * dot * (1 - c),
        targetPosition.z * c + (right.x * targetPosition.y - right.y * targetPosition.x) * s + right.z * dot * (1 - c)
    };
    
    if (rotateAroundTarget) {
        camera->position = simd_make_float3(
            camera->target.x - rotated.x,
            camera->target.y - rotated.y,
            camera->target.z - rotated.z
        );
    } else {
        camera->target = simd_make_float3(
            camera->position.x + rotated.x,
            camera->position.y + rotated.y,
            camera->position.z + rotated.z
        );
    }
    
    if (rotateUp) {
        // Rotate up vector as well
        dot = simd_dot(up, right);
        camera->up = simd_make_float3(
            up.x * c + (right.y * up.z - right.z * up.y) * s + right.x * dot * (1 - c),
            up.y * c + (right.z * up.x - right.x * up.z) * s + right.y * dot * (1 - c),
            up.z * c + (right.x * up.y - right.y * up.x) * s + right.z * dot * (1 - c)
        );
    }
}

void MKLCameraRoll(MKLCamera *camera, float angle) {
    if (!camera) return;
    
    vector_float3 forward = MKLGetCameraForward(camera);
    
    // Rotate up vector around forward axis
    float c = cosf(angle);
    float s = sinf(angle);
    
    float dot = simd_dot(camera->up, forward);
    camera->up = simd_make_float3(
        camera->up.x * c + (forward.y * camera->up.z - forward.z * camera->up.y) * s + forward.x * dot * (1 - c),
        camera->up.y * c + (forward.z * camera->up.x - forward.x * camera->up.z) * s + forward.y * dot * (1 - c),
        camera->up.z * c + (forward.x * camera->up.y - forward.y * camera->up.x) * s + forward.z * dot * (1 - c)
    );
}

// ========== Camera Update Functions ==========

void MKLUpdateCamera(MKLCamera *camera, MKLCameraControls controls) {
    if (!camera) return;
    
    // Legacy mode handling
    if (controls == MKL_CAMERA_ORBIT) {
        camera->mode = MKL_CAMERA_ORBITAL;
    }
    
    // Handle different camera modes
    // Note: Input handling should be done by the application
    // This function just updates camera vectors based on yaw/pitch/target
    
    // Update forward, right, up vectors based on target and position
    camera->forward = MKLGetCameraForward(camera);
    camera->right = MKLGetCameraRight(camera);
    camera->up = simd_normalize(simd_cross(camera->right, camera->forward));
}

void MKLUpdateCameraPro(MKLCamera *camera, vector_float3 movement, vector_float3 rotation, float zoom) {
    if (!camera) return;
    
    bool lockView = true;
    bool rotateAroundTarget = false;
    bool rotateUp = false;
    bool moveInWorldPlane = (camera->mode == MKL_CAMERA_FIRST_PERSON || camera->mode == MKL_CAMERA_THIRD_PERSON);
    
    // Apply rotation (in degrees, convert to radians)
    MKLCameraPitch(camera, -rotation.y * M_PI / 180.0f, lockView, rotateAroundTarget, rotateUp);
    MKLCameraYaw(camera, -rotation.x * M_PI / 180.0f, rotateAroundTarget);
    MKLCameraRoll(camera, rotation.z * M_PI / 180.0f);
    
    // Apply movement
    MKLCameraMoveForward(camera, movement.x, moveInWorldPlane);
    MKLCameraMoveRight(camera, movement.y, moveInWorldPlane);
    MKLCameraMoveUp(camera, movement.z);
    
    // Apply zoom
    MKLCameraMoveToTarget(camera, zoom);
}

// ========== Legacy Camera Functions (Backwards Compatibility) ==========

void MKLSetCamera(MKLCamera *camera, vector_float3 position, vector_float3 up, float fov, float aspect, float near, float far)
{
    MKL_NULL_CHECK_VOID(camera, NULL, MKL_ERROR_NULL_POINTER, "MKLCamera is NULL!");
    camera->position = position;
    camera->target = simd_make_float3(
        position.x + camera->forward.x,
        position.y + camera->forward.y,
        position.z + camera->forward.z
    );
    camera->up = up;
    camera->forward = (vector_float3){0.0f, 0.0f, -1.0f};
    camera->right = (vector_float3){1.0f, 0.0f, 0.0f};
    camera->fov = fov;
    camera->aspect = aspect;
    camera->near = near;
    camera->far = far;
    camera->mode = MKL_CAMERA_FREE;
    camera->projection = MKL_CAMERA_PERSPECTIVE;
    camera->moveSpeed = CAMERA_MOVE_SPEED;
    camera->rotationSpeed = CAMERA_ROTATION_SPEED;
    camera->mouseSensitivity = CAMERA_MOUSE_MOVE_SENSITIVITY;
}
