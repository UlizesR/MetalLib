#import "MCL/math/linear_algebra.h"
#include <simd/vector_types.h>
#include <simd/types.h>

#import <Cocoa/Cocoa.h>
#import <simd/simd.h>

@implementation Matrix44
- (id)init {
  self = [super init];
  if (!self) {
    fprintf(stderr, "Failed to create Matrix44\n");
    return nil;
  }
  return self;
}

+ (simd_float4x4)create_identity
{
    return (simd_float4x4)
    {
        (vector_float4){1.0f, 0.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, 1.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, 1.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, 0.0f, 1.0f}
    };
}

+ (simd_float4x4)create_from_translation:(vector_float3)translation
{
    return (simd_float4x4)
    {
        (vector_float4){1.0f, 0.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, 1.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, 1.0f, 0.0f},
        (vector_float4){translation.x, translation.y, translation.z, 1.0f}
    };
}

+ (simd_float4x4)create_from_rotation:(vector_float3)eulers
{
    float gamma = eulers.x * M_PI / 180.0f;
    float beta = eulers.y * M_PI / 180.0f;
    float alpha = eulers.z * M_PI / 180.0f;
    simd_float4x4 rotationZ = [self create_from_z_rotation:alpha];
    simd_float4x4 rotationY = [self create_from_y_rotation:beta];
    simd_float4x4 rotationX = [self create_from_x_rotation:gamma];
    return simd_mul(simd_mul(rotationZ, rotationY), rotationX);
}

+ (simd_float4x4)create_lookat_withEye:(vector_float3)eye target:(vector_float3)target up:(vector_float3)up
{
    simd_float3 forwards = simd_normalize(target - eye);
    simd_float3 right = simd_normalize(simd_cross(up, forwards));
    simd_float3 up2 = simd_normalize(simd_cross(forwards, right));
    
    return (simd_float4x4)
    {
        (vector_float4){right.x, up2.x, forwards.x, 0.0f},
        (vector_float4){right.y, up2.y, forwards.y, 0.0f},
        (vector_float4){right.z, up2.z, forwards.z, 0.0f},
        (vector_float4){-simd_dot(right, eye), -simd_dot(up2, eye), -simd_dot(forwards, eye), 1.0f}
    };
}

+ (simd_float4x4)create_perspective_projectionWithFovy:(float)fovy aspect:(float)aspect near:(float)near far:(float)far
{
    float A = aspect * 1.0f / tan(fovy * M_PI / 360.0f);
    float B = 1.0f / tan(fovy * M_PI / 360.0f);
    float C = far / (far - near);
    float D = 1.0f;
    float E = -near * far / (far - near);
    
    return (simd_float4x4)
    {
        (vector_float4){A, 0.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, B, 0.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, C, D},
        (vector_float4){0.0f, 0.0f, E, 0.0f}
    };
}

+ (simd_float4x4)create_from_x_rotation:(float)theta
{
    return (simd_float4x4)
    {
        (vector_float4){1.0f, 0.0f, 0.0f, 0.0f},
        (vector_float4){0.0f, cos(theta), sin(theta), 0.0f},
        (vector_float4){0.0f, -sin(theta), cos(theta), 0.0f},
        (vector_float4){0.0f, 0.0f, 0.0f, 1.0f}
    };
}

+ (simd_float4x4)create_from_y_rotation:(float)theta
{
    return (simd_float4x4)
    {
        (vector_float4){cos(theta), 0.0f, -sin(theta), 0.0f},
        (vector_float4){0.0f, 1.0f, 0.0f, 0.0f},
        (vector_float4){sin(theta), 0.0f, cos(theta), 0.0f},
        (vector_float4){0.0f, 0.0f, 0.0f, 1.0f}
    };
}

+ (simd_float4x4)create_from_z_rotation:(float)theta
{
    return (simd_float4x4)
    {
        (vector_float4){cos(theta), sin(theta), 0.0f, 0.0f},
        (vector_float4){-sin(theta), cos(theta), 0.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, 1.0f, 0.0f},
        (vector_float4){0.0f, 0.0f, 0.0f, 1.0f}
    };
}
@end