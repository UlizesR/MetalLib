#ifndef _MKL_RENDERER_H_
#define _MKL_RENDERER_H_

#include <_types/_uint32_t.h>
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

#import <simd/simd.h>

@interface MklRenderer : NSObject <MTKViewDelegate>

@property (nonatomic) vector_float2 bounds;
@property (nonatomic) float deltaTime;
@property (nonatomic) MTLClearColor clearColor;
// command queue
@property(nonatomic, strong, nonnull) id<MTLCommandQueue> commandQueue;

- (nonnull instancetype)initRenderer:(MTKView *_Nonnull)view;
- (void)updateScreenSize:(MTKView *_Nonnull)view;

@end 
#endif // __OBJC__

#include "../MKLDefs.h"
#include "../MKLColors.h"
#include "MKLView.h"

#include <stdint.h>

// typedef struct MKLView MKLView;
typedef struct MKLRenderer MKLRenderer;

struct MKLRenderer 
{
    MKLWindow *window;

#ifdef __OBJC__
    MklRenderer *_renderer;
    MklView *_view;
#endif
};

MKL_PUBLIC MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKL_PUBLIC void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKL_PUBLIC void MKLDestroyRenderer(MKLRenderer *renderer);


#endif // _MKL_RENDERER_H_