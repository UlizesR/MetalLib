#pragma once

#include <math.h>

typedef struct vec4 {
    float x, y, z, w;
} vec4;

typedef struct vec3 {
    float x, y, z;
} vec3;

void translate(vec3 pos, vec4 *t) {
  t[0] = (vec4){1, 0, 0, 0};
  t[1] = (vec4){0, 1, 0, 0};
  t[2] = (vec4){0, 0, 1, 0};
  t[3] = (vec4){pos.x, pos.y, pos.z, 1};
}

void rotate_x(float angle, vec4 *rx) {
  float cos_angle = cos(angle);
  float sin_angle = sin(angle);

  rx[0] = (vec4){1, 0, 0, 0};
  rx[1] = (vec4){0, cos_angle, sin_angle, 0};
  rx[2] = (vec4){0, -sin_angle, cos_angle, 0};
  rx[3] = (vec4){0, 0, 0, 1};
}

void rotate_y(float angle, vec4 *ry) {
  float cos_angle = cos(angle);
  float sin_angle = sin(angle);

  ry[0] = (vec4){cos_angle, 0, -sin_angle, 0};
  ry[1] = (vec4){0, 1, 0, 0};
  ry[2] = (vec4){sin_angle, 0, cos_angle, 0};
  ry[3] = (vec4){0, 0, 0, 1};
}

void rotate_z(float angle, vec4 *rz) {
  float cos_angle = cos(angle);
  float sin_angle = sin(angle);

  rz[0] = (vec4){cos_angle, sin_angle, 0, 0};
  rz[1] = (vec4){-sin_angle, cos_angle, 0, 0};
  rz[2] = (vec4){0, 0, 1, 0};
  rz[3] = (vec4){0, 0, 0, 1};
}

void scale(vec3 scale, vec4 *s) {
  s[0] = (vec4){scale.x, 0, 0, 0};
  s[1] = (vec4){0, scale.y, 0, 0};
  s[2] = (vec4){0, 0, scale.z, 0};
  s[3] = (vec4){0, 0, 0, 1};
}

float dot3(vec3 a, vec3 b)
{
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

vec3 cross(vec3 a, vec3 b)
{
    return (vec3){a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x};
}

vec3 normalize3(vec3 v) {
  float inv_mag = 1 / sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  return (vec3){v.x * inv_mag, v.y * inv_mag, v.z * inv_mag};
}

float dot4(vec4 a, vec4 b)
{
    return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
}

vec4 normalize4(vec4 v) {
  float inv_mag = 1 / sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
  return (vec4){v.x * inv_mag, v.y * inv_mag, v.z * inv_mag, v.w * inv_mag};
}

void multiply(vec4* a, vec4* b, vec4* m)
{
    m[0] = (vec4){dot4(a[0],b[0]), dot4(a[0],b[1]), dot4(a[0],b[2]), dot4(a[0],b[3])};
    m[1] = (vec4){dot4(a[1],b[0]), dot4(a[1],b[1]), dot4(a[1],b[2]), dot4(a[1],b[3])};
    m[2] = (vec4){dot4(a[2],b[0]), dot4(a[2],b[1]), dot4(a[2],b[2]), dot4(a[2],b[3])};
    m[3] = (vec4){dot4(a[3],b[0]), dot4(a[3],b[1]), dot4(a[3],b[2]), dot4(a[3],b[3])};
}