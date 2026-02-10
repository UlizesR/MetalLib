#ifndef _MKL_MATH_H_
#define _MKL_MATH_H_

#include <simd/matrix.h>
#include <simd/vector.h>

#include "../Core/MKLCore.h"

/// Common axis vectors
#define MKL_X_AXIS simd_make_float3(1.0f, 0.0f, 0.0f)
#define MKL_Y_AXIS simd_make_float3(0.0f, 1.0f, 0.0f)
#define MKL_Z_AXIS simd_make_float3(0.0f, 0.0f, 1.0f)

/// World origin point
#define MKL_WORLD_ORIGIN simd_make_float4(0.0f, 0.0f, 0.0f, 1.0f)

/// Identity matrix
#define MKL_IDENTITY_MATRIX matrix_identity_float4x4

/**
 * @brief Creates a translation matrix.
 * @param direction Translation vector
 * @return Translation matrix
 */
MKLAPI matrix_float4x4 MTranslate(const vector_float3 direction);

/**
 * @brief Creates a look-at view matrix.
 * @param eye Camera position
 * @param target Target position to look at
 * @param up Up vector
 * @return View matrix
 */
MKLAPI matrix_float4x4 MLookAt(const vector_float3 eye, const vector_float3 target, const vector_float3 up);

/**
 * @brief Creates a perspective projection matrix.
 * @param fov Field of view in degrees
 * @param aspect Aspect ratio (width/height)
 * @param near Near clipping plane distance
 * @param far Far clipping plane distance
 * @return Perspective projection matrix
 */
MKLAPI matrix_float4x4 MPerspective(const float fov, const float aspect, const float near, const float far);

/**
 * @brief Creates a scale matrix.
 * @param scale Scale factors for x, y, z axes
 * @return Scale matrix
 */
MKLAPI matrix_float4x4 MScale(const vector_float3 scale);

/**
 * @brief Creates a rotation matrix from Euler angles.
 * @param eulers Euler angles in degrees (x, y, z)
 * @return Rotation matrix
 */
MKLAPI matrix_float4x4 MRotate(const vector_float3 eulers);

/**
 * @brief Creates a rotation matrix around the X axis.
 * @param angle Rotation angle in radians
 * @return Rotation matrix
 */
MKLAPI matrix_float4x4 MRotateX(const float angle);

/**
 * @brief Creates a rotation matrix around the Y axis.
 * @param angle Rotation angle in radians
 * @return Rotation matrix
 */
MKLAPI matrix_float4x4 MRotateY(const float angle);

/**
 * @brief Creates a rotation matrix around the Z axis.
 * @param angle Rotation angle in radians
 * @return Rotation matrix
 */
MKLAPI matrix_float4x4 MRotateZ(const float angle);

/**
 * @brief Adds two vectors using SIMD operations.
 * @param vec1 First vector
 * @param vec2 Second vector
 * @return Sum of vectors
 */
MKLAPI vector_float3 MAddVector(const vector_float3 vec1, const vector_float3 vec2);

/**
 * @brief Subtracts two vectors using SIMD operations.
 * @param vec1 First vector
 * @param vec2 Second vector
 * @return Difference of vectors
 */
MKLAPI vector_float3 MSubVector(const vector_float3 vec1, const vector_float3 vec2);

/**
 * @brief Multiplies a vector by a scalar using SIMD operations.
 * @param vec1 Input vector
 * @param scalar Scalar multiplier
 * @return Scaled vector
 */
MKLAPI vector_float3 MMulVecByScalar(const vector_float3 vec1, const float scalar);

/**
 * @brief Normal matrix for correct lighting under non-uniform scale.
 * Returns the inverse-transpose of the upper-left 3x3 of model (column-major).
 * Use for transforming normals; compute once per object on CPU.
 * @param model Model matrix (e.g. scale * rotation * translation)
 * @return matrix_float3x3 to transform normals in the vertex shader
 */
MKLAPI matrix_float3x3 MKLNormalMatrix3x3(const matrix_float4x4 model);

#endif // _MKL_MATH_H_
