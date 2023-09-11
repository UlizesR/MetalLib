#ifndef _mcl_scene_h_
#define _mcl_scene_h_

#include <simd/simd.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface MCL_NsCamera : NSObject
@property(nonatomic, assign) vector_float3 position;
@property(nonatomic, assign) vector_float3 eulers;
@property(nonatomic, assign) vector_float3 forward;
@property(nonatomic, assign) vector_float3 right;
@property(nonatomic, assign) vector_float3 up;
@end

@interface MCL_NsSimpleComponent : NSObject
@property(nonatomic, assign) vector_float3 position;
@property(nonatomic, assign) vector_float3 eulers;

- (id)initWithPos:(vector_float3)position eulers:(vector_float3)eulers;
@end

@interface MCL_NsScene : NSObject
@property(nonatomic, strong) MCL_NsCamera *player;
@property(nonatomic, strong) NSMutableArray<MCL_NsSimpleComponent *> *triangles;
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif



#ifdef __cplusplus
}
#endif

#endif // _mcl_scene_h_