#ifndef GULI_METAL_TYPES_H
#define GULI_METAL_TYPES_H

#ifdef __OBJC__
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

struct MetalState {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _library;
    CAMetalLayer* _layer;
};
#endif

#endif