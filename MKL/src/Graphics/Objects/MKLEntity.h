#ifndef _MKL_ENTITY_H_
#define _MKL_ENTITY_H_

#include <simd/simd.h>
#include <stdbool.h>

#include "../MKLTypes.h"
#include "../../Core/MKLCore.h"

// Camera modes (inspired by raylib)
typedef enum MKLCameraMode {
    MKL_CAMERA_CUSTOM = 0,          // Custom camera, no automatic updates
    MKL_CAMERA_FREE,                // Free camera, full 6-DOF movement
    MKL_CAMERA_ORBITAL,             // Orbital camera around target, mouse rotates
    MKL_CAMERA_FIRST_PERSON,        // FPS-style camera (locked to ground plane)
    MKL_CAMERA_THIRD_PERSON         // Third person camera following target
} MKLCameraMode;

// Camera projection types
typedef enum MKLCameraProjection {
    MKL_CAMERA_PERSPECTIVE = 0,
    MKL_CAMERA_ORTHOGRAPHIC
} MKLCameraProjection;

typedef struct MKLCamera {
    // Position and orientation
    vector_float3 position;
    vector_float3 target;           // Look-at target
    vector_float3 up;
    vector_float3 forward;
    vector_float3 right;

    // Projection parameters
    float fov, aspect, near, far;
    MKLCameraProjection projection;

    // Euler angles (for first-person mode)
    float yaw, pitch, roll;

    // Camera mode
    MKLCameraMode mode;

    // Camera speeds
    float moveSpeed;                // Movement speed
    float rotationSpeed;            // Rotation speed (degrees/second)
    float mouseSensitivity;         // Mouse sensitivity

    // Internal
    simd_quatf rotation;
} MKLCamera;

// Legacy controls enum (for backwards compatibility)
typedef enum MKLCameraControls
{
    MKL_CAMERA_ORBIT = 0x01,
} MKLCameraControls;

// ========== Camera Mode Functions ==========

/**
 * @brief Set camera mode
 * @param camera The camera
 * @param mode Camera mode
 */
MKLAPI void MKLSetCameraMode(MKLCamera *camera, MKLCameraMode mode);

/**
 * @brief Get current camera mode
 * @param camera The camera
 * @return Current camera mode
 */
MKLAPI MKLCameraMode MKLGetCameraMode(const MKLCamera *camera);

// ========== Camera Movement Functions ==========

/**
 * @brief Move camera forward/backward
 * @param camera The camera
 * @param distance Distance to move (negative = backward)
 * @param moveInWorldPlane Lock movement to XZ plane (for FPS mode)
 */
MKLAPI void MKLCameraMoveForward(MKLCamera *camera, float distance, bool moveInWorldPlane);

/**
 * @brief Move camera up/down
 * @param camera The camera
 * @param distance Distance to move
 */
MKLAPI void MKLCameraMoveUp(MKLCamera *camera, float distance);

/**
 * @brief Move camera right/left
 * @param camera The camera
 * @param distance Distance to move (negative = left)
 * @param moveInWorldPlane Lock movement to XZ plane
 */
MKLAPI void MKLCameraMoveRight(MKLCamera *camera, float distance, bool moveInWorldPlane);

/**
 * @brief Move camera toward/away from target (zoom)
 * @param camera The camera
 * @param delta Distance delta (positive = closer, negative = farther)
 */
MKLAPI void MKLCameraMoveToTarget(MKLCamera *camera, float delta);

// ========== Camera Rotation Functions ==========

/**
 * @brief Rotate camera yaw (look left/right)
 * @param camera The camera
 * @param angle Angle in radians
 * @param rotateAroundTarget Rotate around target (orbital) or position (FPS)
 */
MKLAPI void MKLCameraYaw(MKLCamera *camera, float angle, bool rotateAroundTarget);

/**
 * @brief Rotate camera pitch (look up/down)
 * @param camera The camera
 * @param angle Angle in radians
 * @param lockView Prevent camera flipping
 * @param rotateAroundTarget Rotate around target or position
 * @param rotateUp Also rotate the up vector
 */
MKLAPI void MKLCameraPitch(MKLCamera *camera, float angle, bool lockView, bool rotateAroundTarget, bool rotateUp);

/**
 * @brief Rotate camera roll (tilt head)
 * @param camera The camera
 * @param angle Angle in radians
 */
MKLAPI void MKLCameraRoll(MKLCamera *camera, float angle);

// ========== Camera Update Functions ==========

/**
 * @brief Update camera based on its mode (handles input automatically)
 * @param camera The camera
 * @param controls Legacy controls flags (for backwards compatibility)
 */
MKLAPI void MKLUpdateCamera(MKLCamera *camera, MKLCameraControls controls);

/**
 * @brief Update camera with manual control (no automatic input)
 * @param camera The camera
 * @param movement Movement vector (forward, right, up)
 * @param rotation Rotation vector (yaw, pitch, roll) in degrees
 * @param zoom Zoom delta
 */
MKLAPI void MKLUpdateCameraPro(MKLCamera *camera, vector_float3 movement, vector_float3 rotation, float zoom);

// ========== Camera Utility Functions ==========

/**
 * @brief Get camera forward vector
 * @param camera The camera
 * @return Normalized forward vector
 */
MKLAPI vector_float3 MKLGetCameraForward(const MKLCamera *camera);

/**
 * @brief Get camera up vector
 * @param camera The camera
 * @return Normalized up vector
 */
MKLAPI vector_float3 MKLGetCameraUp(const MKLCamera *camera);

/**
 * @brief Get camera right vector
 * @param camera The camera
 * @return Normalized right vector
 */
MKLAPI vector_float3 MKLGetCameraRight(const MKLCamera *camera);

/**
 * @brief Set camera target
 * @param camera The camera
 * @param target New target position
 */
MKLAPI void MKLSetCameraTarget(MKLCamera *camera, vector_float3 target);

/**
 * @brief Set camera projection type
 * @param camera The camera
 * @param projection Projection type
 */
MKLAPI void MKLSetCameraProjection(MKLCamera *camera, MKLCameraProjection projection);

#endif // _MKL_ENTITY_H_
