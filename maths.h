#pragma once

#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  float x;
  float y;
} Vector2;

typedef struct {
  float x;
  float y;
  float z;
} Vector3;

typedef struct {
  float x;
  float y;
  float z;
  float w;
} Vector4;

typedef struct {
  Vector2 v;
} Matrix2x1;

typedef struct {
  Vector2 v1;
  Vector2 v2;
} Matrix2x2;

typedef struct {
  Vector2 v1;
  Vector2 v2;
  Vector2 v3;
} Matrix2x3;

typedef struct {
  Vector3 v;
} Matrix3x1;

typedef struct {
  Vector2 v1;
  Vector2 v2;
} Matrix3x2;

typedef struct {
  Vector3 v1;
  Vector3 v2;
  Vector3 v3;
} Matrix3x3;

typedef struct {
  Vector4 v;
} Matrix4x1;

typedef struct {
  Vector4 v1;
  Vector4 v2;
  Vector4 v3;
  Vector4 v4;
} Matrix4x4;

typedef struct {
  float x;
  float y;
  float z;
  float w;
} Quaternion;

void AddVector2(Vector2 *v1, Vector2 *v2, Vector2 *result);
void AddVector3(Vector3 *v1, Vector3 *v2, Vector3 *result);
void AddVector4(Vector4 *v1, Vector4 *v2, Vector4 *result);

void SubtractVector2(Vector2 *v1, Vector2 *v2, Vector2 *result);
void SubtractVector3(Vector3 *v1, Vector3 *v2, Vector3 *result);
void SubtractVector4(Vector4 *v1, Vector4 *v2, Vector4 *result);

void DotProductVector2(Vector2 *v1, Vector2 *v2, float result);
void DotProductVector3(Vector3 *v1, Vector3 *v2, float result);
void DotProductVector4(Vector4 *v1, Vector4 *v2, float result);

void CrossProductVector3(Vector3 *v1, Vector3 *v2, Vector3 *result);

void MultiplyVector2(Vector2 *v1, float scalar, Vector2 *result);
void MultiplyVector3(Vector3 *v1, float scalar, Vector3 *result);
void MultiplyVector4(Vector4 *v1, float scalar, Vector4 *result);

void MultiplyMatrix2x1(Matrix2x1 *m1, float scalar, Matrix2x1 *result);
void MultiplyMatrix2x2(Matrix2x2 *m1, float scalar, Matrix2x2 *result);
void MultiplyMatrix2x3(Matrix2x3 *m1, float scalar, Matrix2x3 *result);

void MultiplyMatrix3x1(Matrix3x1 *m1, float scalar, Matrix3x1 *result);
void MultiplyMatrix3x2(Matrix3x2 *m1, float scalar, Matrix3x2 *result);
void MultiplyMatrix3x3(Matrix3x3 *m1, float scalar, Matrix3x3 *result);

void MultiplyMatrix4x1(Matrix4x1 *m1, float scalar, Matrix4x1 *result);
void MultiplyMatrix4x4(Matrix4x4 *m1, float scalar, Matrix4x4 *result);

void MultiplyMatrix2x1Vector2(Matrix2x1 *m1, Vector2 *v1, Vector2 *result);
void MultiplyMatrix2x2Vector2(Matrix2x2 *m1, Vector2 *v1, Vector2 *result);
void MultiplyMatrix2x3Vector3(Matrix2x3 *m1, Vector3 *v1, Vector3 *result);

void MultiplyMatrix3x1Vector3(Matrix3x1 *m1, Vector3 *v1, Vector3 *result);
void MultiplyMatrix3x2Vector3(Matrix3x2 *m1, Vector3 *v1, Vector3 *result);
void MultiplyMatrix3x3Vector3(Matrix3x3 *m1, Vector3 *v1, Vector3 *result);

void MultiplyMatrix4x1Vector4(Matrix4x1 *m1, Vector4 *v1, Vector4 *result);
void MultiplyMatrix4x4Vector4(Matrix4x4 *m1, Vector4 *v1, Vector4 *result);

#ifdef __cplusplus
}
#endif