#import "MCL/graphics/scene.h"
#import <simd/vector_types.h>

#import <Cocoa/Cocoa.h>

@implementation MCL_NsCamera

- (id)initWithPos:(vector_float3)position eulers:(vector_float3)eulers {
  self = [super init];
  if (!self) {
    fprintf(stderr, "Failed to create MCL_NsCamera\n");
    return nil;
  }
  self.position = position;
  self.eulers = eulers;
  self.forward = (vector_float3){0.0f, 0.0f, 0.0f};
  self.right = (vector_float3){0.0f, 0.0f, 0.0f};
  self.up = (vector_float3){0.0f, 0.0f, 0.0f};
  return self;
}

- (void)updateVectors {
  self.forward = (vector_float3){cosf(self.eulers[2] * M_PI / 180.0f) * cosf(self.eulers[1] * M_PI / 180.0f),
                                 sinf(self.eulers[2] * M_PI / 180.0f) * sinf(self.eulers[1] * M_PI / 180.0f),
                                 cosf(self.eulers[1] * M_PI / 180.0f)};

  vector_float3 globalUp = {0.0f, 0.0f, 1.0f};
  self.right = simd_cross(globalUp, self.forward);
  self.up = simd_cross(self.forward, self.right);
}
@end

@implementation MCL_NsSimpleComponent
- (id)initWithPos:(vector_float3)position eulers:(vector_float3)euleres {
  self = [super init];
  if (!self) {
    fprintf(stderr, "Failed to create MCL_NsSimpleComponent\n");
    return nil;
  }
  self.position = position;
  self.eulers = euleres;
  return self;
}
@end

@implementation MCL_NsScene
- (id)init
{
    self = [super init];
    if (!self)
    {
        fprintf(stderr, "Failed to create MCL_NsScene\n");
        return nil;
    }
    vector_float3 cPosition = {1.0f, 2.0f, 1.0f};
    vector_float3 cEulers = {0.0f, 90.0f, 315.0f};
    vector_float3 tPosition = {3.0f, 0.0f, 0.0f};
    vector_float3 tEulers = {0.0f, 0.0f, 0.0f};

    self.player = [[MCL_NsCamera alloc] initWithPos:cPosition eulers:cEulers];
    self.triangles = [[NSMutableArray alloc] init];
    [self.triangles addObject:[[MCL_NsSimpleComponent alloc] initWithPos:tPosition eulers:tEulers]];
    
    return self;
}

- (void)update
{
    [self.player updateVectors];
    for (MCL_NsSimpleComponent *triangle in self.triangles) {
      vector_float3 newEulers = triangle.eulers;
      newEulers.x += 0.01;
      if (newEulers.x > 360) {
        newEulers.x -= 360;
      }
      triangle.eulers = newEulers;
    }
}
@end
