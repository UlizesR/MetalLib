//
// MKLAnimation.h
// MetalLib - Skeletal Animation System
//
// Provides skeletal animation support for animated 3D models
//

#ifndef MKLAnimation_h
#define MKLAnimation_h

#include "../Core/MKLCore.h"
#include <simd/simd.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ========== Animation Types ==========

/**
 * @brief Animation playback mode
 */
typedef enum MKLAnimationMode {
    MKL_ANIM_MODE_ONCE = 0,         ///< Play once and stop
    MKL_ANIM_MODE_LOOP,             ///< Loop continuously
    MKL_ANIM_MODE_PINGPONG          ///< Play forward then backward, repeat
} MKLAnimationMode;

/**
 * @brief Transform keyframe for a single bone
 */
typedef struct MKLBoneKeyframe {
    float time;                     ///< Time in seconds
    vector_float3 translation;      ///< Translation
    simd_quatf rotation;            ///< Rotation quaternion
    vector_float3 scale;            ///< Scale
} MKLBoneKeyframe;

/**
 * @brief Animation track for a single bone
 */
typedef struct MKLBoneTrack {
    int boneIndex;                  ///< Index of bone this track controls
    int keyframeCount;              ///< Number of keyframes
    MKLBoneKeyframe *keyframes;     ///< Array of keyframes
} MKLBoneTrack;

/**
 * @brief Bone in skeleton hierarchy
 */
typedef struct MKLBone {
    char name[64];                  ///< Bone name
    int parentIndex;                ///< Parent bone index (-1 for root)
    matrix_float4x4 inverseBindPose; ///< Inverse bind pose matrix
    matrix_float4x4 localTransform; ///< Local transform
    matrix_float4x4 globalTransform; ///< Global/world transform
} MKLBone;

/**
 * @brief Skeleton structure containing bone hierarchy
 */
typedef struct MKLSkeleton {
    int boneCount;                  ///< Number of bones
    MKLBone *bones;                 ///< Array of bones
    matrix_float4x4 *jointMatrices; ///< Final joint matrices for skinning
    bool valid;                     ///< Is skeleton valid
} MKLSkeleton;

/**
 * @brief Animation clip
 */
typedef struct MKLAnimation {
    char name[64];                  ///< Animation name
    float duration;                 ///< Total duration in seconds
    int trackCount;                 ///< Number of bone tracks
    MKLBoneTrack *tracks;           ///< Array of bone tracks
    bool valid;                     ///< Is animation valid
} MKLAnimation;

/**
 * @brief Animation state/player
 */
typedef struct MKLAnimationState {
    MKLAnimation *animation;        ///< Current animation
    MKLSkeleton *skeleton;          ///< Target skeleton
    float currentTime;              ///< Current playback time
    float playbackSpeed;            ///< Playback speed multiplier
    MKLAnimationMode mode;          ///< Playback mode
    bool playing;                   ///< Is currently playing
    bool finished;                  ///< Has animation finished (for ONCE mode)
} MKLAnimationState;

// Forward declarations
typedef struct MKLRenderer MKLRenderer;
typedef struct MKLMesh MKLMesh;

// ========== Skeleton Functions ==========

/**
 * @brief Create an empty skeleton
 * @param boneCount Number of bones
 * @return Created skeleton
 */
MKLAPI MKLSkeleton MKLCreateSkeleton(int boneCount);

/**
 * @brief Load skeleton from model file
 * @param renderer The renderer context
 * @param fileName Path to model file (USDZ, FBX, etc.)
 * @return Loaded skeleton or invalid skeleton on failure
 */
MKLAPI MKLSkeleton MKLLoadSkeleton(MKLRenderer *renderer, const char *fileName);

/**
 * @brief Release skeleton resources
 * @param skeleton Skeleton to release
 */
MKLAPI void MKLReleaseSkeleton(MKLSkeleton *skeleton);

/**
 * @brief Check if skeleton is valid
 * @param skeleton Skeleton to check
 * @return true if valid
 */
MKLAPI bool MKLIsSkeletonValid(const MKLSkeleton *skeleton);

/**
 * @brief Update skeleton bone transforms
 * @param skeleton Skeleton to update
 */
MKLAPI void MKLUpdateSkeleton(MKLSkeleton *skeleton);

// ========== Animation Loading Functions ==========

/**
 * @brief Load animation from file
 * @param fileName Path to animation file
 * @param animationIndex Index of animation in file (if multiple)
 * @return Loaded animation or invalid animation on failure
 */
MKLAPI MKLAnimation MKLLoadAnimation(const char *fileName, int animationIndex);

/**
 * @brief Load all animations from a model file
 * @param fileName Path to model file
 * @param animationCount Output: number of animations loaded
 * @return Array of loaded animations
 */
MKLAPI MKLAnimation* MKLLoadAnimations(const char *fileName, int *animationCount);

/**
 * @brief Release animation resources
 * @param animation Animation to release
 */
MKLAPI void MKLReleaseAnimation(MKLAnimation *animation);

/**
 * @brief Check if animation is valid
 * @param animation Animation to check
 * @return true if valid
 */
MKLAPI bool MKLIsAnimationValid(const MKLAnimation *animation);

// ========== Animation State Functions ==========

/**
 * @brief Create an animation state/player
 * @param animation Animation to play
 * @param skeleton Target skeleton
 * @return Animation state
 */
MKLAPI MKLAnimationState MKLCreateAnimationState(MKLAnimation *animation, MKLSkeleton *skeleton);

/**
 * @brief Update animation state (call each frame)
 * @param state Animation state to update
 * @param deltaTime Time elapsed since last update (in seconds)
 */
MKLAPI void MKLUpdateAnimation(MKLAnimationState *state, float deltaTime);

/**
 * @brief Set animation playback mode
 * @param state Animation state
 * @param mode Playback mode
 */
MKLAPI void MKLSetAnimationMode(MKLAnimationState *state, MKLAnimationMode mode);

/**
 * @brief Play animation
 * @param state Animation state
 */
MKLAPI void MKLPlayAnimation(MKLAnimationState *state);

/**
 * @brief Pause animation
 * @param state Animation state
 */
MKLAPI void MKLPauseAnimation(MKLAnimationState *state);

/**
 * @brief Stop animation and reset to beginning
 * @param state Animation state
 */
MKLAPI void MKLStopAnimation(MKLAnimationState *state);

/**
 * @brief Seek to specific time in animation
 * @param state Animation state
 * @param time Time in seconds
 */
MKLAPI void MKLSeekAnimation(MKLAnimationState *state, float time);

/**
 * @brief Set animation playback speed
 * @param state Animation state
 * @param speed Speed multiplier (1.0 = normal speed)
 */
MKLAPI void MKLSetAnimationSpeed(MKLAnimationState *state, float speed);

/**
 * @brief Check if animation is playing
 * @param state Animation state
 * @return true if playing
 */
MKLAPI bool MKLIsAnimationPlaying(const MKLAnimationState *state);

/**
 * @brief Check if animation has finished (for ONCE mode)
 * @param state Animation state
 * @return true if finished
 */
MKLAPI bool MKLIsAnimationFinished(const MKLAnimationState *state);

// ========== Animation Blending Functions ==========

/**
 * @brief Blend between two animations
 * @param state1 First animation state
 * @param state2 Second animation state
 * @param blendFactor Blend factor (0.0 = anim1, 1.0 = anim2)
 * @param outSkeleton Output skeleton with blended transforms
 */
MKLAPI void MKLBlendAnimations(const MKLAnimationState *state1,
                                 const MKLAnimationState *state2,
                                 float blendFactor,
                                 MKLSkeleton *outSkeleton);

/**
 * @brief Crossfade from one animation to another
 * @param fromState Animation to fade from
 * @param toState Animation to fade to
 * @param duration Crossfade duration in seconds
 */
MKLAPI void MKLCrossfadeAnimation(MKLAnimationState *fromState,
                                    MKLAnimationState *toState,
                                    float duration);

// ========== Mesh Animation Functions ==========

/**
 * @brief Attach a skeleton to a mesh for skinning
 * @param mesh Mesh to attach skeleton to
 * @param skeleton Skeleton to attach
 */
MKLAPI void MKLAttachSkeletonToMesh(MKLMesh *mesh, MKLSkeleton *skeleton);

/**
 * @brief Detach skeleton from mesh
 * @param mesh Mesh to detach from
 */
MKLAPI void MKLDetachSkeletonFromMesh(MKLMesh *mesh);

/**
 * @brief Check if mesh has an attached skeleton
 * @param mesh Mesh to check
 * @return true if skeleton is attached
 */
MKLAPI bool MKLMeshHasSkeleton(const MKLMesh *mesh);

// ========== Utility Functions ==========

/**
 * @brief Get bone index by name
 * @param skeleton Skeleton to search
 * @param boneName Name of bone
 * @return Bone index or -1 if not found
 */
MKLAPI int MKLGetBoneIndex(const MKLSkeleton *skeleton, const char *boneName);

/**
 * @brief Get bone transform matrix
 * @param skeleton Skeleton
 * @param boneIndex Index of bone
 * @return Global transform matrix
 */
MKLAPI matrix_float4x4 MKLGetBoneTransform(const MKLSkeleton *skeleton, int boneIndex);

/**
 * @brief Set bone transform matrix
 * @param skeleton Skeleton
 * @param boneIndex Index of bone
 * @param transform New transform matrix
 */
MKLAPI void MKLSetBoneTransform(MKLSkeleton *skeleton, int boneIndex, matrix_float4x4 transform);

#ifdef __cplusplus
}
#endif

#endif /* MKLAnimation_h */

